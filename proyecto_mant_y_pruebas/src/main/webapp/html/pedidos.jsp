<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>
<%@ page import="java.util.List, java.util.ArrayList" %>

<%
Integer admin = (Integer) session.getAttribute("admin");
if (admin == null) admin = 0;

request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

int pendientes = 0;
int enProceso = 0;
int completadosHoy = 0;
double totalDelDia = 0.0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");

    // Pedidos Pendientes
    PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM pedido WHERE estado = 'pendiente'");
    ResultSet rs1 = ps1.executeQuery();
    if (rs1.next()) pendientes = rs1.getInt(1);
    rs1.close(); ps1.close();

    // Pedidos en Proceso
    PreparedStatement ps2 = conn.prepareStatement("SELECT COUNT(*) FROM pedido WHERE estado = 'En proceso'");
    ResultSet rs2 = ps2.executeQuery();
    if (rs2.next()) enProceso = rs2.getInt(1);
    rs2.close(); ps2.close();

    // Completados hoy
    PreparedStatement ps3 = conn.prepareStatement("SELECT COUNT(*) FROM pedido WHERE estado = 'completado' AND DATE(fecha_pedido) = CURDATE()");
    ResultSet rs3 = ps3.executeQuery();
    if (rs3.next()) completadosHoy = rs3.getInt(1);
    rs3.close(); ps3.close();

    // Total del día
    PreparedStatement ps4 = conn.prepareStatement(
        "SELECT COALESCE(SUM(monto), 0) FROM pedido " +
        "WHERE DATE(fecha_pedido) = CURDATE() " +
        "AND estado != 'cancelado'"
    );
    ResultSet rs4 = ps4.executeQuery();
    if (rs4.next()) totalDelDia = rs4.getDouble(1);
    rs4.close(); ps4.close();

    conn.close();
} catch (Exception e) {
    out.println("<p style='color:red;'>Error al cargar estadísticas: " + e.getMessage() + "</p>");
}

List<String[]> pedidos = new ArrayList<>();

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
    // Consulta que une pedido con cliente
    String sql = "SELECT p.id, c.id, p.fecha_pedido, pr.nombre, p.cant, p.monto, p.estado, p.metodo_pago " +
             "FROM pedido p " +
             "JOIN cliente c ON p.id_cliente = c.id " +
             "JOIN producto pr ON p.id_prod = pr.id " +
             "ORDER BY p.fecha_pedido DESC";
    PreparedStatement ps = conn.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();

    while (rs.next()) {
        String[] fila = new String[8];
        fila[0] = String.valueOf(rs.getInt(1));  // p.id (ID Pedido)
        fila[1] = String.valueOf(rs.getInt(2));  // c.id (ID Cliente)
        fila[2] = new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getDate(3)); // p.fecha_pedido
        fila[3] = rs.getString(4);               // pr.nombre (Producto)
        fila[4] = String.valueOf(rs.getInt(5));  // p.cantidad
        fila[5] = String.format("$%.2f", rs.getDouble(6)); // p.monto (Total)
        fila[6] = rs.getString(7);               // p.estado
        fila[7] = "Cambiar";                     // Para acción de cambio de estado
        pedidos.add(fila);
    }

    rs.close();
    ps.close();
    conn.close();
} catch (Exception e) {
    out.println("<p style='color:red;'>Error al cargar pedidos: " + e.getMessage() + "</p>");
}

// Variables para manejo de parámetros
String idClienteStr = request.getParameter("idCliente");
String idProductoStr = request.getParameter("idProducto");
String cantidadStr = request.getParameter("cantidad");
String metodoPago = request.getParameter("metodoPago");
String idPedidoStr = request.getParameter("idPedido");
String nuevoEstado = request.getParameter("nuevoEstado");

boolean mostrarResumen = false;
String mensaje = "";

