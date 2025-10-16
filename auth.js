
// Configuración de AWS Cognito (inline para login.html)
const poolData = {
  UserPoolId: 'us-east-1_juoZIaN09',
  ClientId: '767u280f6hkmc7p28b3d0i0u5i'
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

// Elementos del DOM
const authContainer = document.getElementById('authContainer');
const loginForm = document.getElementById('loginForm');
const registerForm = document.getElementById('registerForm');
const verifyForm = document.getElementById('verifyForm');
const toggleLink = document.getElementById('toggleLink');
const toggleText = document.getElementById('toggleText');
const message = document.getElementById('message');

let isLoginMode = true;
let pendingUsername = null;

// Verificar si ya hay sesión activa (redirigir a app)
const currentUser = userPool.getCurrentUser();
if (currentUser) {
  currentUser.getSession((err, session) => {
    if (err) {
      console.log('No hay sesión activa');
      return;
    }
    if (session.isValid()) {
      window.location.href = 'app.html';
    }
  });
}

// Toggle entre login y registro
toggleLink.addEventListener('click', (e) => {
  e.preventDefault();
  isLoginMode = !isLoginMode;
  
  if (isLoginMode) {
    loginForm.classList.remove('hidden');
    registerForm.classList.add('hidden');
    verifyForm.classList.add('hidden');
    toggleText.textContent = '¿No tienes cuenta? ';
    toggleLink.textContent = 'Regístrate aquí';
  } else {
    loginForm.classList.add('hidden');
    registerForm.classList.remove('hidden');
    verifyForm.classList.add('hidden');
    toggleText.textContent = '¿Ya tienes cuenta? ';
    toggleLink.textContent = 'Inicia sesión aquí';
  }
  clearMessage();
});

// Login
loginForm.addEventListener('submit', (e) => {
  e.preventDefault();
  const email = document.getElementById('loginEmail').value;
  const password = document.getElementById('loginPassword').value;
  const btn = document.getElementById('loginBtn');
  
  btn.disabled = true;
  btn.innerHTML = '<span class="loading"></span>';

  const authenticationData = {
    Username: email,
    Password: password,
  };
  
  const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
  
  const userData = {
    Username: email,
    Pool: userPool
  };
  
  const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
  
  cognitoUser.authenticateUser(authenticationDetails, {
    onSuccess: (result) => {
      showMessage('¡Inicio de sesión exitoso!', 'success');
      setTimeout(() => {
        window.location.href = 'app.html';
      }, 1000);
    },
    onFailure: (err) => {
      console.error('Error:', err);
      if (err.code === 'UserNotConfirmedException') {
        showMessage('Por favor verifica tu email primero', 'error');
        pendingUsername = email;
        loginForm.classList.add('hidden');
        verifyForm.classList.remove('hidden');
      } else if (err.code === 'NotAuthorizedException') {
        showMessage('Email o contraseña incorrectos', 'error');
      } else {
        showMessage('Error: ' + err.message, 'error');
      }
      btn.disabled = false;
      btn.textContent = 'Iniciar Sesión';
    }
  });
});

// Registro
registerForm.addEventListener('submit', (e) => {
  e.preventDefault();
  const email = document.getElementById('registerEmail').value;
  const password = document.getElementById('registerPassword').value;
  const confirmPassword = document.getElementById('confirmPassword').value;
  const btn = document.getElementById('registerBtn');

  if (password !== confirmPassword) {
    showMessage('Las contraseñas no coinciden', 'error');
    return;
  }

  if (password.length < 8) {
    showMessage('La contraseña debe tener al menos 8 caracteres', 'error');
    return;
  }

  btn.disabled = true;
  btn.innerHTML = '<span class="loading"></span>';

  const attributeList = [
    new AmazonCognitoIdentity.CognitoUserAttribute({
      Name: 'email',
      Value: email
    })
  ];

  userPool.signUp(email, password, attributeList, null, (err, result) => {
    if (err) {
      console.error('Error:', err);
      if (err.code === 'UsernameExistsException') {
        showMessage('Este email ya está registrado', 'error');
      } else {
        showMessage('Error: ' + err.message, 'error');
      }
      btn.disabled = false;
      btn.textContent = 'Crear Cuenta';
      return;
    }
    
    pendingUsername = email;
    showMessage('¡Cuenta creada! Revisa tu email para el código de verificación', 'success');
    registerForm.classList.add('hidden');
    verifyForm.classList.remove('hidden');
    btn.disabled = false;
    btn.textContent = 'Crear Cuenta';
  });
});

// Verificación
verifyForm.addEventListener('submit', (e) => {
  e.preventDefault();
  const code = document.getElementById('verifyCode').value;
  const btn = document.getElementById('verifyBtn');

  if (!pendingUsername) {
    showMessage('Error: No hay usuario pendiente de verificación', 'error');
    return;
  }

  btn.disabled = true;
  btn.innerHTML = '<span class="loading"></span>';

  const userData = {
    Username: pendingUsername,
    Pool: userPool
  };

  const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

  cognitoUser.confirmRegistration(code, true, (err, result) => {
    if (err) {
      console.error('Error:', err);
      showMessage('Código incorrecto: ' + err.message, 'error');
      btn.disabled = false;
      btn.textContent = 'Verificar Email';
      return;
    }
    
    showMessage('¡Email verificado! Ahora puedes iniciar sesión', 'success');
    setTimeout(() => {
      verifyForm.classList.add('hidden');
      loginForm.classList.remove('hidden');
      isLoginMode = true;
      toggleText.textContent = '¿No tienes cuenta? ';
      toggleLink.textContent = 'Regístrate aquí';
      document.getElementById('verifyCode').value = '';
      btn.disabled = false;
      btn.textContent = 'Verificar Email';
    }, 2000);
  });
});

// Funciones auxiliares
function showMessage(text, type) {
  message.textContent = text;
  message.className = `message ${type}`;
}

function clearMessage() {
  message.textContent = '';
  message.className = 'message';
}