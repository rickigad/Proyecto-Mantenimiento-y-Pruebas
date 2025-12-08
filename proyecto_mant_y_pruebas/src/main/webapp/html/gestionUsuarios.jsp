<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="java.util.Calendar" %>

<%
Integer admin = (Integer) session.getAttribute("admin");
if (admin == null) admin = 0;

// PROCESAR FORMULARIO DE NUEVO USUARIO
String mensaje = "";
String tipoMensaje = "";

if (request.getMethod().equals("POST") && request.getParameter("user") != null) {
    String user = request.getParameter("user");
    String password = request.getParameter("password");
    String nombre = request.getParameter("nombre");
    String apellido = request.getParameter("apellido");
    String email = request.getParameter("email");
    String telefono = request.getParameter("telefono");
    String fechanac = request.getParameter("fechanac");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
        
        String sql = "INSERT INTO usuario (user, password, nombre, apellido, email, telefono, fechanac, admin) VALUES (?, ?, ?, ?, ?, ?, ?, 0)";
        PreparedStatement stmt = con.prepareStatement(sql);
        stmt.setString(1, user);
        stmt.setString(2, password);
        stmt.setString(3, nombre);
        stmt.setString(4, apellido);
        stmt.setString(5, email);
        stmt.setString(6, telefono);
        stmt.setString(7, fechanac);
        
        int result = stmt.executeUpdate();
        
        stmt.close();
        con.close();
        
        if (result > 0) {
            mensaje = "Usuario guardado exitosamente";
            tipoMensaje = "success";
        } else {
            mensaje = "Error al guardar el usuario";
            tipoMensaje = "error";
        }
    } catch (Exception e) {
        mensaje = "Error: " + e.getMessage();
        tipoMensaje = "error";
    }
}

// CONSULTAR USUARIOS EXISTENTES
List<String[]> usuarios = new ArrayList<>();
try{
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT id, nombre, apellido, email, telefono, fechanac FROM usuario WHERE admin = 0");
    
    while(rs.next()){
        String[] fila = new String[6];
        fila[0] = String.valueOf(rs.getInt("id"));
        fila[1] = rs.getString("nombre");
        fila[2] = rs.getString("apellido");
        fila[3] = rs.getString("email");
        fila[4] = rs.getString("telefono");
        fila[5] = rs.getString("fechanac");
        usuarios.add(fila);     
    }
    
    rs.close();
    stmt.close();
    con.close();
    
}catch(Exception e){
    
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usuarios - ELITE FASHION</title>
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
	        <h2 class="titulo-seccion">Gestión de Usuarios</h2>
	
	        <div class="controles">
	            <button class="btn-primario" onclick="abrirModal()">+ Nuevo Usuario</button>
	            <div class="filtros">
	                <input type="text" id="buscarUsuario" placeholder="Buscar por ID, nombre, correo o telefono..." style="width: 400px;">
	            </div>
	        </div>
	
	        <div class="tabla-container">
	            <table class="tabla-clientes" id="tablaClientes">
				    <thead>
				        <tr>
				            <th>ID</th>
				            <th>Nombre</th>
				            <th>Apellido</th>
				            <th>email</th>
				            <th>telefono</th>
				            <th>Fecha de nacimiento</th>
				            <th>Cambiar datos</th>
				        </tr>
				    </thead>
				    <tbody id="cuerpoTabla">
				        <%
				            for (String[] c : usuarios) {
				        %>
				        <tr>
				            <td><%= c[0] %></td>
				            <td><%= c[1] %></td>
				            <td><%= c[2] %></td>
				            <td><%= c[3] %></td>
				            <td><%= c[4] %></td>
				            <td><%= c[5] %></td>
				            <td></td>
				        </tr>
				        <%
				            }
				        %>
				    </tbody>
				</table>
	        </div>
	    </section>
	</main>
	
    <!-- MODAL NUEVO USUARIO -->
	<div id="modalUsuario" class="modal">
	    <div class="modal-content">
	        <span class="close" onclick="cerrarModal()">&times;</span>
	        <h2 id="tituloModal">Nuevo Usuario</h2>
	        <form id="formUsuario" method="post" action="gestionUsuarios.jsp">
	            <div class="form-row">
	                <div class="form-grupo">
	                    <label for="user">Usuario *</label>
	                    <input type="text" id="user" name="user" required>
	                </div>
	                <div class="form-grupo">
	                    <label for="password">Contraseña *</label>
	                    <input type="password" id="password" name="password" required>
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
	
	            <div class="form-row">
	                <div class="form-grupo">
	                    <label for="email">Email *</label>
	                    <input type="email" id="email" name="email" required>
	                </div>
	                <div class="form-grupo">
	                    <label for="telefono">Teléfono *</label>
	                    <input type="tel" id="telefono" name="telefono" required>
	                </div>
	            </div>
	
	            <div class="form-grupo">
	                <label for="fechanac">Fecha de Nacimiento *</label>
	                <input type="date" id="fechanac" name="fechanac" required>
	            </div>
	
	            <div class="form-botones">
	                <button type="button" class="btn-cancelar" onclick="cerrarModal()">Cancelar</button>
	                <button type="submit" class="btn-primario">Guardar Usuario</button>
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
    
    <script src="../JS/gestionUsuario.js"></script>
</body>
</html>