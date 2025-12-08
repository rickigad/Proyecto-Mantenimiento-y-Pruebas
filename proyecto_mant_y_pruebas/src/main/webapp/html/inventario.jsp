<%@ page import="java.sql.*" %>
<%@ page import="java.util.List, java.util.ArrayList" %>

<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<%
Integer admin = (Integer) session.getAttribute("admin");
if (admin == null) admin = 0;


String errorMsg = null;
String successMsg = null;

// Procesamiento POST
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String newCategoryName = request.getParameter("newCategoryName");
    String nombre = request.getParameter("nombre");
    String updateStockProductId = request.getParameter("updateStockProductId");
    String addStockAmount = request.getParameter("addStockAmount");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");

        // Actualizar stock de producto existente
        if (updateStockProductId != null && addStockAmount != null && 
            !updateStockProductId.trim().isEmpty() && !addStockAmount.trim().isEmpty()) {
            
            int productId = Integer.parseInt(updateStockProductId);
            int stockToAdd = Integer.parseInt(addStockAmount);
            
            if (stockToAdd > 0) {
                String sql = "UPDATE producto SET stock = stock + ? WHERE id = ?";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, stockToAdd);
                ps.setInt(2, productId);
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    successMsg = "Stock actualizado correctamente. Se agregaron " + stockToAdd + " unidades.";
                } else {
                    errorMsg = "Error al actualizar el stock del producto.";
                }
                ps.close();
            } else {
                errorMsg = "La cantidad a agregar debe ser mayor a 0.";
            }

        } else if (newCategoryName != null && !newCategoryName.trim().isEmpty()) {
            // Insertar categoría
            String sql = "INSERT INTO categoria (nombre) VALUES (?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, newCategoryName.trim());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                successMsg = "Categoría agregada correctamente.";
            } else {
                errorMsg = "Error al agregar la categoría.";
            }
            ps.close();

        } else if (nombre != null) {
            // Insertar producto
            String categoriaStr = request.getParameter("categoria");
            String marca = request.getParameter("marca");
            String color = request.getParameter("color");
            String talla = request.getParameter("talla");
            String precioStr = request.getParameter("precio");
            String stockStr = request.getParameter("stock");

            if (nombre != null && categoriaStr != null && precioStr != null && stockStr != null &&
                !nombre.isEmpty() && !categoriaStr.isEmpty() && !precioStr.isEmpty() && !stockStr.isEmpty()) {

                int categoria = Integer.parseInt(categoriaStr);
                double precio = Double.parseDouble(precioStr);
                int stock = Integer.parseInt(stockStr);

                if (precio > 0 && stock >= 0) {
                    String sql = "INSERT INTO producto (nombre, categoria, marca, color, talla, precio, stock) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement ps = con.prepareStatement(sql);

                    ps.setString(1, nombre);
                    ps.setInt(2, categoria);
                    ps.setString(3, marca);
                    ps.setString(4, color);
                    ps.setString(5, talla);
                    ps.setDouble(6, precio);
                    ps.setInt(7, stock);

                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        successMsg = "Producto agregado correctamente.";
                    } else {
                        errorMsg = "Error al agregar el producto.";
                    }

                    ps.close();
                } else {
                    errorMsg = "Precio debe ser > 0 y stock ≥ 0.";
                }

            } else {
                errorMsg = "Complete todos los campos obligatorios.";
            }
        }

        con.close();

    } catch (NumberFormatException e) {
        errorMsg = "Error: Formato de número inválido.";
        e.printStackTrace();
    } catch (Exception e) {
        errorMsg = "Error: " + e.getMessage();
        e.printStackTrace();
    }

    // Redirección para evitar reenvío de formulario
    if (successMsg != null) {
        session.setAttribute("successMsg", successMsg);
    }
    if (errorMsg != null) {
        session.setAttribute("errorMsg", errorMsg);
    }

    response.sendRedirect("inventario.jsp");
    return;
}

// Recuperar mensajes de la sesión
successMsg = (String) session.getAttribute("successMsg");
errorMsg = (String) session.getAttribute("errorMsg");
session.removeAttribute("successMsg");
session.removeAttribute("errorMsg");

// Variables de estadísticas
int totalProducts = 0;
int lowStockProducts = 0;
int outOfStockProducts = 0;
int totalCategories = 0;

