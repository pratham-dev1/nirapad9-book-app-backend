const express = require("express");
const router = express.Router();
const {
  saveSlot,
  getTalentPartnerHistory,
  checkExistingSlots,
  deleteSingleOrMultipleAvailabilities,
  updateExistingSlot,
  updateRecordTime,
  slotCancelRequestOrWithdrawnRequest
} = require("../controllers/TalentPartnerController");
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const { CheckAuthRole } = require("../middlewares/auth/CheckAuthRole");

router.post("/save-slot",[VerifyAccessToken, CheckAuthRole([1])], saveSlot);

router.get('/history',[VerifyAccessToken, CheckAuthRole([1])], getTalentPartnerHistory)

router.post('/check-existing-slot',[VerifyAccessToken, CheckAuthRole([1])], checkExistingSlots)

router.delete('/delete-slot',[VerifyAccessToken, CheckAuthRole([1])],deleteSingleOrMultipleAvailabilities)

router.post('/update-slot',[VerifyAccessToken, CheckAuthRole([1])], updateExistingSlot)

router.post('/update-record-time', [VerifyAccessToken, CheckAuthRole([1])], updateRecordTime)

router.post('/cancel-slot-request-or-withdrawn', [VerifyAccessToken, CheckAuthRole([1])], slotCancelRequestOrWithdrawnRequest)

module.exports = router;
