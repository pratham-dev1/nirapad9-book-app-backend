const jwt = require('jsonwebtoken');

const secretKey = 'yourSecretKey'; // Replace with your own secret key

// Function to generate a JWT
const generateAccessToken = (payload = {}, options) => {
    return new Promise((resolve, reject) => {
        jwt.sign(payload, secretKey, options, (error, token) => {
            if (error) {
                reject(error);
            } else {
                resolve(token);
            }
        });
    });
}

// Function to validate a JWT
// const checkAuthRole = (req, res, next) => {
//     try {
//         const accessToken = req.cookies.accessToken
//         if (!accessToken) {
//             throw { statusCode: 401, message: "Authorization token is missing" }
//         }
//         jwt.verify(accessToken, secretKey, (error, decoded) => {
//             if (error) {
//                 throw { statusCode: 401, message: 'Invalid token' }
//             } else {
//                 req.user = decoded;
//                 next();
//             }
//         });
//     }
//     catch (error) {
//         return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Error in verifying access token' });
//     }
// }

module.exports = {
    generateAccessToken,
    // checkAuthRole,
};
