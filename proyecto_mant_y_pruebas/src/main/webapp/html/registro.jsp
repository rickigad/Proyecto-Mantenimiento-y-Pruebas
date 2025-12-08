<%@ page import="java.sql.*" %>

<%@ page contentType="text/html; charset=UTF-8" language="java" %>



<%
String errorMsg = null;    
String successMsg = null;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    String phone = request.getParameter("phone");
    String birthdate = request.getParameter("birthdate");
    String terms = request.getParameter("terms"); 
    String newsletter = request.getParameter("newsletter");

    if (!password.equals(confirmPassword)) {
        errorMsg = "Las contraseñas no coinciden.";
    } else if (terms == null) {
        errorMsg = "Debes aceptar los términos y condiciones.";
    } else {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");

            String sql = "INSERT INTO usuario (user, password, Nombre, Apellido, email, telefono, fechanac) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, username);      
            ps.setString(2, password);      
            ps.setString(3, firstName);     
            ps.setString(4, lastName);      
            ps.setString(5, email);        
            
            if (phone == null || phone.isEmpty()) {
                ps.setNull(6, java.sql.Types.INTEGER);
            } else {
                ps.setInt(6, Integer.parseInt(phone));
            }
            
            ps.setDate(7, java.sql.Date.valueOf(birthdate)); 
            
            HttpSession session_user = request.getSession();
            session_user.setAttribute("admin", 0); 

            ps.executeUpdate();
            con.close();
            response.sendRedirect("home.jsp");
            return;
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
    <title>Crear Cuenta</title>
    <link rel="stylesheet" href="../css/registro.css">
</head>
<body>
    <div class="register-container">
        <div class="register-header">
            <h1 class="register-title">Crear Cuenta</h1>
            <p class="register-subtitle">Completa el formulario para registrarte</p>
        </div>
        
        <% if (errorMsg != null) { %>
        <p style="color:red;"><%= errorMsg %></p>
    	<% } %>

        <form id="registerForm" action=registro.jsp method="post">
           
            <div class="form-group">
                <label for="firstName">Nombre</label>
                <input type="text" id="firstName" name="firstName" required>
            </div>

            <div class="form-group">
                <label for="lastName">Apellido</label>
                <input type="text" id="lastName" name="lastName" required>
            </div>
             
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label for="username">Usuario</label>
                <input type="text" id="username" name="username" required>
            </div>
            
            <div class="form-group">
                <label for="password">Contraseña</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">Confirmar Contraseña</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required>
            </div>
            
            <div class="form-group">
                <label for="phone">Telefono (opcional)</label>
                <input type="tel" id="phone" name="phone">
            </div>
            
            <div class="form-group">
                <label for="birthdate">Fecha de Nacimiento</label>
                <input type="date" id="birthdate" name="birthdate" required>
            </div>
            
            <div class="checkbox-group">
                <input type="checkbox" id="terms" name="terms" required>
                <label for="terms">Acepto los <a href="#">terminos y condiciones</a></label>
            </div>
            
            <div class="checkbox-group">
                <input type="checkbox" id="newsletter" name="newsletter">
                <label for="newsletter">Deseo recibir noticias y promociones</label>
            </div>
            
            <button type="submit" class="register-btn">Crear Cuenta</button>
        </form>
        
        <div class="register-footer">
            <p>¿Ya tienes cuenta? <a href="login.jsp">Inicia sesion aqui</a></p>
        </div>
    </div>
</body>
</html>