<% 
Integer admin = (Integer) session.getAttribute("admin");
if (admin == null) admin = 0;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sobre Nosotros - Elite Fashion</title>
    <link rel="stylesheet" href="../css/nosotros.css">
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
                <li><a href="gestionUsuarios.jsp">Gesti�n de Usuarios</a></li>
                <li><a href="proveedores.jsp">Proveedores</a></li>
            	<% } %>
	        </ul>
	    </nav>
	</header>
    
    <main>
        <h1>Nuestro Equipo</h1>
        
        <div class="equipo">
            <div class="miembro">
                <img src="../imagenes/diego.jpg" alt="Diego Jaimes">
                <div class="info">
                    <h3>Diego Jaimes</h3>
                    <p><strong>ID:</strong> 20-14-7829</p>
                    <p><strong>Rol:</strong> Ingeniero de Software</p>
                    <p>Desarrollador backend.</p>
                </div>
            </div>
            
            <div class="miembro">
                <img src="../imagenes/jose sierra.jpg" alt="José Sierra">
                <div class="info">
                    <h3>José Sierra</h3>
                    <p><strong>ID:</strong> 8-1013-523</p>
                    <p><strong>Rol:</strong> Ingeniero de Software</p>
                    <p>Especialista en desarrollo backend y bases de datos.</p>
                </div>
            </div>
            
            <div class="miembro">
                <img src="../imagenes/Ricardo.jpg" alt="Ricardo">
                <div class="info">
                    <h3>Ricardo Solís</h3>
                    <p><strong>ID:</strong> 4-828-646</p>
                    <p><strong>Rol:</strong> Ingeniero de Software</p>
                    <p>Desarrollador full-stack con experiencia en tecnologías web modernas.</p>
                </div>
            </div>
            <div class="miembro">
                <img src="../imagenes/louis.jpg" alt="Ricardo">
                <div class="info">
                    <h3>Louis Wiltshire</h3>
                    <p><strong>ID:</strong> 3-756-1538</p>
                    <p><strong>Rol:</strong> Ingeniero de Software</p>
                    <p>Desarrollador full-stack con experiencia en tecnologías web modernas.</p>
                </div>
            </div>            
            <div class="miembro">
                <img src="../imagenes/madeleine.jpg" alt="Madeleine Velásquez">
                <div class="info">
                    <h3>Madeleine Velásquez</h3>
                    <p><strong>ID:</strong> 8-1015-1772</p>
                    <p><strong>Rol:</strong> Ingeniera de Software</p>
                    <p>Estudiante de Ingeniería de Software con conocimientos en desarrollo web front-end utilizando HTML, CSS y JSP.</p>
                </div>
            </div>
        </div>
    </main>
    
    <footer>
        <!-- Menú secundario -->
        <nav class="menu-secundario">
            <ul>
                <li><a href="home.html">Inicio</a></li>
                <li><a href="nosotros.html">Sobre Nosotros</a></li>
                <li><a href="consultas.html">Consultas</a></li>
                <li><a href="registro.html">Registro</a></li>
            </ul>
        </nav>
        
        <!-- Derechos -->
        <p>&copy; 2025 Elite Fashion. Todos los derechos reservados.</p>
        
        <!-- Logout -->
        <a href="login.html" class="logout">Cerrar sesión</a>
    </footer>
</body>
</html>