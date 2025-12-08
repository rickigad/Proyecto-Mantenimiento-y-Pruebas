// Sistema de filtros para pedidos
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const dateFilter = document.getElementById('dateFilter');
    const tableBody = document.getElementById('ordersTableBody');
    
    // Verificar que los elementos existen
    if (!searchInput || !statusFilter || !dateFilter || !tableBody) {
        console.error('No se encontraron algunos elementos del filtro');
        return;
    }
    
    // Guardar todas las filas originales
    let allRows = Array.from(tableBody.getElementsByTagName('tr'));
    
    // Función principal de filtrado
    function filterOrders() {
        const searchTerm = searchInput.value.toLowerCase().trim();
        const selectedStatus = statusFilter.value.toLowerCase();
        const selectedDateRange = dateFilter.value;
        
        let filteredRows = allRows.filter(row => {
            // Obtener datos de la fila
            const cells = row.getElementsByTagName('td');
            if (cells.length === 0) return false;
            
            const idPedido = cells[0].textContent.toLowerCase();
            const idCliente = cells[1].textContent.toLowerCase();
            const fecha = cells[2].textContent;
            const producto = cells[3].textContent.toLowerCase();
            const cantidad = cells[4].textContent.toLowerCase();
            const total = cells[5].textContent.toLowerCase();
            const estado = cells[6].textContent.toLowerCase().trim();
            
            // Filtro de búsqueda (busca en ID pedido, ID cliente, producto)
            const matchesSearch = searchTerm === '' || 
                idPedido.includes(searchTerm) ||
                idCliente.includes(searchTerm) ||
                producto.includes(searchTerm) ||
                cantidad.includes(searchTerm) ||
                total.includes(searchTerm);
            
            // Filtro de estado
            let matchesStatus = true;
            if (selectedStatus !== '') {
                if (selectedStatus === 'proceso') {
                    matchesStatus = estado.includes('proceso');
                } else {
                    matchesStatus = estado === selectedStatus;
                }
            }
            
            // Filtro de fecha
            const matchesDate = filterByDate(fecha, selectedDateRange);
            
            return matchesSearch && matchesStatus && matchesDate;
        });
        
        // Mostrar filas filtradas
        displayFilteredRows(filteredRows);
        
        // Mostrar mensaje si no hay resultados
        showNoResultsMessage(filteredRows.length === 0);
        
        // Actualizar contador
        updateResultsCounter();
    }
    
    // Función para filtrar por fecha
    function filterByDate(fechaStr, dateRange) {
        if (dateRange === '') return true;
        
        try {
            // Convertir fecha del formato dd/MM/yyyy a Date
            const [day, month, year] = fechaStr.split('/');
            const fechaPedido = new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
            const hoy = new Date();
            hoy.setHours(0, 0, 0, 0);
            
            switch (dateRange) {
                case 'hoy':
                    const pedidoHoy = new Date(fechaPedido);
                    pedidoHoy.setHours(0, 0, 0, 0);
                    return pedidoHoy.getTime() === hoy.getTime();
                    
                case 'semana':
                    const inicioSemana = new Date(hoy);
                    inicioSemana.setDate(hoy.getDate() - hoy.getDay());
                    inicioSemana.setHours(0, 0, 0, 0);
                    return fechaPedido >= inicioSemana && fechaPedido <= hoy;
                    
                case 'mes':
                    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
                    inicioMes.setHours(0, 0, 0, 0);
                    return fechaPedido >= inicioMes && fechaPedido <= hoy;
                    
                default:
                    return true;
            }
        } catch (error) {
            console.error('Error al parsear fecha:', fechaStr, error);
            return true;
        }
    }
    
    // Función para mostrar las filas filtradas
    function displayFilteredRows(rows) {
        // Limpiar tabla
        tableBody.innerHTML = '';
        
        // Agregar filas filtradas
        rows.forEach(row => {
            const clonedRow = row.cloneNode(true);
            tableBody.appendChild(clonedRow);
        });
        
        // Re-agregar event listeners a los selects de estado
        addStateChangeListeners();
    }
    
    // Función para mostrar mensaje de "no hay resultados"
    function showNoResultsMessage(show) {
        const existingMessage = document.getElementById('noResultsMessage');
        if (existingMessage) {
            existingMessage.remove();
        }
        
        if (show) {
            const noResultsRow = document.createElement('tr');
            noResultsRow.id = 'noResultsMessage';
            noResultsRow.innerHTML = `
                <td colspan="8" style="text-align: center; padding: 20px; color: #666; font-style: italic;">
                    <i class="fas fa-search" style="margin-right: 8px;"></i>
                    No se encontraron pedidos que coincidan con los criterios de búsqueda
                </td>
            `;
            tableBody.appendChild(noResultsRow);
        }
    }
    
    // Función para re-agregar event listeners a los selects de cambio de estado
    function addStateChangeListeners() {
        const stateSelects = tableBody.querySelectorAll('select[name="nuevoEstado"]');
        stateSelects.forEach(select => {
            select.addEventListener('change', function() {
                this.form.submit();
            });
        });
    }
    
    // Función debounce para optimizar la búsqueda
    function debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    // Agregar contador de resultados
    function addResultsCounter() {
        const tableContainer = document.querySelector('.table-container');
        if (!tableContainer) return;
        
        const counterDiv = document.createElement('div');
        counterDiv.id = 'resultsCounter';
        counterDiv.style.cssText = `
            margin-bottom: 10px;
            color: #666;
            font-size: 14px;
            text-align: right;
        `;
        tableContainer.insertBefore(counterDiv, tableContainer.firstChild);
        updateResultsCounter();
    }
    
    // Actualizar contador de resultados
    function updateResultsCounter() {
        const counter = document.getElementById('resultsCounter');
        const visibleRows = tableBody.querySelectorAll('tr:not(#noResultsMessage)').length;
        const totalRows = allRows.length;
        
        if (counter) {
            counter.innerHTML = `
                <i class="fas fa-list"></i>
                Mostrando ${visibleRows} de ${totalRows} pedidos
            `;
        }
    }
    
    // Event listeners para los filtros
    if (searchInput) {
        searchInput.addEventListener('input', debounce(filterOrders, 300));
    }
    if (statusFilter) {
        statusFilter.addEventListener('change', filterOrders);
    }
    if (dateFilter) {
        dateFilter.addEventListener('change', filterOrders);
    }
    
    // Inicializar funcionalidades adicionales
    addResultsCounter();
    
    // Inicializar event listeners para los selects existentes
    addStateChangeListeners();
    
    console.log('Sistema de filtros inicializado correctamente');
});