try (
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
    Statement stmt = con.createStatement()
) {
    Class.forName("com.mysql.cj.jdbc.Driver");

    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM producto");
    if (rs.next()) totalProducts = rs.getInt(1);
    rs.close();

    rs = stmt.executeQuery("SELECT COUNT(*) FROM producto WHERE stock <= 20 AND stock > 0");
    if (rs.next()) lowStockProducts = rs.getInt(1);
    rs.close();

    rs = stmt.executeQuery("SELECT COUNT(*) FROM producto WHERE stock = 0");
    if (rs.next()) outOfStockProducts = rs.getInt(1);
    rs.close();

    rs = stmt.executeQuery("SELECT COUNT(*) FROM categoria");
    if (rs.next()) totalCategories = rs.getInt(1);
    rs.close();

} catch (Exception e) {
    e.printStackTrace();
    errorMsg = "Error cargando estadísticas: " + e.getMessage();
}

List<String> categoriasList = new ArrayList<>();
List<String> idcatList = new ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT id, nombre FROM categoria ORDER BY nombre");
    while (rs.next()) {
        categoriasList.add(rs.getString("nombre"));
        idcatList.add(String.valueOf(rs.getInt("id"))); 
    }
    rs.close();
    stmt.close();
    con.close();
} catch (Exception e) {
    errorMsg = "Error cargando categorías: " + e.getMessage();
}

