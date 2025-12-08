<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="java.util.Calendar" %>

<%
Integer admin = (Integer) session.getAttribute("admin");
if (admin == null) admin = 0;


int totalClientes = 0;
int clientesActivos = 0;
int nuevosEsteMes = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");

    // Total clientes
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM cliente");
    if(rs.next()){
        totalClientes = rs.getInt(1);
    }
    rs.close();

    // Clientes activos
    rs = st.executeQuery("SELECT COUNT(*) FROM cliente WHERE activo = 1");
    if(rs.next()){
        clientesActivos = rs.getInt(1);
    }
    rs.close();

    // Nuevos este mes
    Calendar cal = Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int month = cal.get(Calendar.MONTH) + 1; // enero = 0

    String sqlNuevosMes = "SELECT COUNT(*) FROM cliente WHERE YEAR(fecha_creacion) = ? AND MONTH(fecha_creacion) = ?";
    PreparedStatement ps = con.prepareStatement(sqlNuevosMes);
    ps.setInt(1, year);
    ps.setInt(2, month);
    rs = ps.executeQuery();
    if(rs.next()){
        nuevosEsteMes = rs.getInt(1);
    }
    rs.close();
    ps.close();

    st.close();
    con.close();

} catch(Exception e) {
    // manejar error o mostrar mensaje
}

String mensaje = null;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    // Conexión
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");

    // Si se está actualizando el estado activo/inactivo
    if (request.getParameter("toggleActivo") != null) {
        String idStr = request.getParameter("id");
        String activoStr = request.getParameter("activo");
        int activo = (activoStr != null) ? 1 : 0;

        try {
            PreparedStatement ps = con.prepareStatement("UPDATE cliente SET activo = ? WHERE id = ?");
            ps.setInt(1, activo);
            ps.setInt(2, Integer.parseInt(idStr));
            ps.executeUpdate();
            ps.close();

         	// Redirigir para evitar resubmission
            con.close();
            response.sendRedirect("cliente.jsp");
            return;

        } catch (Exception e) {
            mensaje = "Error al actualizar estado: " + e.getMessage();
        }
    } else {
        // Inserción nuevo cliente
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String correo = request.getParameter("correo");
        String direccion = request.getParameter("direccion");
        String telefonoStr = request.getParameter("telefono");
        String cedula = request.getParameter("cedula");

        // Por defecto activo = 1
        int activo = 1;
        String activoStr = request.getParameter("activo");
        if (activoStr != null && activoStr.equals("on")) {
            activo = 1;
        }

        try {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO cliente (nombre, apellido, correo, direccion, telefono, activo,cedula) VALUES (?, ?, ?, ?, ?, ?,?)"
            );
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, correo);
            ps.setString(4, direccion);
            ps.setInt(5, Integer.parseInt(telefonoStr));
            ps.setInt(6, activo);
            ps.setString(7,cedula);

            int filas = ps.executeUpdate();

            if (filas > 0) {
                mensaje = "Cliente guardado exitosamente.";
            } else {
                mensaje = "No se pudo guardar el cliente.";
            }

            ps.close();
            con.close();

            // Redirigir para evitar reenvío al refrescar
            response.sendRedirect("cliente.jsp");
            return;

        } catch (Exception e) {
            mensaje = "Error al insertar cliente: " + e.getMessage();
        }
    }
}

