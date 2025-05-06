const express = require("express");
const { saveLeadInfo, getCommunicationStatus, getAllLeads, updateLeadInfo, saveLeadsThroughExcel, getCommunicationStatusForPhone, getCommunicationStatusForEmail, getCommunicationStatusForLinkedin } = require("../controllers/CrmInternalController");
const router = express.Router();

router.post('/save-lead-info', saveLeadInfo)

router.get('/get-communication-status', getCommunicationStatus)

router.get('/get-communication-status-email', getCommunicationStatusForEmail)

router.get('/get-communication-status-phone', getCommunicationStatusForPhone)

router.get('/get-communication-status-linkedin', getCommunicationStatusForLinkedin)

router.get('/get-all-leads', getAllLeads)

router.put('/edit-lead-info', updateLeadInfo)

router.post('/save-leads-through-excel', saveLeadsThroughExcel)

module.exports = router;
