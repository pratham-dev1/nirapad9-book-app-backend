const express = require("express");
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const { CheckAuthRole } = require("../middlewares/auth/CheckAuthRole");
const { getEmailSupportHistory, getAllUserList, enableOrDisableCredentials, getCredentialBlockedLogs, getUsersTokenInfo } = require("../controllers/ProductOwnerController");
const router = express.Router();

router.get('/get-email-support-history',[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getEmailSupportHistory)

router.get('/all-user-list',[VerifyAccessToken, CheckAuthRole([5])], getAllUserList)

router.put('/enable-or-disable-credentials',[VerifyAccessToken, CheckAuthRole([5])], enableOrDisableCredentials)

router.get('/get-credential-blocked-logs',[VerifyAccessToken, CheckAuthRole([5])], getCredentialBlockedLogs)

router.get('/get-users-token-info',[VerifyAccessToken, CheckAuthRole([5])], getUsersTokenInfo)


module.exports = router;