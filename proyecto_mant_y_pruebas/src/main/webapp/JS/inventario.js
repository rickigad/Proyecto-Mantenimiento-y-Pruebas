// Variables globales
let allProducts = [];
let filteredProducts = [];

// Elementos del DOM
const searchInput = document.getElementById('searchInput');
const categoryFilter = document.getElementById('categoryFilter');
const addProductBtn = document.getElementById('addProductBtn');
const productModal = document.getElementById('productModal');
const closeModal = document.getElementById('closeModal');
const cancelBtn = document.getElementById('cancelBtn');
const modalTitle = document.getElementById('modalTitle');
const productsTableBody = document.getElementById('productsTableBody');
const emptyState = document.getElementById('emptyState');

// Modal de categorías
const categoryModal = document.getElementById('categoryModal');
const manageCategoriesBtn = document.getElementById('manageCategoriesBtn');
const closeCategoryModal = document.getElementById('closeCategoryModal');

// Inicializar la aplicación
document.addEventListener('DOMContentLoaded', function() {
    // Cargar productos desde la tabla HTML existente
    loadProductsFromTable();
    
    // Event listeners para búsqueda y filtros
    if (searchInput) {
        searchInput.addEventListener('input', filterProducts);
    }
    if (categoryFilter) {
        categoryFilter.addEventListener('change', filterProducts);
    }
    
    // Event listeners para modal de productos
    if (addProductBtn) {
        addProductBtn.addEventListener('click', openAddProductModal);
    }
    if (closeModal) {
        closeModal.addEventListener('click', closeProductModal);
    }
    if (cancelBtn) {
        cancelBtn.addEventListener('click', closeProductModal);
    }
    
    // Event listeners para modal de categorías
    if (manageCategoriesBtn) {
        manageCategoriesBtn.addEventListener('click', openCategoryModal);
    }
    if (closeCategoryModal) {
        closeCategoryModal.addEventListener('click', closeCategoryModalFunc);
    }
    
    // Cerrar modales al hacer clic fuera
    if (productModal) {
        productModal.addEventListener('click', function(e) {
            if (e.target === productModal) {
                closeProductModal();
            }
        });
    }
    
    if (categoryModal) {
        categoryModal.addEventListener('click', function(e) {
            if (e.target === categoryModal) {
                closeCategoryModalFunc();
            }
        });
    }
});

// Cargar productos desde la tabla HTML existente
function loadProductsFromTable() {
    allProducts = [];
    const rows = productsTableBody.querySelectorAll('tr');
    
    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length >= 8) {
            const product = {
                id: cells[0].textContent.trim(),
                nombre: cells[1].textContent.trim(),
                categoria: cells[2].textContent.trim(),
                marca: cells[3].textContent.trim(),
                color: cells[4].textContent.trim(),
                talla: cells[5].textContent.trim(),
                precio: cells[6].textContent.trim(),
                stock: cells[7].textContent.trim()
            };
            allProducts.push(product);
        }
    });
    
    filteredProducts = [...allProducts];
}

// Función que filtra productos con base en búsqueda y categoría
function filterProducts() {
    const searchTerm = searchInput.value.toLowerCase();
    const selectedCategory = categoryFilter.value.toLowerCase();

    filteredProducts = allProducts.filter(product => {
        const name = (product.nombre || '').toLowerCase();
        const category = (product.categoria || '').toLowerCase();
        const brand = (product.marca || '').toLowerCase();
        const color = (product.color || '').toLowerCase();

        const matchesSearch =
            name.includes(searchTerm) ||
            brand.includes(searchTerm) ||
            color.includes(searchTerm);

        const matchesCategory =
            !selectedCategory || category === selectedCategory;

        return matchesSearch && matchesCategory;
    });

    renderFilteredProducts();
}

// Renderizar productos filtrados
function renderFilteredProducts() {
    const rows = productsTableBody.querySelectorAll('tr');
    
    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length >= 8) {
            const productId = cells[0].textContent.trim();
            const productName = cells[1].textContent.trim();
            const productCategory = cells[2].textContent.trim();
            const productBrand = cells[3].textContent.trim();
            const productColor = cells[4].textContent.trim();
            
            // Verificar si este producto está en los resultados filtrados
            const isVisible = filteredProducts.some(product => 
                product.id === productId && 
                product.nombre === productName
            );
            
            if (isVisible) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    });
    
    // Mostrar/ocultar estado vacío
    const visibleRows = Array.from(rows).filter(row => row.style.display !== 'none');
    if (emptyState) {
        if (visibleRows.length === 0 || (visibleRows.length === 1 && visibleRows[0].querySelector('.no-data'))) {
            emptyState.style.display = 'block';
        } else {
            emptyState.style.display = 'none';
        }
    }
}

// Funciones para modal de productos
function openAddProductModal() {
    modalTitle.textContent = 'Agregar Producto';
    clearProductForm();
    productModal.classList.add('active');
}

function closeProductModal() {
    productModal.classList.remove('active');
    clearProductForm();
}

function clearProductForm() {
    const form = document.getElementById('productForm');
    if (form) {
        form.reset();
    }
}

// Funciones para modal de categorías
function openCategoryModal() {
    categoryModal.classList.add('active');
}

function closeCategoryModalFunc() {
    categoryModal.classList.remove('active');
    const form = document.getElementById('categoryForm');
    if (form) {
        form.reset();
    }
}

// Funciones para manejar la actualización de stock
function showStockForm(productId) {
    // Ocultar todos los otros formularios
    document.querySelectorAll('.stock-form').forEach(form => {
        form.classList.remove('active');
    });
    
    // Mostrar el formulario específico
    const form = document.getElementById('stockForm' + productId);
    form.classList.add('active');
    
    // Enfocar el input
    const input = form.querySelector('input[name="addStockAmount"]');
    input.focus();
}

function hideStockForm(productId) {
    const form = document.getElementById('stockForm' + productId);
    form.classList.remove('active');
    
    // Limpiar el input
    const input = form.querySelector('input[name="addStockAmount"]');
    input.value = '';
}

// Inicializar eventos cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', function() {
    // Ocultar formularios al hacer clic fuera
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.stock-cell')) {
            document.querySelectorAll('.stock-form').forEach(form => {
                form.classList.remove('active');
            });
        }
    });

    // Prevenir que el clic en el formulario de stock lo oculte
    document.addEventListener('click', function(e) {
        if (e.target.closest('.stock-form')) {
            e.stopPropagation();
        }
    });

    // Manejo del Enter en los campos de stock
    document.querySelectorAll('input[name="addStockAmount"]').forEach(input => {
        input.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.closest('form').submit();
            }
        });
    });
});