// MANEJO DE CAMBIO DE ESTADO DEL PEDIDO
if (idPedidoStr != null && nuevoEstado != null && !nuevoEstado.trim().isEmpty()) {
    try {
        int idPedido = Integer.parseInt(idPedidoStr);
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
        
        // Iniciar transacción
        conn.setAutoCommit(false);
        
        try {
            // 1. Obtener el estado actual del pedido y datos del producto
            String sqlPedidoActual = "SELECT estado, id_prod, cant FROM pedido WHERE id = ?";
            PreparedStatement psActual = conn.prepareStatement(sqlPedidoActual);
            psActual.setInt(1, idPedido);
            ResultSet rsActual = psActual.executeQuery();
            
            String estadoActual = "";
            int idProductoPedido = 0;
            int cantidadPedido = 0;
            
            if (rsActual.next()) {
                estadoActual = rsActual.getString("estado");
                idProductoPedido = rsActual.getInt("id_prod");
                cantidadPedido = rsActual.getInt("cant");
            } else {
                mensaje = "<p style='color:red;'>Error: Pedido no encontrado.</p>";
                conn.rollback();
                conn.close();
                response.sendRedirect("pedidos.jsp");
                return;
            }
            rsActual.close();
            psActual.close();
            
            // 2. Verificar si el estado actual permite cambios
            if ("completado".equalsIgnoreCase(estadoActual) || "cancelado".equalsIgnoreCase(estadoActual)) {
                mensaje = "<p style='color:red;'>Error: No se puede cambiar el estado de un pedido " + estadoActual + ".</p>";
                conn.rollback();
                conn.close();
                response.sendRedirect("pedidos.jsp");
                return;
            }
            
            // 3. Si se está cancelando el pedido, devolver stock
            if ("cancelado".equalsIgnoreCase(nuevoEstado)) {
                String updateStockSql = "UPDATE producto SET stock = stock + ? WHERE id = ?";
                PreparedStatement psStock = conn.prepareStatement(updateStockSql);
                psStock.setInt(1, cantidadPedido);
                psStock.setInt(2, idProductoPedido);
                int stockActualizado = psStock.executeUpdate();
                psStock.close();
                
                if (stockActualizado == 0) {
                    mensaje = "<p style='color:red;'>Error: No se pudo restaurar el stock del producto.</p>";
                    conn.rollback();
                    conn.close();
                    response.sendRedirect("pedidos.jsp");
                    return;
                }
            }
            
            // 4. Actualizar el estado del pedido
            String sqlUpdate = "UPDATE pedido SET estado = ? WHERE id = ?";
            PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate);
            psUpdate.setString(1, nuevoEstado);
            psUpdate.setInt(2, idPedido);
            int filasAfectadas = psUpdate.executeUpdate();
            psUpdate.close();
            
            if (filasAfectadas > 0) {
                // Confirmar transacción
                conn.commit();
                
                if ("cancelado".equalsIgnoreCase(nuevoEstado)) {
                    mensaje = "<p style='color:green;'>Pedido cancelado exitosamente. Stock restaurado.</p>";
                } else {
                    mensaje = "<p style='color:green;'>Estado del pedido actualizado exitosamente.</p>";
                }
            } else {
                conn.rollback();
                mensaje = "<p style='color:red;'>Error: No se pudo actualizar el estado del pedido.</p>";
            }
            
        } catch (Exception e) {
            conn.rollback();
            mensaje = "<p style='color:red;'>Error al actualizar estado: " + e.getMessage() + "</p>";
        } finally {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (Exception e) {}
        }
        
        response.sendRedirect("pedidos.jsp");
        return;
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error al actualizar estado: " + e.getMessage() + "</p>");
    }
}

