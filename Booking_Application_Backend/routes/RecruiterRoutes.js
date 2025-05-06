const express = require("express");
const router = express.Router();
const {
  getAvailableSlots,
  bookSlot,
  getZohoForms,
  getRecruiterHistory,
  getSkillsForBookedSlot,
  updateSlot,
  cancelEvent,
  bookConfirmedSlot,
  getSelectedUserAvailableSlots,
  changeBookedSlot
} = require("../controllers/RecruiterController");
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const { CheckAuthRole } = require("../middlewares/auth/CheckAuthRole");


router.get("/available-slots",[VerifyAccessToken,CheckAuthRole([2])], getAvailableSlots);

router.post("/book-slot",[VerifyAccessToken,CheckAuthRole([2])], bookSlot);

router.get("/zoho-forms",[VerifyAccessToken,CheckAuthRole([2])], getZohoForms);

router.get('/history', [VerifyAccessToken,CheckAuthRole([2])], getRecruiterHistory)

router.get('/get-skills-for-booked-slot', [VerifyAccessToken,CheckAuthRole([2])], getSkillsForBookedSlot)

router.put('/update-slot',[VerifyAccessToken, CheckAuthRole([2])], updateSlot)

router.post('/cancel-event',[VerifyAccessToken, CheckAuthRole([2])], cancelEvent)

router.post("/book-confirmed-slot",[VerifyAccessToken,CheckAuthRole([2])], bookConfirmedSlot);

router.get("/selected-user-available-slots",[VerifyAccessToken,CheckAuthRole([2])], getSelectedUserAvailableSlots);

router.post("/change-booked-slot",[VerifyAccessToken,CheckAuthRole([2])], changeBookedSlot);

module.exports = router;
