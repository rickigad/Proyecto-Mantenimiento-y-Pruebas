// ===== FUNCIONALIDAD MODAL =====

// Abrir el modal
function abrirModal() {
    const modal = document.getElementById("modalCliente");
    modal.style.display = "block";
    document.body.style.overflow = 'hidden'; // Prevenir scroll del body
}

// Cerrar el modal
function cerrarModal() {
    const modal = document.getElementById("modalCliente");
    modal.style.display = "none";
    document.body.style.overflow = 'auto'; // Restaurar scroll del body
    
    // Limpiar formulario
    document.getElementById('formCliente').reset();
    
    // Limpiar errores de validación
    document.querySelectorAll('.mensaje-error').forEach(error => error.remove());
    document.querySelectorAll('.error').forEach(input => input.classList.remove('error'));
}

// Cerrar modal al hacer clic fuera de él
window.onclick = function(event) {
    const modal = document.getElementById("modalCliente");
    if (event.target === modal) {
        cerrarModal();
    }
};

// Cerrar modal con tecla Escape
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modal = document.getElementById('modalCliente');
        if (modal.style.display === 'block') {
            cerrarModal();
        }
    }
});

// ===== FUNCIONALIDAD DE FILTROS =====

// Variables globales
let todosLosClientes = [];

// Función para inicializar la aplicación
document.addEventListener('DOMContentLoaded', function() {
    cargarClientesEnMemoria();
    configurarEventosFiltroBusqueda();
});

// Cargar todos los clientes en memoria para filtrado rápido
function cargarClientesEnMemoria() {
    const tabla = document.getElementById('tablaClientes');
    const filas = tabla.querySelectorAll('tbody tr');
    
    todosLosClientes = [];
    
    filas.forEach(fila => {
        const celdas = fila.querySelectorAll('td');
        if (celdas.length > 0) {
            const cliente = {
                elemento: fila,
                id: celdas[0].textContent.trim(),
                cedula: celdas[1].textContent.trim().toLowerCase(),
                nombreCompleto: celdas[2].textContent.trim().toLowerCase(),
                correo: celdas[3].textContent.trim().toLowerCase(),
                direccion: celdas[4].textContent.trim().toLowerCase(),
                telefono: celdas[5].textContent.trim(),
                activo: celdas[7].querySelector('input[type="checkbox"]').checked
            };
            todosLosClientes.push(cliente);
        }
    });
}

// Configurar eventos de filtro y búsqueda
function configurarEventosFiltroBusqueda() {
    const inputBuscar = document.getElementById('buscarCliente');
    const selectEstado = document.getElementById('filtroEstado');
    
    // Evento de búsqueda con debounce
    let timeoutBusqueda;
    inputBuscar.addEventListener('input', function() {
        clearTimeout(timeoutBusqueda);
        timeoutBusqueda = setTimeout(() => {
            aplicarFiltros();
        }, 300); // Esperar 300ms después de que el usuario deje de escribir
    });
    
    // Evento de cambio de estado
    selectEstado.addEventListener('change', function() {
        aplicarFiltros();
    });
}

// Aplicar filtros de búsqueda y estado
function aplicarFiltros() {
    const textoBusqueda = document.getElementById('buscarCliente').value.toLowerCase().trim();
    const filtroEstado = document.getElementById('filtroEstado').value;
    
    let clientesFiltrados = todosLosClientes;
    
    // Filtrar por texto de búsqueda
    if (textoBusqueda !== '') {
        clientesFiltrados = clientesFiltrados.filter(cliente => {
            return cliente.nombreCompleto.includes(textoBusqueda) ||
                   cliente.cedula.includes(textoBusqueda) ||
                   cliente.correo.includes(textoBusqueda) ||
                   cliente.telefono.includes(textoBusqueda) ||
                   cliente.id.includes(textoBusqueda) ||
                   cliente.direccion.includes(textoBusqueda);
        });
    }
    
    // Filtrar por estado
    if (filtroEstado !== '') {
        clientesFiltrados = clientesFiltrados.filter(cliente => {
            if (filtroEstado === 'activo') {
                return cliente.activo === true;
            } else if (filtroEstado === 'inactivo') {
                return cliente.activo === false;
            }
            return true;
        });
    }
    
    // Mostrar/ocultar filas según filtros
    mostrarClientesFiltrados(clientesFiltrados);
}

