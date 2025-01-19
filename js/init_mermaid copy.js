document.addEventListener("DOMContentLoaded", function() {
    if (typeof mermaid !== 'undefined') {
        mermaid.initialize({
            startOnLoad: true,
            theme: 'base',  // Cambiar el tema por 'base' para personalización
            themeVariables: {
                primaryColor: '#d89717', // Color principal para los nodos
                primaryBorderColor: '#b1740f', // Color de los bordes principales
                primaryTextColor: '#ffffff', // Color del texto principal
                secondaryColor: '#f3c785', // Color secundario para nodos relacionados
                lineColor: '#b1740f', // Color de las líneas de conexión
                background: '#ffffff', // Color de fondo de los diagramas
                fontFamily: 'Arial, sans-serif', // Fuente a usar en los diagramas
            },
            flowchart: {
                curve: 'basis', // Añadir curvas suaves a los diagramas
            }
        });
    }
});
