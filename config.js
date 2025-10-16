// Configuración de AWS Cognito
const poolData = {
  UserPoolId: 'us-east-1_juoZIaN09',
  ClientId: '767u280f6hkmc7p28b3d0i0u5i'
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);