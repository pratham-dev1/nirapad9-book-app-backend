const express = require("express");
const router = express.Router();
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const { createNewPassword, getCalendarEvents, getUserEmailList, getOpenAvailabilityUserData, bookOpenAvailability, getOpenAvailabilityHistory, getEventColors, fetchGoogleOrMicrosoftEvents, checkExistingOpenAvailabilityOrSave, saveSlotOpenAvailability, updateExistingOpenAvailability, deleteSingleOrMultipleOpenAvailabilities, getOpenAvailabilitySlots, saveProfilePicture, getUserDetails, getNotifications,addGeneralSkills,getGeneralSkills,deleteGeneralSkills,editUserDetails, deleteProfilePicture, saveOpenAvailabilityText, saveOpenAvailabilityTag, getOpenAvailabilityTag, editOpenAvailabilityTag, deleteOpenAvailabilityTag, restoreOpenAvailabilityTag, changePassword, editSettingsUserDetails, deleteBookedSingleOpenAvailabilities, updateExistingBookedOpenAvailability, getTimezones, updateOrCreatePersonalityTraits, getPersonalityTraits, getLocation, getOrganization, getDesignation, updateTheme, createNewEvent, AddPhoneNumbers, deletePhoneNumber, addAboutMeText, notificationSettings, getEducationDetails, addEducationDetails, editEducationDetails, deleteEducationDetails, getExperienceDetails, addExperienceDetails, editExperienceDetails, deleteExperienceDetails, addSecondaryEmail, deleteSecondaryEmail, getCourse, getInstitution, getAllUserList, createGroup, groupListWithMembers, deleteGroup, editGroup, getCities, getCountries, createGroupEvent, readNotification, getGeneralTemplates, getEmbedToken, getPowerBIReport, getStates, getEducationLevel, getFieldOfStudy, getUpcomingEvents, saveEventDraft, getEventDrafts, createEmailTemplate, getUserEmailTemplates, deleteEmailTemplate, editEmailTemplate, createEventTemplate, getEventTemplates, deleteEventTemplate, editEventTemplate, previewTemplate, frequentlyUsedEvents, getSubscriptionDetails, getFeaturesList, getOrgTabNames, getEventTypes, getEventHubHistory, savePredefinedMeet, createPredefinedMeet, getPredefinedMeets, deletePredefinedMeet, editPredefinedMeet, getPredefinedMeetLocation, getPredefinedMeetType, deleteEventHubEvent, updateEventHubEvent, respondEventInvite, frequentlyMetPeople, deleteEventDraft, getContacts, addContact, deleteContact, editContact, addBulkContacts, getQuestions, addQuestion, deleteQuestion, editQuestion, submitOpenAvailabilityFeedback, saveMultipleContacts, createEmailSignature, getEmailSignature, createEventTemplateDuplicate, sendInviteOnEmail, createEmailTemplateDuplicate, createGroupDuplicate, respondAvailabilityAccept, getEventDetails, getAllUpcomingEvents, getFaq, shareOpenAvailabilityLinkViaEmail,getDashboardSearchOptions,getEndUserReports, createAdvancedEvent, checkAvailabilityForAdvancedEvent, createAdvancedEventWithoutCheckingAvailability, getTagLinkTypes, getEmailSupportCategory, emailSupport, getEmailSupportHistory ,updateUserTabActivity,getTabs, duplicateQuestion, getEmailSupportHistoryByUserId, createAdvancedEventRoundRobin, checkAvailabilityForAdvancedEventRoundRobin, getProposeNewTime, saveBlockEmailForBookingSlot, getBlockedEmailForSlots, deleteBlockedEmailForSlot, updateUsernameFlag, getOpenAvailabilityQuestionAnswer, getIndustries, activateFreeTrial, getOpenAvailabilityByTagId, updateAppGuide, getPersonalBookings} = require("../controllers/CommonController");
const { CheckAuthRole } = require("../middlewares/auth/CheckAuthRole");
const upload = require('../utils/multer');
const UserTabActivity = require("../models/CommonModels/UserTabActivityModel");
const { CheckAppAccess } = require("../middlewares/CheckAppAccess");
const {EVENT_HUB, SLOT_BROADCAST} = require("../constants/Applications")
const CacheMiddleware = require("../middlewares/CacheMiddleware");

router.post('/create-new-password', [VerifyAccessToken], createNewPassword)

router.get('/calendar-events',[VerifyAccessToken, CheckAuthRole([1,2,4,5])], getCalendarEvents)