// MANEJO DE CREACIÓN DE NUEVO PEDIDO
if (idClienteStr != null && idProductoStr != null && cantidadStr != null && metodoPago != null) {
    try {
        int idCliente = Integer.parseInt(idClienteStr);
        int idProducto = Integer.parseInt(idProductoStr);
        int cantidad = Integer.parseInt(cantidadStr);
        double precio = 0.0;
        double monto = 0.0;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String url = "jdbc:mysql://localhost/tienda";
            String user = "root";
            String pass = "";

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);
            
            // Iniciar transacción
            conn.setAutoCommit(false);

            // 1. Verificar que el producto existe y obtener precio y stock actual
            String sqlProducto = "SELECT precio, stock FROM producto WHERE id = ?";
            ps = conn.prepareStatement(sqlProducto);
            ps.setInt(1, idProducto);
            rs = ps.executeQuery();

            int stockActual = 0;
            if (rs.next()) {
                precio = rs.getDouble("precio");
                stockActual = rs.getInt("stock");
            } else {
                mensaje = "<p style='color:red;'>Error: Producto no encontrado.</p>";
                conn.rollback();
                return;
            }
            rs.close();
            ps.close();

            // 2. Verificar que hay suficiente stock
            if (stockActual < cantidad) {
                mensaje = "<p style='color:red;'>Error: Stock insuficiente. Stock disponible: " + stockActual + "</p>";
                conn.rollback();
                return;
            }

            monto = precio * cantidad;

            Date fechaActual = new Date();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String fechaStr = sdf.format(fechaActual);

            // 3. Insertar el pedido
            String insertSql = "INSERT INTO pedido (id_cliente, fecha_pedido, estado, monto, metodo_pago, id_prod, cant) VALUES (?, ?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(insertSql);
            ps.setInt(1, idCliente);
            ps.setString(2, fechaStr);
            ps.setString(3, "pendiente");
            ps.setDouble(4, monto);
            ps.setString(5, metodoPago);
            ps.setInt(6, idProducto);
            ps.setInt(7, cantidad);
            int filasAfectadas = ps.executeUpdate();
            ps.close();

            if (filasAfectadas > 0) {
                // 4. Actualizar el stock del producto
                String updateStockSql = "UPDATE producto SET stock = stock - ? WHERE id = ?";
                ps = conn.prepareStatement(updateStockSql);
                ps.setInt(1, cantidad);
                ps.setInt(2, idProducto);
                int stockActualizado = ps.executeUpdate();
                ps.close();

                if (stockActualizado > 0) {
                    // Confirmar transacción
                    conn.commit();
                    mostrarResumen = true;
                    mensaje = "<p style='color:green;'>Pedido creado exitosamente. Stock actualizado.</p>";
                } else {
                    // Revertir transacción si no se pudo actualizar el stock
                    conn.rollback();
                    mensaje = "<p style='color:red;'>Error: No se pudo actualizar el stock del producto.</p>";
                }
            } else {
                conn.rollback();
                mensaje = "<p style='color:red;'>Error: No se pudo guardar el pedido.</p>";
            }
            
            response.sendRedirect("pedidos.jsp");
            return;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }
            mensaje = "<p style='color:red;'>Error en la base de datos: " + e.getMessage() + "</p>";
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true); // Restaurar auto-commit
                    conn.close(); 
                }
            } catch (Exception e) {}
        }

    } catch (NumberFormatException e) {
        mensaje = "<p style='color:red;'>Error: Los datos ingresados no son válidos.</p>";
    }
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion de Pedidos - Sistema de Inventario</title>
    <link rel="stylesheet" href="../css/pedidos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <!-- ENCABEZADO -->
    <header>
	    <nav class="menu-principal">
	        <img src="../imagenes/LOGOO.png" alt="Logo" class="logo">
	        <ul>
	            <li><a href="home.jsp">Panel principal</a></li>
	            <li><a href="inventario.jsp">Inventario</a></li>
	            <li><a href="cliente.jsp">Clientes</a></li>
	            <li><a href="pedidos.jsp">Pedidos</a></li>
	            <li><a href="nosotros.jsp">Nosotros</a></li>
	            
	            <% if (admin == 1) { %>
                <!-- Opciones exclusivas para admin -->
                <li><a href="gestionUsuarios.jsp">Gestión de Usuarios</a></li>
                <li><a href="proveedores.jsp">Proveedores</a></li>
            	<% } %>
	        </ul>
	    </nav>
	</header>

    <main class="container">
        <div class="seccion">
            <div class="titulo">
                <h1>Gestion de Pedidos</h1>
                <p>Administra y supervisa todos los pedidos de tu negocio</p>
            </div>

            <div class="stats-grid">
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <div class="stat-label">Pedidos Pendientes</div>
			                <div class="stat-value yellow"><%= pendientes %></div>
			            </div>
			            <div class="stat-icon">
			                <i class="fas fa-clock"></i>
			            </div>
			        </div>
			    </div>
			
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <div class="stat-label">En Proceso</div>
			                <div class="stat-value blue"><%= enProceso %></div>
			            </div>
			            <div class="stat-icon">
			                <i class="fas fa-cogs"></i>
			            </div>
			        </div>
			    </div>
			
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <div class="stat-label">Completados Hoy</div>
			                <div class="stat-value green"><%= completadosHoy %></div>
			            </div>
			            <div class="stat-icon">
			                <i class="fas fa-check-circle"></i>
			            </div>
			        </div>
			    </div>
			
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <div class="stat-label">Total del Día</div>
			                <div class="stat-value blue">$<%= String.format("%.2f", totalDelDia) %></div>
			            </div>
			            <div class="stat-icon">
			                <i class="fas fa-dollar-sign"></i>
			            </div>
			        </div>
			    </div>
			</div>

            <div class="controls">
                <div class="controls-left">
                    <div class="search-box">
                        <input type="text" placeholder="Buscar pedidos..." id="searchInput">
                    </div>
                    
                    <div class="filter-box">
                        <select id="statusFilter">
                            <option value="">Todos los estados</option>
                            <option value="pendiente">Pendiente</option>
                            <option value="proceso">En Proceso</option>
                            <option value="completado">Completado</option>
                            <option value="cancelado">Cancelado</option>
                        </select>
                    </div>

                    <div class="filter-box">
                        <select id="dateFilter">
                            <option value="">Todos los pedidos</option>
                            <option value="hoy">Hoy</option>
                            <option value="semana">Esta semana</option>
                            <option value="mes">Este mes</option>
                        </select>
                    </div>
                </div>
                
                <div class="controls-right">
                    <button class="btn btn-primary" id="addOrderBtn" onclick="openProductoModal()">
                        <i class="fas fa-plus"></i>
                        Nuevo Pedido
                    </button>
                </div>
            </div>

            <div class="table-container">
                <table class="products-table">
                    <thead>
                        <tr>
                            <th>ID Pedido</th>
                            <th>ID Cliente</th>
                            <th>Fecha</th>
                            <th>Producto</th> 
                            <th>cantidad</th>      
                            <th>Total</th>
                            <th>Estado</th>
                            <th>cambiar estado</th>
                        </tr>
                    </thead>
                    <tbody id="ordersTableBody">
					    <%
					        for (String[] fila : pedidos) {
					            String estado = fila[6];
					            boolean estadoBloqueado = "completado".equalsIgnoreCase(estado) || "cancelado".equalsIgnoreCase(estado);
					    %>
					        <tr>
					            <td><%= fila[0] %></td> <!-- ID Pedido -->
					            <td><%= fila[1] %></td> <!-- ID Cliente -->
					            <td><%= fila[2] %></td> <!-- Fecha -->
					            <td><%= fila[3] %></td> <!-- Producto -->
					            <td><%= fila[4] %></td> <!-- Cantidad -->
					            <td><%= fila[5] %></td> <!-- Total -->
					            <td>
					                <span class="estado-badge estado-<%= estado.toLowerCase().replace(" ", "-") %>">
					                    <%= estado %>
					                </span>
					            </td>
					            <td>
					                <% if (estadoBloqueado) { %>
					                    <span class="estado-bloqueado">
					                        <i class="fas fa-lock"></i> Bloqueado
					                    </span>
					                <% } else { %>
					                    <form method="post" action="pedidos.jsp" style="display:inline;">
					                        <input type="hidden" name="idPedido" value="<%= fila[0] %>">
					                        <select name="nuevoEstado" onchange="confirmarCambioEstado(this)" class="select-estado">
					                            <option value="">-- Cambiar estado --</option>
					                            <option value="pendiente" <%= "pendiente".equalsIgnoreCase(estado) ? "selected" : "" %>>Pendiente</option>
					                            <option value="En proceso" <%= "En proceso".equalsIgnoreCase(estado) ? "selected" : "" %>>En Proceso</option>
					                            <option value="completado" <%= "completado".equalsIgnoreCase(estado) ? "selected" : "" %>>Completado</option>
					                            <option value="cancelado" <%= "cancelado".equalsIgnoreCase(estado) ? "selected" : "" %>>Cancelado</option>
					                        </select>
					                    </form>
					                <% } %>
					            </td>
					        </tr>
					    <%
					        }
					    %>
					</tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal para agregar producto al pedido -->
	<div class="modal" id="productoModal">
	    <div class="modal-content">
	        <div class="modal-header">
	            <h2>Agregar Producto al Pedido</h2>
	            <button class="close-btn" onclick="closeProductoModal()">&times;</button>
	        </div>
	        <div class="modal-body">
	            <form id="productoForm" method="post">
				    <div class="form-group">
				        <label for="clienteId">ID del Cliente</label>
				        <input type="text" id="clienteId" name="idCliente" required>
				    </div>
				
				    <div class="form-group">
				        <label for="paymentMethod">Método de Pago</label>
				        <select id="paymentMethod" name="metodoPago" required>
				            <option value="">Selecciona método de pago</option>
				            <option value="efectivo">Efectivo</option>
				            <option value="tarjeta">Tarjeta de Crédito</option>
				            <option value="transferencia">Transferencia</option>
				            <option value="otro">Otro</option>
				        </select>
				    </div>
				
				    <div class="form-group">
				        <label for="productoId">ID del Producto</label>
				        <input type="text" id="productoId" name="idProducto" required>
				    </div>
				
				    <div class="form-group">
				        <label for="cantidadProducto">Cantidad</label>
				        <input type="number" id="cantidadProducto" name="cantidad" min="1" value="1" required>
				    </div>
				
				    <div class="modal-footer">
				        <button type="button" class="btn btn-secondary" onclick="closeProductoModal()">Cancelar</button>
				        <button type="submit" class="btn btn-primary">Agregar</button>
				    </div>
				</form>
	        </div>
	    </div>
	</div>

    <footer>
        <!-- Menú secundario -->
        <nav class="menu-secundario">
            <ul>
                <li><a href="home.jsp">Inicio</a></li>
                <li><a href="nosotros.html">Sobre Nosotros</a></li>
                <li><a href="consultas.html">Consultas</a></li>
                <li><a href="registro.html">Registro</a></li>
            </ul>
        </nav>

        <!-- Derechos -->
        <p>&copy; 2025 ELITE FASHION. Todos los derechos reservados.</p>

        <!-- Logout -->
        <a href="login.html" class="logout">Cerrar sesión</a>
    </footer>
    <script src="../JS/pedido.js"></script>
</body>
</html>