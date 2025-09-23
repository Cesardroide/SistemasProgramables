window.addEventListener("DOMContentLoaded", () => {
  const boton = document.getElementById("miBoton");

  boton.addEventListener("click", () => {
    const colores = ["lightblue", "lightgreen", "lightpink", "lightyellow"];
    const colorActual = document.body.style.backgroundColor;
    let nuevoColor = colores[Math.floor(Math.random() * colores.length)];

    // Evitar que salga el mismo color consecutivo
    while(nuevoColor === colorActual) {
      nuevoColor = colores[Math.floor(Math.random() * colores.length)];
    }

    document.body.style.backgroundColor = nuevoColor;
  });
});
