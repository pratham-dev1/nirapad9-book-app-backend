const express = require("express");
const router = express.Router();
const { login, getSession, logout, googleLoginResponse, microsoftLoginResponse, generateOtpForResetPassword, verifyOtpForResetPassword, resetPassword, verifyAccountKey, resendVerificationLink, passwordUpdatedVerification, passwordUpdateForSecurity, verifyKeyForUpdatePassword, updatePasswordForSecurity,getFaqTesting,createApiKey ,getResources,regenerateAPIKey,deleteAPIKey,verifyMFASetup,updateMFAConfigurationSetup,getMfaQRcode, verifyMFA,enableMFA,skipMFA} = require("../controllers/AuthController");
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const passport = require('../config/passport');
const { CLIENT_URL, SERVER_URL } = require("../config/urlsConfig");
const { google } = require('googleapis');
const { AuthenticateApiKey } = require("../middlewares/auth/AuthenticateAPIKey");



router.post('/login', login)

router.get("/get-session", [VerifyAccessToken], getSession)

router.post("/logout", logout)

router.get('/google-login/:userId?', (req, res, next) => {
    passport.authenticate('google',
        {
            scope: ['profile', 'email', 'https://www.googleapis.com/auth/calendar', 'https://mail.google.com'],
            accessType: 'offline',
            state: req.params.userId,
            prompt: 'consent'
        })(req, res, next);
})

router.get('/google/callback', passport.authenticate('google', { failureRedirect: `${CLIENT_URL}/login` }), googleLoginResponse);

router.get('/microsoft-login/:userId?', (req, res, next) => {
    passport.authenticate('microsoft',
    { 
        scope: ['user.read',  'Mail.ReadWrite', 'Mail.Send', 'Calendars.ReadWrite', 'offline_access'],
        state: req.params.userId
    })(req, res, next);      
});

router.get('/microsoft/callback', passport.authenticate('microsoft', { failureRedirect: `${CLIENT_URL}/login` }), microsoftLoginResponse);

router.post("/generate-otp", generateOtpForResetPassword)

router.post("/verify-otp", verifyOtpForResetPassword)

router.post("/reset-password", resetPassword)

router.get("/verify-account-key/:userId/:key", verifyAccountKey)

router.post("/resend-verification-link", resendVerificationLink)

router.get('/verify-update-password-key/:userId/:key', verifyKeyForUpdatePassword)

router.post('/update-password-for-security', updatePasswordForSecurity)

router.get('/testing-faqs',[AuthenticateApiKey], getFaqTesting)
router.post('/create-api-key', createApiKey); 
router.get('/get-resources', getResources); 
router.put('/regenerate-api-key',regenerateAPIKey)
router.delete('/delete-api-key',deleteAPIKey)
router.post('/update-mfa-configuration-setup',updateMFAConfigurationSetup)
router.post('/get-mfa-qr-code',getMfaQRcode)
router.post('/verify-mfa',verifyMFA)
router.post('/enable-mfa',enableMFA)
router.post('/skip-mfa',skipMFA)

module.exports = router;