// Funciones para el modal
function openProductoModal() {
    const modal = document.getElementById('productoModal');
    if (modal) {
        modal.classList.add('active');
        // Enfocar el primer input
        const firstInput = modal.querySelector('input');
        if (firstInput) {
            setTimeout(() => firstInput.focus(), 100);
        }
    }
}

function closeProductoModal() {
    const modal = document.getElementById('productoModal');
    const form = document.getElementById('productoForm');
    
    if (modal) {
        modal.classList.remove('active');
    }
    if (form) {
        form.reset();
    }
}

// Cerrar modal al hacer clic fuera de él o con Escape
document.addEventListener('click', function(event) {
    const modal = document.getElementById('productoModal');
    if (modal && event.target === modal) {
        closeProductoModal();
    }
});

// Cerrar modal con tecla Escape
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modal = document.getElementById('productoModal');
        if (modal && modal.classList.contains('active')) {
            closeProductoModal();
        }
    }
});

function confirmarCambioEstado(selectElement) {
    const nuevoEstado = selectElement.value;
    const form = selectElement.closest('form');
    
    if (nuevoEstado === '') {
        return; // No hacer nada si no se seleccionó un estado
    }
    
    let mensaje = '';
    
    if (nuevoEstado === 'completado') {
        mensaje = '¿Estás seguro de marcar este pedido como COMPLETADO? Esta acción no se puede deshacer.';
    } else if (nuevoEstado === 'cancelado') {
        mensaje = '¿Estás seguro de CANCELAR este pedido? Se restaurará el stock del producto y esta acción no se puede deshacer.';
    } else {
        mensaje = `¿Confirmas cambiar el estado a "${nuevoEstado}"?`;
    }
    
    if (confirm(mensaje)) {
        form.submit();
    } else {
        // Resetear el select si el usuario cancela
        selectElement.selectedIndex = 0;
    }
}