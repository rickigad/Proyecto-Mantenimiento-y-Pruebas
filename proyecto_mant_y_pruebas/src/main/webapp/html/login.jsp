<%@ page import="java.sql.*" %>

<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<% 
String errorMsg = null;   

	if ("POST".equalsIgnoreCase(request.getMethod())){
		String password = request.getParameter("password");
		String user = request.getParameter("login");
		
		if(user != null && password != null){
			try {
	            Class.forName("com.mysql.cj.jdbc.Driver");
	            Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
	            String sql = "SELECT * FROM usuario WHERE user = ? AND password = ?";
	            PreparedStatement ps = con.prepareStatement(sql);
	            ps.setString(1, user);
	            ps.setString(2, password);
	            
	            ResultSet rs = ps.executeQuery();
	            
	            if(rs.next()){
	            	// Guardar datos del usuario en sesión
	                HttpSession session_user = request.getSession();
	                session_user.setAttribute("admin", rs.getInt("admin")); 

	                // Redirigir siempre al mismo JSP
	                response.sendRedirect("home.jsp");
	            }
	            else{
	    			errorMsg ="usuario o contraseña incorrectos";
	    		}
	         
	        } catch (Exception e) {
	            errorMsg = "Error: " + e.getMessage();
	        }
		}
	}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesion</title>
    <link rel="stylesheet" href="../css/login.css">
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1 class="login-title">Iniciar Sesion</h1>
            <p class="login-subtitle">Ingresa tus credenciales para continuar</p>
        </div>
        
        <% if (errorMsg != null) { %>
        <p style="color:red;"><%= errorMsg %></p>
    	<% } %>
        
        <form id="loginForm" action="login.jsp" method="post">
            <div class="form-group">
                <label for="login">Usuario</label>
                <input type="text" id="login" name="login" required>
            </div>
            
            <div class="form-group">
                <label for="password">Contraseña</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <div class="form-options">
                <label>
                    <input type="checkbox" id="remember"> Recordarme
                </label>
                <a href="#" id="forgotPassword">¿Olvidaste tu contraseña?</a>
            </div>
            
            <button type="submit" class="login-btn" >Iniciar Sesion</button>
        </form>
        
        <div class="login-footer">
            <p>¿No tienes cuenta? <a href="registro.jsp">Registrate aqui</a></p>
        </div>
    </div>
</body>
</html>