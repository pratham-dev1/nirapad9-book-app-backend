const express = require("express");
const router = express.Router();
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const { CheckAuthRole } = require("../middlewares/auth/CheckAuthRole");
const { getProjects, submitTimeSheet, getTimeSheet, addProject } = require("../controllers/TimeSheetController");

router.get('/project-list', [VerifyAccessToken], getProjects)

router.post('/submit-timesheet', [VerifyAccessToken], submitTimeSheet)

router.get('/get-timesheet', [VerifyAccessToken], getTimeSheet)

router.post('/add-project', [VerifyAccessToken], addProject)


module.exports = router;
