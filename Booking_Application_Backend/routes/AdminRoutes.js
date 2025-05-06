const express = require("express");
const router = express.Router();
const {
  getUserTypes,
  getSkills,
  createUser,
  getUserList,
  editUser,
  getSecondarySkills,
  updateUserType,
  addSkill,
  addSecondarySkill,
  getSecondarySkillsAll,
  createSkillSecondarySkillRelation,
  deleteSingleOrMultipleUsers,
  restoreSingleOrMultipleUsers,
  createBulkUsers,
  getAllTabs,
  editTabName,
  updateTagLogoSetting,
  getApplicationList
} = require("../controllers/AdminController");
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const { CheckAuthRole } = require("../middlewares/auth/CheckAuthRole");

router.get("/user-types",[VerifyAccessToken, CheckAuthRole([3,5])], getUserTypes);

router.get('/skills',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getSkills)

router.get('/secondary-skills', [VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getSecondarySkills)

router.post('/create-user', createUser)

router.get('/user-list',[VerifyAccessToken, CheckAuthRole([3,5])], getUserList)

router.post('/edit-user', [VerifyAccessToken, CheckAuthRole([3,5])], editUser)

router.put('/update-usertype', [VerifyAccessToken, CheckAuthRole([3,5])], updateUserType)

router.post('/add-skill', [VerifyAccessToken, CheckAuthRole([3,5])], addSkill)

router.post('/add-secondary-skill', [VerifyAccessToken, CheckAuthRole([3,5])], addSecondarySkill)

router.get('/secondary-skills-all', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getSecondarySkillsAll)

router.post('/create-skill-secondarySkill-relation', [VerifyAccessToken, CheckAuthRole([3,5])], createSkillSecondarySkillRelation)

router.delete('/delete-users', [VerifyAccessToken, CheckAuthRole([3,5])], deleteSingleOrMultipleUsers)

router.put('/restore-user', [VerifyAccessToken, CheckAuthRole([3,5])], restoreSingleOrMultipleUsers)

router.post('/create-bulk-users', [VerifyAccessToken, CheckAuthRole([3,5])], createBulkUsers)

router.get('/get-all-tabs', [VerifyAccessToken, CheckAuthRole([3,5])], getAllTabs)

router.post('/edit-tab-name', [VerifyAccessToken, CheckAuthRole([3,5])], editTabName)

router.post('/update-tag-logo-setting', [VerifyAccessToken, CheckAuthRole([3,5])], updateTagLogoSetting)

router.get('/get-application-list', [VerifyAccessToken, CheckAuthRole([3,5])], getApplicationList)

module.exports = router;