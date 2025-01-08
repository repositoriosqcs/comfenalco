document.addEventListener("DOMContentLoaded", function () {
    // Configuración de Mermaid para diagramas personalizados
    if (window.mermaid) {
        mermaid.initialize({
            startOnLoad: true,
            theme: 'base',  // Usa 'base' para personalización avanzada
            themeVariables: {
                primaryColor: '#d89717',      // Color principal para nodos
                primaryBorderColor: '#b1740f', // Color de bordes
                primaryTextColor: '#ffffff',   // Color de texto principal
                secondaryColor: '#f3c785',     // Color secundario
                lineColor: '#b1740f',          // Color de líneas de conexión
                background: '#ffffff',         // Fondo de diagramas
                fontFamily: 'Arial, sans-serif' // Fuente para los diagramas
            },
            flowchart: {
                curve: 'basis', // Añadir curvas suaves en los diagramas
            }
        });
    } else {
        console.warn("Mermaid no se ha cargado. Verifica la inclusión del script.");
    }

    // Reemplaza el texto "Tabla de contenidos" por "DETALLE DE CONTENIDO" en la barra lateral derecha
    const sidebarTitle = document.querySelector(".md-sidebar--secondary .md-nav__title");
    if (sidebarTitle) {
        sidebarTitle.textContent = "DETALLE DE CONTENIDO";
    }
});
