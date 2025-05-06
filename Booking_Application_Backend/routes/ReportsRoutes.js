const express = require("express");
const router = express.Router();
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const {getEndUserReports,getProductOwnerReports,getOpenAvailabilityReportsSchema,getOpenAvailabilityReports } = require("../controllers/ReportsController");
const { CheckAuthRole } = require("../middlewares/auth/CheckAuthRole");

router.get('/get-end-user-reports',[VerifyAccessToken, CheckAuthRole([1,3,2,4])], getEndUserReports)

router.get('/get-product-owner-reports',[VerifyAccessToken, CheckAuthRole([1,3,2,4])], getProductOwnerReports)
router.get('/get-open-availability-reports-schema',[VerifyAccessToken, CheckAuthRole([1,3,2,4])], getOpenAvailabilityReportsSchema)
router.get('/get-open-availability-reports',[VerifyAccessToken, CheckAuthRole([1,3,2,4])], getOpenAvailabilityReports)



module.exports = router;