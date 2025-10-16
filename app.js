// Verificar si hay sesión activa
const currentUser = userPool.getCurrentUser();

if (!currentUser) {
  // No hay sesión, redirigir al login
  window.location.href = 'login.html';
} else {
  // Verificar que la sesión sea válida
  currentUser.getSession((err, session) => {
    if (err || !session.isValid()) {
      window.location.href = 'login.html';
      return;
    }
    
    // Mostrar email del usuario
    document.getElementById('userEmail').textContent = `📧 ${currentUser.getUsername()}`;
  });
}

// Cerrar sesión
document.getElementById('logoutBtn').addEventListener('click', () => {
  if (currentUser) {
    currentUser.signOut();
  }
  window.location.href = 'login.html';
});

// Cambiar color de fondo
document.getElementById('changeColorBtn').addEventListener('click', () => {
  const colors = [
    'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
    'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)'
  ];
  
  const currentBg = document.body.style.background;
  let newColor = colors[Math.floor(Math.random() * colors.length)];
  
  while (newColor === currentBg && colors.length > 1) {
    newColor = colors[Math.floor(Math.random() * colors.length)];
  }
  
  document.body.style.background = newColor;
});