// Función para abrir el modal
function abrirModal() {
    const modal = document.getElementById('modalUsuario');
    const form = document.getElementById('formUsuario');
    const titulo = document.getElementById('tituloModal');
    
    titulo.textContent = 'Nuevo Usuario';
    form.reset();
    modal.style.display = 'block';
}

// Función para cerrar el modal
function cerrarModal() {
    const modal = document.getElementById('modalUsuario');
    modal.style.display = 'none';
}

// Cerrar modal al hacer clic fuera de él
window.onclick = function(event) {
    const modal = document.getElementById('modalUsuario');
    if (event.target == modal) {
        modal.style.display = 'none';
    }
}

// El formulario ahora se envía directamente al JSP (sin JavaScript)
// Solo dejamos la funcionalidad de búsqueda
document.addEventListener('DOMContentLoaded', () => {
    // Función de búsqueda en la tabla
    const inputBuscar = document.getElementById('buscarCliente');
    if (inputBuscar) {
        inputBuscar.addEventListener('input', function() {
            const filtro = this.value.toLowerCase();
            const filas = document.querySelectorAll('#cuerpoTabla tr');
            
            filas.forEach(fila => {
                const texto = fila.textContent.toLowerCase();
                if (texto.includes(filtro)) {
                    fila.style.display = '';
                } else {
                    fila.style.display = 'none';
                }
            });
        });
    }
    
    // Cerrar mensaje después de 5 segundos
    const mensaje = document.querySelector('.mensaje');
    if (mensaje) {
        setTimeout(() => {
            mensaje.style.display = 'none';
        }, 5000);
    }
});

document.addEventListener('DOMContentLoaded', function() {
    const inputBuscar = document.getElementById('buscarUsuario');
    const tabla = document.getElementById('tablaClientes');
    const tbody = document.getElementById('cuerpoTabla');
    
    if (inputBuscar) {
        inputBuscar.addEventListener('keyup', function() {
            const filtro = this.value.toLowerCase().trim();
            const filas = tbody.getElementsByTagName('tr');
            
            for (let i = 0; i < filas.length; i++) {
                const fila = filas[i];
                const celdas = fila.getElementsByTagName('td');
                let encontrado = false;
                
                // Buscar en todas las celdas excepto la última (botones)
                for (let j = 0; j < celdas.length - 1; j++) {
                    const textoCelda = celdas[j].textContent || celdas[j].innerText;
                    if (textoCelda.toLowerCase().indexOf(filtro) > -1) {
                        encontrado = true;
                        break;
                    }
                }
                
                // Mostrar u ocultar la fila según si se encontró coincidencia
                if (encontrado || filtro === '') {
                    fila.style.display = '';
                } else {
                    fila.style.display = 'none';
                }
            }
        });
    }
});