router.get('/user-emails',[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getUserEmailList)

router.get('/open-availability-user-data', getOpenAvailabilityUserData)
 
router.get('/open-availability', getOpenAvailabilitySlots)
 
router.post('/book-open-availability', bookOpenAvailability)
 
router.get('/open-availability-history',[VerifyAccessToken, CheckAuthRole([1,2,4,5])], getOpenAvailabilityHistory)

router.get('/event-colors',[VerifyAccessToken, CheckAuthRole([1,2,4,5])], getEventColors)

router.post('/check-existing-open-availability',[VerifyAccessToken, CheckAuthRole([1,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], checkExistingOpenAvailabilityOrSave)
 
router.post("/save-slot-open-availability",[VerifyAccessToken, CheckAuthRole([1,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], saveSlotOpenAvailability);

// router.get('/fetch-calendar-events',[VerifyAccessToken, CheckAuthRole([1,2,4,5])], fetchGoogleOrMicrosoftEvents)

router.post("/update-open-availability",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], updateExistingOpenAvailability);

router.delete("/delete-open-availability",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], deleteSingleOrMultipleOpenAvailabilities);

router.post("/upload-profile-picture",[VerifyAccessToken, CheckAuthRole([1,2,4,5])],upload.single('image'), saveProfilePicture);
 
router.get("/get-user-details",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CacheMiddleware({ttl: 600})], getUserDetails);

router.post("/add-general-skills",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], addGeneralSkills);
 
router.get("/get-general-skills",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], getGeneralSkills);
 
router.post("/delete-general-skills",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], deleteGeneralSkills);
 
router.post("/edit-user-details",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], editUserDetails);

router.get("/get-notifications", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getNotifications)

router.delete("/delete-profile-picture",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], deleteProfilePicture);

router.post("/save-open-availability-text",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], saveOpenAvailabilityText)

router.post("/save-open-availability-tag",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), upload.single('image'), CheckAppAccess(SLOT_BROADCAST)], saveOpenAvailabilityTag)

router.get("/get-open-availability-tag",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(SLOT_BROADCAST)], getOpenAvailabilityTag,)

router.post("/edit-open-availability-tag",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(SLOT_BROADCAST)], upload.single('image'), editOpenAvailabilityTag)
 
router.post("/delete-open-availability-tag",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(SLOT_BROADCAST)], deleteOpenAvailabilityTag);
 
router.post("/restore-open-availability-tag",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(SLOT_BROADCAST)], restoreOpenAvailabilityTag);

router.post('/change-password', [VerifyAccessToken], changePassword)

router.post("/add-phone-numbers",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], AddPhoneNumbers);

router.delete("/delete-phone-number",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], deletePhoneNumber);

router.delete("/delete-booked-open-availability",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], deleteBookedSingleOpenAvailabilities);

router.post("/update-booked-open-availability",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], updateExistingBookedOpenAvailability);

router.get("/get-timezones", getTimezones)

router.post("/update-user-personality-traits",[VerifyAccessToken, CheckAuthRole([1,2,4,5])], updateOrCreatePersonalityTraits);

router.get('/get-location',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getLocation)
 
router.get('/get-organization',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getOrganization)
 
router.get('/get-designation',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getDesignation)
 
router.post("/update-theme",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], updateTheme);

router.post("/create-new-event",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], createNewEvent);

router.post("/add-about-me-text",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], addAboutMeText);

router.post('/notification-setting', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], notificationSettings);

router.get("/get-education-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], getEducationDetails);

router.post("/add-education-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], addEducationDetails);

router.post("/edit-education-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], editEducationDetails);

router.post("/delete-education-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], deleteEducationDetails);

router.get("/get-experience-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], getExperienceDetails);

router.post("/add-experience-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], addExperienceDetails);

router.post("/edit-experience-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], editExperienceDetails);

router.post("/delete-experience-details", [VerifyAccessToken, CheckAuthRole([1, 2, 3, 4,5])], deleteExperienceDetails);

router.post("/add-secondary-email", [VerifyAccessToken,CheckAuthRole([1,2,3,4,5])], addSecondaryEmail)

router.post("/delete-secondary-email", [VerifyAccessToken,CheckAuthRole([1,2,3,4,5])], deleteSecondaryEmail)

router.get('/get-course',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getCourse)

router.get('/get-institution',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getInstitution)

router.get("/get-all-user-list", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getAllUserList);

router.post("/create-group", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], createGroup);

router.get("/group-list-with-members", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], groupListWithMembers);

router.delete("/delete-group", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], deleteGroup);

router.post("/edit-group", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], editGroup);

router.get('/get-cities',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getCities)

router.get('/get-countries',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CacheMiddleware({common: true})], getCountries)

router.put("/read-notification", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], readNotification);

router.post("/create-group-event",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], createGroupEvent);

router.get('/get-general-templates',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getGeneralTemplates)

router.get('/get-powerbi-report',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getPowerBIReport)

router.post("/save-event-draft",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], saveEventDraft);

router.get('/get-event-drafts',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], getEventDrafts)

router.post("/create-email-template", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], createEmailTemplate);

router.get('/get-user-defined-email-templates',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getUserEmailTemplates)

router.delete("/delete-email-template", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], deleteEmailTemplate);

router.post("/edit-email-template", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], editEmailTemplate);

router.get('/get-states',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getStates)

router.get('/get-education-level',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getEducationLevel)

router.get('/get-field-of-study',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getFieldOfStudy)

router.get('/get-upcoming-events',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getUpcomingEvents)

router.post("/create-event-template", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], createEventTemplate);

router.get('/get-event-templates',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], getEventTemplates)