List<String[]> productosList = new ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/tienda", "root", "");
    Statement stmt = con.createStatement();
    // Suponiendo que categoria es un join con la tabla categoria para obtener nombre de categoría
    String sql = "SELECT p.id, p.nombre, c.nombre AS categoria, p.marca, p.color, p.talla, p.precio, p.stock " +
                 "FROM producto p JOIN categoria c ON p.categoria = c.id ORDER BY p.id";
    ResultSet rs = stmt.executeQuery(sql);

    while (rs.next()) { 	
    	String[] fila = new String[8];
    	fila[0] = String.valueOf(rs.getInt("id"));
        fila[1] = rs.getString("nombre");
        fila[2] = rs.getString("categoria");
        fila[3] = rs.getString("marca");
        fila[4] = rs.getString("color");
        fila[5] = rs.getString("talla");
        fila[6] = String.valueOf(rs.getDouble("precio"));
        fila[7] = String.valueOf(rs.getInt("stock"));
    	productosList.add(fila);
    }
    rs.close();
    stmt.close();
    con.close();
} catch (Exception e) {
    out.println("Error cargando productos: " + e.getMessage());
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema de Inventario - Elite Fashion</title>
    <link rel="stylesheet" href="../css/inventario.css">
    <link rel="stylesheet" href="../css/home.css">

</head>
<body>
	<% if (errorMsg != null) { %>
        <p style="color:red; background: #f8d7da; border: 1px solid #f5c6cb; padding: 10px; border-radius: 5px; margin: 10px;"><%= errorMsg %></p>
    <% } %>
    
    <% if (successMsg != null) { %>
        <p style="color:#155724; background: #d4edda; border: 1px solid #c3e6cb; padding: 10px; border-radius: 5px; margin: 10px;"><%= successMsg %></p>
    <% } %>

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
		<section class="seccion">
	        <!-- TITULO -->
	        <div class="titulo">
	            <h1>Gestion de Inventario</h1>
	            <p>Controla productos, stock y categorias de Elite Fashion</p>
	        </div>
	
	
	        <!-- Estadisticas -->
		    <div class="stats-grid">
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <p class="stat-label">Total Productos</p>
			                <p class="stat-value" id="totalProducts"><%= totalProducts %></p>
			            </div>
			            <i class="fas fa-tshirt stat-icon blue"></i>
			        </div>
			    </div>
			
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <p class="stat-label">Stock Bajo</p>
			                <p class="stat-value yellow" id="lowStockProducts"><%= lowStockProducts %></p>
			            </div>
			            <i class="fas fa-exclamation-triangle stat-icon yellow"></i>
			        </div>
			    </div>
			
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <p class="stat-label">Sin Stock</p>
			                <p class="stat-value red" id="outOfStockProducts"><%= outOfStockProducts %></p>
			            </div>
			            <i class="fas fa-times-circle stat-icon red"></i>
			        </div>
			    </div>
			
			    <div class="stat-card">
			        <div class="stat-content">
			            <div class="stat-info">
			                <p class="stat-label">Categorías</p>
			                <p class="stat-value green" id="totalCategories"><%= totalCategories %></p>
			            </div>
			            <i class="fas fa-tags stat-icon green"></i>
			        </div>
			    </div>
			</div>
	
	        <!-- Controles -->
	        <div class="controls">
	            <div class="controls-left">
	                <div class="search-box">
	                    <i class="fas fa-search"></i>
	                    <input type="text" id="searchInput" placeholder="Buscar por nombre, marca o color...">
	                </div>
	                
	                <div class="filter-box">
					    <i class="fas fa-filter"></i>
					    <select id="categoryFilter" name="categoryFilter">
					        <option value="">Todas las categorias</option>
					        <%
					            for (String cat : categoriasList) {
					        %>
					            <option value="<%= cat %>"><%= cat %></option>
					        <%
					            }
					        %>
					    </select>
					</div>
	            </div>
	            
	            <div class="controls-right">
	                <button class="btn btn-secondary" id="manageCategoriesBtn">
	                    <i class="fas fa-tags"></i>
	                    Gestionar Categorias
	                </button>
	                <button class="btn btn-primary" id="addProductBtn">
	                    <i class="fas fa-plus"></i>
	                    Nuevo Producto
	                </button>
	            </div>
	        </div>
	
	        <!-- Tabla de productos -->
	        <div class="table-container">
			    <table class="products-table">
			        <thead>
			            <tr>
			                <th>ID</th>
			                <th>Producto</th>
			                <th>Categoria</th>
			                <th>Marca</th>
			                <th>Color</th>
			                <th>Talla</th>
			                <th>Precio</th>
			                <th>Stock</th>
			            </tr>
			        </thead>
			        <tbody id="productsTableBody">
			            <%
			                if (productosList != null && !productosList.isEmpty()) {
			                    for (String[] producto : productosList) {
			                        // producto[0] = id, [1] = nombre, [2] = categoria, [3] = marca, 
			                        // [4] = color, [5] = talla, [6] = precio, [7] = stock
			                        
			                        // Determinar clase de stock para styling
			                        String stockClass = "";
			                        int stock = Integer.parseInt(producto[7]);
			                        if (stock == 0) {
			                            stockClass = "out-of-stock";
			                        } else if (stock <= 20) {
			                            stockClass = "low-stock";
			                        }
			            %>
			                <tr>
			                    <td><%= producto[0] %></td>
			                    <td class="product-name"><%= producto[1] %></td>
			                    <td><span class="category-badge"><%= producto[2] %></span></td>
			                    <td><%= producto[3] != null ? producto[3] : "N/A" %></td>
			                    <td><%= producto[4] != null ? producto[4] : "N/A" %></td>
			                    <td><%= producto[5] != null ? producto[5] : "N/A" %></td>
			                    <td class="price">$<%= String.format("%.2f", Double.parseDouble(producto[6])) %></td>
			                    <td class="stock <%= stockClass %>">
			                        <div class="stock-cell">
			                            <span class="stock-value"><%= producto[7] %></span>
			                            <div class="stock-actions">
			                                <button type="button" class="add-stock-btn" onclick="showStockForm(<%= producto[0] %>)">
			                                    +
			                                </button>
			                            </div>
			                            <form class="stock-form" id="stockForm<%= producto[0] %>" method="post" action="inventario.jsp">
			                                <input type="hidden" name="updateStockProductId" value="<%= producto[0] %>">
			                                <input type="number" name="addStockAmount" class="stock-input" min="1" max="999" placeholder="+" required>
			                                <button type="submit" class="confirm-btn">✓</button>
			                                <button type="button" class="cancel-btn" onclick="hideStockForm(<%= producto[0] %>)">✗</button>
			                            </form>
			                        </div>
			                    </td>
			                </tr>
			            <%
			                    }
			                } else {
			            %>
			                <tr>
			                    <td colspan="8" class="no-data">
			                        <div class="empty-state-inline">
			                            <i class="fas fa-tshirt"></i>
			                            <p>No hay productos registrados</p>
			                        </div>
			                    </td>
			                </tr>
			            <%
			                }
			            %>
			        </tbody>
			    </table>
			    
			    <!-- Estado vacío (se muestra cuando no hay productos) -->
			    <div class="empty-state" id="emptyState" style="<%= (productosList == null || productosList.isEmpty()) ? "display: block;" : "display: none;" %>">
			        <i class="fas fa-tshirt"></i>
			        <h3>No hay productos disponibles</h3>
			        <p>Comienza agregando tu primer producto al inventario</p>
			        <button class="btn btn-primary" onclick="document.getElementById('addProductBtn').click()">
			            <i class="fas fa-plus"></i>
			            Agregar Producto
			        </button>
			    </div>
			</div>
		</section>
	</main>

    <!-- Modal para agregar/editar producto -->
    <div class="modal" id="productModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle">Agregar Producto</h2>
                <button class="close-btn" id="closeModal">&times;</button>
            </div>
            
            <div class="modal-body">
                <form id="productForm" action="inventario.jsp" method="post">			
				    <div class="form-group">
				        <label for="productName">Nombre del Producto *</label>
				        <input type="text" id="productName" name="nombre" required maxlength="200" placeholder="Ej: Camiseta Polo Clasica">
				    </div>
				
				    <div class="form-row">
				        <div class="form-group">
				            <label for="productCategory">Categoría *</label>
				            <input type="number" id="productCategory" name="categoria" required placeholder="ID de categoría">
				        </div>
				
				        <div class="form-group">
				            <label for="productPrice">Precio *</label>
				            <input type="number" id="productPrice" name="precio" step="0.01" min="0" required placeholder="0.00">
				        </div>
				    </div>
				
				    <div class="form-row">
				        <div class="form-group">
				            <label for="productMarca">Marca</label>
				            <input type="text" id="productMarca" name="marca" maxlength="100" placeholder="Ej: Nike, Adidas">
				        </div>
				
				        <div class="form-group">
				            <label for="productColor">Color</label>
				            <input type="text" id="productColor" name="color" maxlength="50" placeholder="Ej: Azul, Rojo">
				        </div>
				    </div>
				
				    <div class="form-row">
				        <div class="form-group">
				            <label for="productTalla">Talla</label>
				            <input type="text" id="productTalla" name="talla" maxlength="20" placeholder="Ej: S, M, L, XL">
				        </div>
				
				        <div class="form-group">
				            <label for="productStock">Stock Inicial *</label>
				            <input type="number" id="productStock" name="stock" min="0" required placeholder="0">
				        </div>
				    </div>
				
				    <div class="modal-footer">
				        <button type="submit" class="btn btn-primary">
				            <i class="fas fa-save"></i>
				            Guardar
				        </button>
				        <button type="button" class="btn btn-secondary" id="cancelBtn">Cancelar</button>
				    </div>
				</form>
            </div>
        </div>
    </div>

    <!-- Modal para gestionar categorias -->
    <div class="modal" id="categoryModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Gestionar Categorias</h2>
                <button class="close-btn" id="closeCategoryModal">&times;</button>
            </div>
            
            <div class="modal-body">
                <form id="categoryForm" action="inventario.jsp" method="post">
	                <div class="form-group">
	                    <label for="newCategoryName">Nueva Categoria</label>
	                    <div class="input-group">
	                        <input type="text" id="newCategoryName" name="newCategoryName" placeholder="Nombre de la categoria" maxlength="100" required>
	                        <button type="submit" class="btn btn-primary" id="addCategoryBtn">
	                            <i class="fas fa-plus"></i>
	                            Agregar
	                        </button>
	                    </div>
	                </div>
	            </form>
            
            	<div class="categories-list">
	                <h4>Categorias Existentes:</h4>
	                <div id="categoriesList">
	                    <%
                        if (categoriasList.isEmpty()) {
	                    %>
	                        <p>No hay categorías registradas.</p>
	                    <%
	                        } else {
	                        	for (int i = 0; i < categoriasList.size(); i++) {
	                        		%>
	                        		    <div class="category-item">
	                        		        <%= categoriasList.get(i) %>, id: <%= idcatList.get(i) %>
	                        		    </div>
	                        		<%
	                            }
	                        }
	                    %>
	                </div>
                </div>
            </div>
        </div>
    </div>

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
        <a href="login.html" class="logout">Cerrar sesión</a>
    </footer>

<script src="../JS/inventario.js"></script>

</body>
</html>