// Mostrar solo los clientes filtrados
function mostrarClientesFiltrados(clientesFiltrados) {
    // Ocultar todos los clientes primero
    todosLosClientes.forEach(cliente => {
        cliente.elemento.style.display = 'none';
    });
    
    // Mostrar solo los filtrados
    clientesFiltrados.forEach(cliente => {
        cliente.elemento.style.display = '';
    });
    
    // Mostrar mensaje si no hay resultados
    mostrarMensajeSinResultados(clientesFiltrados.length === 0);
}

// Mostrar mensaje cuando no hay resultados
function mostrarMensajeSinResultados(mostrar) {
    let mensajeExistente = document.getElementById('mensajeSinResultados');
    
    if (mostrar) {
        if (!mensajeExistente) {
            const tbody = document.querySelector('#tablaClientes tbody');
            const fila = document.createElement('tr');
            fila.id = 'mensajeSinResultados';
            fila.innerHTML = `
                <td colspan="8" class="no-datos">
                    <div style="padding: 2rem; text-align: center;">
                        <i style="font-size: 3rem; color: #ccc; margin-bottom: 1rem;">🔍</i>
                        <p>No se encontraron clientes que coincidan con los filtros aplicados.</p>
                        <p style="font-size: 0.9rem; color: #999; margin-top: 0.5rem;">
                            Intenta modificar los criterios de búsqueda.
                        </p>
                    </div>
                </td>
            `;
            tbody.appendChild(fila);
        }
    } else {
        if (mensajeExistente) {
            mensajeExistente.remove();
        }
    }
}

// ===== VALIDACIÓN DE FORMULARIO =====

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('formCliente');
    if (form) {
        form.addEventListener('submit', function(e) {
            if (!validarFormulario()) {
                e.preventDefault();
                return false;
            }
        });
    }
});

function validarFormulario() {
    let esValido = true;
    
    // Limpiar errores previos
    document.querySelectorAll('.mensaje-error').forEach(error => error.remove());
    document.querySelectorAll('.error').forEach(input => input.classList.remove('error'));
    
    // Validar cédula
    const cedula = document.getElementById('cedula');
    if (cedula.value.trim().length < 6) {
        mostrarError(cedula, 'La cédula debe tener al menos 6 caracteres');
        esValido = false;
    }
    
    // Validar nombre
    const nombre = document.getElementById('nombre');
    if (nombre.value.trim().length < 2) {
        mostrarError(nombre, 'El nombre debe tener al menos 2 caracteres');
        esValido = false;
    }
    
    // Validar apellido
    const apellido = document.getElementById('apellido');
    if (apellido.value.trim().length < 2) {
        mostrarError(apellido, 'El apellido debe tener al menos 2 caracteres');
        esValido = false;
    }
    
    // Validar correo
    const correo = document.getElementById('correo');
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo.value.trim())) {
        mostrarError(correo, 'Ingrese un correo electrónico válido');
        esValido = false;
    }
    
    // Validar teléfono
    const telefono = document.getElementById('telefono');
    const telefonoRegex = /^\d{8}$/; // 8 dígitos para Panamá
    if (!telefonoRegex.test(telefono.value.trim())) {
        mostrarError(telefono, 'El teléfono debe tener 8 dígitos');
        esValido = false;
    }
    
    // Validar dirección
    const direccion = document.getElementById('direccion');
    if (direccion.value.trim().length < 10) {
        mostrarError(direccion, 'La dirección debe ser más detallada');
        esValido = false;
    }
    
    return esValido;
}

function mostrarError(input, mensaje) {
    input.classList.add('error');
    
    const errorDiv = document.createElement('span');
    errorDiv.className = 'mensaje-error';
    errorDiv.textContent = mensaje;
    
    input.parentNode.appendChild(errorDiv);
}