// Obtener lista de clientes para mostrar
List<String[]> clientes = new ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT * FROM cliente");

    while (rs.next()) {
        String[] fila = new String[8];
        fila[0] = String.valueOf(rs.getInt("id"));
        fila[1] = rs.getString("cedula");
        fila[2] = rs.getString("nombre");
        fila[3] = rs.getString("apellido");
        fila[4] = rs.getString("correo");
        fila[5] = rs.getString("direccion");
        fila[6] = String.valueOf(rs.getInt("telefono"));
        fila[7] = (rs.getInt("activo") == 1) ? "Activo" : "Inactivo";
        clientes.add(fila);
    }
    rs.close();
    stmt.close();
    con.close();

} catch (Exception e) {
    mensaje = "Error al obtener clientes: " + e.getMessage();
}
%>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clientes - ELITE FASHION</title>
    <link rel="stylesheet" href="../css/clientes.css">
    <link rel="stylesheet" href="../css/home.css">
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

    <!-- CONTENIDO PRINCIPAL -->
    <main class="container">
	    <section class="seccion">
	        <h2 class="titulo-seccion">Gestión de Clientes</h2>
	
	        <div class="stats-rapidas">
			    <div class="stat-card">
			        <div class="stat-value" id="totalClientes"><%= totalClientes %></div>
			        <div class="stat-label">Total Clientes</div>
			    </div>
			    <div class="stat-card">
			        <div class="stat-value" id="clientesActivos"><%= clientesActivos %></div>
			        <div class="stat-label">Clientes Activos</div>
			    </div>
			    <div class="stat-card">
			        <div class="stat-value" id="nuevosEstesMes"><%= nuevosEsteMes %></div>
			        <div class="stat-label">Nuevos Este Mes</div>
			    </div>
			</div>
	
	        <div class="controles">
	            <button class="btn-primario" onclick="abrirModal()">+ Nuevo Cliente</button>
	            <div class="filtros">
	                <input type="text" id="buscarCliente" placeholder="Buscar por ID, nombre, cedula, correo, direccion o telefono..." style="width: 400px;">
	                <select id="filtroEstado">
	                    <option value="">Todos los estados</option>
	                    <option value="activo">Activos</option>
	                    <option value="inactivo">Inactivos</option>
	                </select>
	            </div>
	        </div>
	
	        <div class="tabla-container">
	            <table class="tabla-clientes" id="tablaClientes">
				    <thead>
				        <tr>
				            <th>ID</th>
				            <th>Cedula</th>
				            <th>Nombre Completo</th>
				            <th>Correo</th>
				            <th>Dirección</th>
				            <th>Teléfono</th>
				            <th>Estado</th>
				            <th>Cambiar estado</th>
				        </tr>
				    </thead>
				    <tbody id="cuerpoTabla">
				        <%
				            for (String[] c : clientes) {
				        %>
				        <tr>
				            <td><%= c[0] %></td>
				            <td><%= c[1] %></td>
				            <td><%= c[2] %> <%= c[3] %></td>
				            <td><%= c[4] %></td>
				            <td><%= c[5] %></td>
				            <td><%= c[6] %></td>
				            <td><%= c[7] %></td>
				            <td>
				                <form method="post" action="cliente.jsp" style="display:inline;">
				                    <input type="hidden" name="id" value="<%= c[0] %>">
				                    <input type="hidden" name="toggleActivo" value="true">
				                    <input type="checkbox" name="activo" onchange="this.form.submit()" <%= "Activo".equals(c[7]) ? "checked" : "" %> >
				                </form>
				            </td>
				        </tr>
				        <%
				            }
				        %>
				    </tbody>
				</table>
	        </div>
	    </section>
	</main>
	
    <!-- MODAL NUEVO CLIENTE -->
    <div id="modalCliente" class="modal">
        <div class="modal-content">
            <span class="close" onclick="cerrarModal()">&times;</span>
            <h2 id="tituloModal">Nuevo Cliente</h2>
            <form id="formCliente" method="post">
                <div class="form-row">
                    <div class="form-grupo">
                        <label for="cedula">Cédula *</label>
                        <input type="text" id="cedula" name="cedula" required>
                    </div>
                    <div class="form-grupo">
                        <label for="telefono">Teléfono *</label>
                        <input type="tel" id="telefono" name="telefono" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-grupo">
                        <label for="nombre">Nombre *</label>
                        <input type="text" id="nombre" name="nombre" required>
                    </div>
                    <div class="form-grupo">
                        <label for="apellido">Apellido *</label>
                        <input type="text" id="apellido" name="apellido" required>
                    </div>
                </div>

                <div class="form-grupo">
                    <label for="correo">Correo Electrónico *</label>
                    <input type="email" id="correo" name="correo" required>
                </div>

                <div class="form-grupo">
                    <label for="direccion">Dirección *</label>
                    <textarea id="direccion" name="direccion" rows="3" required></textarea>
                </div>

                <div class="form-botones">
                    <button type="button" class="btn-cancelar" onclick="cerrarModal()">Cancelar</button>
                    <button type="submit" class="btn-primario">Guardar Cliente</button>
                </div>
            </form>
        </div>
    </div>

    <!-- PIE DE PÁGINA -->
    <footer>
        <nav class="menu-secundario">
            <ul>
                <li><a href="home.jsp">Inicio</a></li>
                <li><a href="nosotros.jsp">Sobre Nosotros</a></li>
                <li><a href="consultas.jsp">Consultas</a></li>
                <li><a href="registro.jsp">Registro</a></li>
            </ul>
        </nav>
        <p>&copy; 2025 ELITE FASHION. Todos los derechos reservados.</p>
        <a href="login.jsp" class="logout">Cerrar sesión</a>
    </footer>
    
    <script src="../JS/cliente.js"></script>
</body>
</html>