router.delete("/delete-event-template", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], deleteEventTemplate);

router.post("/edit-event-template", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], editEventTemplate);

router.post('/preview-template', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], previewTemplate)

router.get('/frequently-used-events', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], frequentlyUsedEvents)

router.get('/get-subscription-details', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getSubscriptionDetails)

router.get('/get-features-list', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getFeaturesList)

router.get('/get-tab-names/:userTypeId', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getOrgTabNames)

router.get('/get-event-types',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getEventTypes)

router.get('/get-event-hub-history',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getEventHubHistory)

router.post('/create-predefined-meet',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], createPredefinedMeet)

router.get('/get-predefined-meets',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], getPredefinedMeets)

router.delete("/delete-predefined-meet", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], deletePredefinedMeet);

router.post("/edit-predefined-meet", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5]), CheckAppAccess(EVENT_HUB)], editPredefinedMeet);

router.get('/get-predefined-meet-locations',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], getPredefinedMeetLocation)

router.get('/get-predefined-meet-types',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getPredefinedMeetType)

router.delete('/delete-event-hub-event',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], deleteEventHubEvent)

router.post("/update-event",[VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], updateEventHubEvent);

router.post("/respond-event-invite", [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], respondEventInvite)

router.get('/frequently-met-people', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], frequentlyMetPeople)

router.delete('/delete-event-draft',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], deleteEventDraft)

router.get('/contact-list',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getContacts)

router.post('/add-contact',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], addContact)

router.delete('/delete-contact',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], deleteContact)

router.post('/edit-contact',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], editContact)

router.post('/add-bulk-contact',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], addBulkContacts)

router.get('/question-list',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], getQuestions)

router.post('/add-question',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], addQuestion)

router.delete('/delete-question',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], deleteQuestion)

router.post('/edit-question',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], editQuestion)

router.post('/submit-open-availability-feedback', submitOpenAvailabilityFeedback)

router.post('/save-multiple-contacts',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], saveMultipleContacts)

router.post('/create-email-signature',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], createEmailSignature)

router.get('/get-email-signature',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getEmailSignature)

router.post('/create-predefined-event-duplicate',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], createEventTemplateDuplicate)

router.post('/send-invite-on-email',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], sendInviteOnEmail)

router.post('/create-predefined-email-template-duplicate',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], createEmailTemplateDuplicate)

router.post('/duplicate-group',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], createGroupDuplicate)

router.post('/respond-accept-invite',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], respondAvailabilityAccept)

router.get('/get-event-details/:eventId', [VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getEventDetails)

router.get('/get-all-upcoming-events',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getAllUpcomingEvents)

router.get('/get-faq',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getFaq)

router.post('/share-open-availability-link-via-email',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], shareOpenAvailabilityLinkViaEmail)

router.get('/get-dashboard-search-options',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getDashboardSearchOptions)

router.post('/create-advanced-event',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], createAdvancedEvent)

router.post('/check-availability-for-advanced-event',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], checkAvailabilityForAdvancedEvent)

router.post('/create-advanced-event-without-checking-availability',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], createAdvancedEventWithoutCheckingAvailability)

router.post('/update-user-tab-activity',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], updateUserTabActivity)

router.get('/get-tabs', [VerifyAccessToken, CheckAuthRole([1,2,3,4,5])], getTabs)

router.get('/get-tag-link-types',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], getTagLinkTypes)

router.get('/get-email-support-categories',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getEmailSupportCategory)

router.post('/email-support',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], emailSupport)

router.post('/duplicate-question',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], duplicateQuestion)

router.get('/get-email-support-history-by-userId',[VerifyAccessToken, CheckAuthRole([1,2,3,4])], getEmailSupportHistoryByUserId)

router.post('/create-advanced-event-round-robin',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], createAdvancedEventRoundRobin)

router.post('/check-availability-for-advanced-event-round-robin',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(EVENT_HUB)], checkAvailabilityForAdvancedEventRoundRobin)

router.get('/get-propose-new-time/:eventIdAcrossAllCalendar/:userId?',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], getProposeNewTime)

router.post('/save-block-email-for-booking-slot',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], saveBlockEmailForBookingSlot)

router.get('/get-blocked-email-for-slots',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], getBlockedEmailForSlots)

router.delete('/delete-blocked-email-for-slot',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], deleteBlockedEmailForSlot)

router.post('/update-username-flag',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5])], updateUsernameFlag)

router.get('/get-open-availability-question-answer',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], getOpenAvailabilityQuestionAnswer)

router.get('/get-industries', getIndustries)

router.post('/activate-free-trial',[VerifyAccessToken, CheckAuthRole([1,2,3,4])], activateFreeTrial)

router.get('/get-open-availability-by-tagId',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], getOpenAvailabilityByTagId)

router.post('/update-app-guide',[VerifyAccessToken, CheckAuthRole([1,2,3,4])], updateAppGuide)

router.get('/get-personal-bookings',[VerifyAccessToken, CheckAuthRole([1,3,2,4,5]), CheckAppAccess(SLOT_BROADCAST)], getPersonalBookings)


module.exports = router;