<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.Map, java.util.HashMap" %>

<% 
Integer admin = (Integer) session.getAttribute("admin");
if (admin == null) admin = 0;

int totalProductos = 0;
double valorTotal = 0.0;
int totalClientes = 0;
int totalCategorias = 0;
double promedioPrecio = 0;
int totalStock = 0;
int clientesActivos = 0;
int clientesInactivos = 0;
int totalPedidos = 0;
double  montoTotalVentas = 0;
String productoMasVendido = "";

Map<String, Integer> pedidosPorEstado = new HashMap<>();
Map<String, Integer> productosPorCategoria = new HashMap<>();

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");

    // Total de productos
    String sqlProductos = "SELECT COUNT(*) FROM producto";
    PreparedStatement stmt1 = con.prepareStatement(sqlProductos);
    ResultSet rs1 = stmt1.executeQuery();
    if (rs1.next()) totalProductos = rs1.getInt(1);
    rs1.close();
    stmt1.close();
    
 	// Total de categorías registradas
    String sqlCategorias = "SELECT COUNT(*) FROM categoria";
    PreparedStatement stmtC1 = con.prepareStatement(sqlCategorias);
    ResultSet rsC1 = stmtC1.executeQuery();
    if (rsC1.next()) totalCategorias = rsC1.getInt(1);
    rsC1.close();
    stmtC1.close();
    
 	// Promedio de precio de los productos
    String sqlPromedioPrecio = "SELECT AVG(precio) FROM producto";
    PreparedStatement stmtP2 = con.prepareStatement(sqlPromedioPrecio);
    ResultSet rsP2 = stmtP2.executeQuery();
    if (rsP2.next()) promedioPrecio = rsP2.getDouble(1);
    rsP2.close();
    stmtP2.close();
    
 	// Total de stock general (sumatoria de unidades)
    String sqlStockTotal = "SELECT SUM(stock) FROM producto";
    PreparedStatement stmtP3 = con.prepareStatement(sqlStockTotal);
    ResultSet rsP3 = stmtP3.executeQuery();
    if (rsP3.next()) totalStock = rsP3.getInt(1);
    rsP3.close();
    stmtP3.close();

    // Valor total de productos (precio * stock)
    String sqlValor = "SELECT SUM(precio * stock) FROM producto";
    PreparedStatement stmt2 = con.prepareStatement(sqlValor);
    ResultSet rs2 = stmt2.executeQuery();
    if (rs2.next()) valorTotal = rs2.getDouble(1);
    rs2.close();
    stmt2.close();

    // Total de clientes
    String sqlClientes = "SELECT COUNT(*) FROM cliente";
    PreparedStatement stmt3 = con.prepareStatement(sqlClientes);
    ResultSet rs3 = stmt3.executeQuery();
    if (rs3.next()) totalClientes = rs3.getInt(1);
    rs3.close();
    stmt3.close();
    
 	// Total de clientes activos
    String sqlClientesActivos = "SELECT COUNT(*) FROM cliente WHERE activo = 1";
    PreparedStatement stmtCl1 = con.prepareStatement(sqlClientesActivos);
    ResultSet rsCl1 = stmtCl1.executeQuery();
    if (rsCl1.next()) clientesActivos = rsCl1.getInt(1);
    rsCl1.close();
    stmtCl1.close();
    
 	// Total de clientes inactivos
    String sqlClientesInactivos = "SELECT COUNT(*) FROM cliente WHERE activo = 0";
    PreparedStatement stmtCl2 = con.prepareStatement(sqlClientesInactivos);
    ResultSet rsCl2 = stmtCl2.executeQuery();
    if (rsCl2.next()) clientesInactivos = rsCl2.getInt(1);
    rsCl2.close();
    stmtCl2.close();
    
 	// Total de pedidos
    String sqlPedidos = "SELECT COUNT(*) FROM pedido";
    PreparedStatement stmtPe1 = con.prepareStatement(sqlPedidos);
    ResultSet rsPe1 = stmtPe1.executeQuery();
    if (rsPe1.next()) totalPedidos = rsPe1.getInt(1);
    rsPe1.close();
    stmtPe1.close();
    
 	// Total de monto generado en ventas
    String sqlMontoTotal = "SELECT SUM(monto) FROM pedido";
    PreparedStatement stmtPe2 = con.prepareStatement(sqlMontoTotal);
    ResultSet rsPe2 = stmtPe2.executeQuery();
    if (rsPe2.next()) montoTotalVentas = rsPe2.getDouble(1);
    rsPe2.close();
    stmtPe2.close();
    
 	// Producto más vendido
    String sqlMasVendido = "SELECT p.nombre, SUM(pe.cant) AS total_vendido FROM pedido pe JOIN producto p ON pe.id_prod = p.id GROUP BY p.nombre ORDER BY total_vendido DESC LIMIT 1";
    PreparedStatement stmtPe4 = con.prepareStatement(sqlMasVendido);
    ResultSet rsPe4 = stmtPe4.executeQuery();
    if (rsPe4.next()) productoMasVendido = rsPe4.getString(1);
    rsPe4.close();
    stmtPe4.close();
    
	 // Pedidos por estado (Pendiente, Enviado, Entregado, Cancelado, etc.) 
	 String sqlPorEstado = "SELECT estado, COUNT(*) FROM pedido GROUP BY estado"; 
	 PreparedStatement stmtPe3 = con.prepareStatement(sqlPorEstado); 
	 ResultSet rsPe3 = stmtPe3.executeQuery(); 
	 
	 while (rsPe3.next()) {
	     pedidosPorEstado.put(rsPe3.getString(1), rsPe3.getInt(2));
	 }
	 
	 rsPe3.close(); 
	 stmtPe3.close();
	 
	 // Total de productos por categoría 
	 String sqlProductosPorCat = "SELECT c.nombre, COUNT(p.id) FROM producto p JOIN categoria c ON p.categoria = c.id GROUP BY c.nombre"; 
	 PreparedStatement stmtP1 = con.prepareStatement(sqlProductosPorCat); 
	 ResultSet rsP1 = stmtP1.executeQuery(); 
	 
	 while (rsP1.next()) {
		    productosPorCategoria.put(rsP1.getString(1), rsP1.getInt(2));
	 }
	 
	 
	 
	 rsP1.close(); 
	 stmtP1.close();
    

    con.close();
} catch (Exception e) {
    out.println("Error al obtener estadísticas: " + e.getMessage());
}

