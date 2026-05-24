const crypto = require('crypto');
function b64url(s) { return Buffer.from(s).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_'); }
const header = b64url(JSON.stringify({alg:"HS256",typ:"JWT"}));
const payload = b64url(JSON.stringify({sub:"test_farmer",role:"FARMER",iat:Math.floor(Date.now()/1000),exp:Math.floor(Date.now()/1000)+3600}));
const secret = "4d6a695b2c75a401a4e21544a4253133"; // Checking application.properties for secret?
console.log(header + "." + payload + "." + b64url(crypto.createHmac('sha256', secret).update(header+"."+payload).digest()));
