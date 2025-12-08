document.addEventListener("DOMContentLoaded", () => {
    const boton = document.getElementById("descargarPDF");
    if (!boton) return;

    boton.addEventListener("click", async () => {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        // --- Texto principal ---
        doc.setFontSize(16);
        doc.text("Reporte de Estadísticas", 20, 20);
        doc.setFontSize(12);
        doc.text(`Total de Productos: ${boton.dataset.totalProductos}`, 20, 40);
        doc.text(`Valor Total Inventario: $${boton.dataset.valorTotal}`, 20, 50);
        doc.text(`Total de Categorías: ${boton.dataset.totalCategorias}`, 20, 60);
        doc.text(`Precio Promedio Productos: $${boton.dataset.promedioPrecio}`, 20, 70);
        doc.text(`Stock Total: ${boton.dataset.totalStock}`, 20, 80);
        doc.text(`Total de Clientes: ${boton.dataset.totalClientes}`, 20, 90);
        doc.text(`Clientes Activos: ${boton.dataset.clientesActivos}`, 20, 100);
        doc.text(`Clientes Inactivos: ${boton.dataset.clientesInactivos}`, 20, 110);
        doc.text(`Total de Pedidos: ${boton.dataset.totalPedidos}`, 20, 120);
        doc.text(`Monto Total Ventas: $${boton.dataset.montoTotal}`, 20, 130);
        doc.text(`Producto Más Vendido: ${boton.dataset.productoMasVendido}`, 20, 140);

        // --- GRAFICA PEDIDOS POR ESTADO ---
        const canvasPedidos = document.getElementById("graficaPedidos");
        const ctxPedidos = canvasPedidos.getContext("2d");
        const estados = Object.keys(pedidosPorEstado);
        const cantidadPedidos = Object.values(pedidosPorEstado);

        const chartPedidos = new Chart(ctxPedidos, {
            type: 'bar',
            data: {
                labels: estados,
                datasets: [{
                    label: 'Pedidos por Estado',
                    data: cantidadPedidos,
                    backgroundColor: 'rgba(54,162,235,0.6)'
                }]
            },
            options: { 
                responsive: false,
                animation: false, // Desactivar animación
                plugins: { legend: { display: true } } 
            }
        });

        // Esperar a que se renderice la gráfica
        await new Promise(resolve => setTimeout(resolve, 500));

        const imgPedidos = canvasPedidos.toDataURL("image/png");
        doc.addPage();
        doc.text("Pedidos por Estado", 20, 20);
        doc.addImage(imgPedidos, "PNG", 15, 30, 180, 90);

        // --- GRAFICA PRODUCTOS POR CATEGORIA ---
        const canvasProductos = document.getElementById("graficaProductosCat");
        const ctxProductos = canvasProductos.getContext("2d");
        const categorias = Object.keys(productosPorCategoria);
        const cantidadProductos = Object.values(productosPorCategoria);

        const chartProductos = new Chart(ctxProductos, {
            type: 'pie',
            data: {
                labels: categorias,
                datasets: [{
                    label: 'Productos por Categoría',
                    data: cantidadProductos,
                    backgroundColor: [
                        'rgba(255,99,132,0.6)',
                        'rgba(54,162,235,0.6)',
                        'rgba(255,206,86,0.6)',
                        'rgba(75,192,192,0.6)',
                        'rgba(153,102,255,0.6)',
                        'rgba(255,159,64,0.6)'
                    ]
                }]
            },
            options: { 
                responsive: false,
                animation: false // Desactivar animación
            }
        });

        // Esperar a que se renderice la gráfica
        await new Promise(resolve => setTimeout(resolve, 500));

        const imgProductos = canvasProductos.toDataURL("image/png");
        doc.addPage();
        doc.text("Productos por Categoría", 20, 20);
        doc.addImage(imgProductos, "PNG", 15, 30, 180, 90);

        // --- Descargar PDF ---
        doc.save("estadisticas_completas.pdf");
        
        // Limpiar las gráficas
        chartPedidos.destroy();
        chartProductos.destroy();
    });
});