DecimalFormat df = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HOME ELITE FASHION</title>
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
    
    <!-- CARTAS INFORMATIVAS -->
    <section id="home" class="seccion">
	    <h2 class="titulo-seccion">Panel Principal</h2>
	
	    <div class="dashboard-cards">
	        <!-- Productos -->
	        <div class="card">
	            <div class="card-value"><%= totalProductos %></div>
	            <div class="card-label">Total de Productos</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value">$<%= df.format(valorTotal) %></div>
	            <div class="card-label">Valor Total en Inventario</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value"><%= totalCategorias %></div>
	            <div class="card-label">Total de Categorías</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value"><%= df.format(promedioPrecio) %></div>
	            <div class="card-label">Precio Promedio de Productos</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value"><%= totalStock %></div>
	            <div class="card-label">Unidades en Stock</div>
	        </div>
	
	        <!-- Clientes -->
	        <div class="card">
	            <div class="card-value"><%= totalClientes %></div>
	            <div class="card-label">Total de Clientes</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value"><%= clientesActivos %></div>
	            <div class="card-label">Clientes Activos</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value"><%= clientesInactivos %></div>
	            <div class="card-label">Clientes Inactivos</div>
	        </div>
	
	        <!-- Pedidos -->
	        <div class="card">
	            <div class="card-value"><%= totalPedidos %></div>
	            <div class="card-label">Total de Pedidos</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value">$<%= df.format(montoTotalVentas) %></div>
	            <div class="card-label">Monto Total en Ventas</div>
	        </div>
	
	        <div class="card">
	            <div class="card-value"><%= productoMasVendido %></div>
	            <div class="card-label">Producto Más Vendido</div>
	        </div>
	    </div>
	    <button id="descargarPDF" class="logout"
		    data-total-productos="<%= totalProductos %>"
		    data-valor-total="<%= valorTotal %>"
		    data-total-clientes="<%= totalClientes %>"
		    data-promedio-precio="<%= promedioPrecio %>"
		    data-total-stock="<%= totalStock %>"
		    data-clientes-activos="<%= clientesActivos %>"
		    data-clientes-inactivos="<%= clientesInactivos %>"
		    data-total-pedidos="<%= totalPedidos %>"
		    data-monto-total="<%= montoTotalVentas %>"
		    data-producto-mas-vendido="<%= productoMasVendido %>"
		    data-total-categorias="<%= totalCategorias %>"
		>Generar PDF</button>
	</section>

    
    <!-- PIE DE PÁGINA -->
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
        <a href="login.jsp" class="logout">Cerrar sesión</a>
    </footer>


<canvas id="graficaPedidos" width="400" height="200" style="position:absolute; left:-9999px;"></canvas>
<canvas id="graficaProductosCat" width="400" height="200" style="position:absolute; left:-9999px;"></canvas>
<script>
    const pedidosPorEstado = {
        <% 
            int i = 0;
            for(Map.Entry<String, Integer> entry : pedidosPorEstado.entrySet()) {
                out.print("\"" + entry.getKey() + "\":" + entry.getValue());
                if(i < pedidosPorEstado.size() - 1) out.print(",");
                i++;
            }
        %>
    };

    const productosPorCategoria = {
        <% 
            int j = 0;
            for(Map.Entry<String, Integer> entry : productosPorCategoria.entrySet()) {
                out.print("\"" + entry.getKey() + "\":" + entry.getValue());
                if(j < productosPorCategoria.size() - 1) out.print(",");
                j++;
            }
        %>
    };
</script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
<script src="../JS/home.js"></script>
</body>
</html>