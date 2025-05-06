const { Sequelize, DataTypes } = require("sequelize");
const dbConfig = require("../config/dbConfig");

const sequelize = new Sequelize({
    dialect: dbConfig.DIALECT,
    host: dbConfig.HOST,
    username: dbConfig.USER,
    password: dbConfig.PASSWORD,
    database: dbConfig.DB,
    port: dbConfig.PORT,
    logging: dbConfig.LOGGING
});

sequelize.authenticate().then(() => {
    console.log(`Database connected to discover`);
}).catch((err) => {
    console.log(err);
});

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

//boooking application models

db.availability = require("./TalentPartnerModels/AvailabilityModel")(sequelize, DataTypes);
db.user_type = require("./adminModels/UserTypeModel")(sequelize, DataTypes);
db.skill = require("./adminModels/SkillModel")(sequelize, DataTypes);
db.user = require("./adminModels/UserModel")(sequelize, DataTypes);
db.secondary_skill = require("./adminModels/SecondarySkillModel")(sequelize, DataTypes);
db.event = require("./CommonModels/EventModel")(sequelize, DataTypes);
db.zoho_form = require("./RecruiterModel/ZohoFormModel")(sequelize, DataTypes);
db.otp = require("./CommonModels/OtpModel")(sequelize, DataTypes);
db.user_verification = require("./CommonModels/UserVerificationModel")(sequelize, DataTypes);
db.open_availability = require("./CommonModels/OpenAvailabilityModel")(sequelize, DataTypes)
db.event_color = require("./CommonModels/EventColorModel")(sequelize, DataTypes)
db.user_ip = require("./CommonModels/UserIpModel")(sequelize, DataTypes)
db.password_verification_key = require("../models/CommonModels/PasswordVerificationKeyModel")(sequelize, DataTypes)
db.notification = require("./CommonModels/NotificationModel")(sequelize, DataTypes)
db.user_associated_general_skill = require("./CommonModels/UserAssociatedGeneralSkillsModel")(sequelize, DataTypes)
db.user_associated_general_secondary_skill = require("./CommonModels/UserAssociatedGeneralSecondarySkillsModel")(sequelize, DataTypes)
db.open_availability_tags = require("./CommonModels/OpenAvailabilityTagModel")(sequelize, DataTypes)
db.timezone = require("./CommonModels/TimezoneModel")(sequelize, DataTypes)
db.user_personality_trait = require("./CommonModels/UserPersonalityTraitModel")(sequelize, DataTypes)
db.designation = require("./CommonModels/DesignationModel")(sequelize, DataTypes)
db.location = require("./CommonModels/LocationModel")(sequelize, DataTypes)
db.organization = require("./CommonModels/OrganizationModel")(sequelize, DataTypes)
db.education_details = require("./CommonModels/EducationDetailsModel")(sequelize, DataTypes);
db.experience_details = require("./CommonModels/ExperienceDetailsModel")(sequelize, DataTypes);
db.course = require("./CommonModels/CourseModel")(sequelize, DataTypes)
db.institution = require("./CommonModels/InstitutionModel")(sequelize, DataTypes)
db.group = require("./CommonModels/GroupModel")(sequelize, DataTypes);
db.userSuggestedCourse = require("./CommonModels/UserSuggestedCourseModel")(sequelize, DataTypes)
db.userSuggestedDesignation = require("./CommonModels/UserSuggestedDesignationModel")(sequelize, DataTypes)
db.userSuggestedInstitution = require("./CommonModels/UserSuggestedInstitutionModel")(sequelize, DataTypes)
db.userSuggestedOrganization = require("./CommonModels/UserSuggestedOrganizationModel")(sequelize, DataTypes)
db.cities = require("./CommonModels/CityModel")(sequelize, DataTypes)
db.countries = require("./CommonModels/CountryModel")(sequelize, DataTypes)
db.general_template = require("./CommonModels/GeneralTemplatesModel")(sequelize, DataTypes)
db.subscription = require("./CommonModels/SubscriptionModel")(sequelize, DataTypes)
db.ba_organization = require("./OrganizationModels/BaOrganizationModel")(sequelize, DataTypes)
db.event_draft = require("./CommonModels/EventDraftModel")(sequelize, DataTypes)
db.user_defined_email_template = require("./CommonModels/UserDefinedEmailTemplateModel")(sequelize, DataTypes)
db.states = require("./CommonModels/StateModel")(sequelize, DataTypes)
db.fieldOfStudy = require("./CommonModels/FieldOfStudyModel")(sequelize, DataTypes)
db.educationLevel = require("./CommonModels/EducationLevelModel")(sequelize, DataTypes)
db.predefined_event = require("./CommonModels/PredefinedEventModel")(sequelize, DataTypes)
db.powerbi_report = require("./CommonModels/PowerBIReportModel")(sequelize, DataTypes)
db.user_current_location = require("./CommonModels/UserCurrentLocationModel")(sequelize, DataTypes)
db.feature_list = require("./CommonModels/FeaturesListModel")(sequelize, DataTypes)
db.subscription_feature = require("./CommonModels/SubscriptionFeaturesModel")(sequelize, DataTypes)
db.tabs = require("./CommonModels/TabModel")(sequelize, DataTypes)
db.org_tabs = require("./CommonModels/OrgTabModel")(sequelize, DataTypes)
db.event_types = require("./CommonModels/EventTypeModel")(sequelize, DataTypes)
db.event_hub_events = require("./CommonModels/EventHubEventsModel")(sequelize, DataTypes)
db.predefined_meet = require("./CommonModels/PredefinedMeetModel")(sequelize, DataTypes)
db.predefined_meet_location = require("./CommonModels/PredefinedMeetLocationModel")(sequelize, DataTypes)
db.predefined_meet_type = require("./CommonModels/PredefinedMeetTypeModel")(sequelize, DataTypes)
db.contact = require("./CommonModels/ContactModel")(sequelize, DataTypes)
db.question = require("./CommonModels/QuestionModel")(sequelize, DataTypes)
db.open_availability_feedback = require("./CommonModels/OpenAvailabilityFeedbackModel")(sequelize, DataTypes)
db.user_email_signature = require("./CommonModels/UserEmailSignatureModel")(sequelize, DataTypes)
db.open_availability_tag_verification = require("./CommonModels/OpenAvailabilityTagVerificationModel")(sequelize, DataTypes)
db.open_availability_tag_question = require("./CommonModels/OpenAvailabilityTagQuestionRelation")(sequelize, DataTypes)
db.status = require("./CommonModels/StatusModel")(sequelize, DataTypes)  
db.faq = require("./CommonModels/FaqModel")(sequelize, DataTypes)
db.dashboard_search_options = require("./CommonModels/DashboardSearchOptionModel")(sequelize, DataTypes)
db.organization_resources = require("./OrganizationModels/OrganizationResource")(sequelize, DataTypes)
db.resources = require("./OrganizationModels/Resources")(sequelize, DataTypes)
db.user_tab_activities=require("./CommonModels/UserTabActivityModel")(sequelize, DataTypes)
db.booking_application_tabs=require("./CommonModels/TabsModel")(sequelize, DataTypes)
db.tag_link_type = require("./CommonModels/TagLinkTypeModel")(sequelize, DataTypes)
db.email_support_category = require("./CommonModels/EmailSupportCategoryModel")(sequelize, DataTypes)
db.email_support = require("./CommonModels/EmailSupportModel")(sequelize, DataTypes)
db.user_login_logs = require("./CommonModels/UserLoginLogsModel")(sequelize, DataTypes)
db.propose_new_time = require("./CommonModels/ProposeNewTimeModel")(sequelize, DataTypes)
db.blocked_email_by_slot_broadcaster = require("./CommonModels/BlockedEmailBySlotBroadcasterModel")(sequelize, DataTypes)
db.applications = require("./CommonModels/ApplicationsModel")(sequelize, DataTypes)
db.app_access = require("./CommonModels/AppAccessModel")(sequelize, DataTypes)
db.industry = require("./CommonModels/IndustriesModel")(sequelize, DataTypes)



//timesheet models
db.project = require("./TimeSheetModels/ProjectsModel")(sequelize, DataTypes)
db.timesheet = require("./TimeSheetModels/TimeSheetModel")(sequelize, DataTypes)


//crm internal models
db.crm_internal_user = require("./CrmInternalModels/CrmInternalUserModel")(sequelize, DataTypes)
db.crm_internal_lead_info = require("./CrmInternalModels/LeadInfoModel")(sequelize, DataTypes)
db.crm_internal_lead_contact_info = require("./CrmInternalModels/LeadContactInfoModel")(sequelize, DataTypes)
db.crm_internal_lead_company_info = require("./CrmInternalModels/LeadCompanyInfoModel")(sequelize, DataTypes)
db.crm_internal_lead_notes = require("./CrmInternalModels/LeadNotesModel")(sequelize, DataTypes)
db.crm_internal_lead_tag = require("./CrmInternalModels/LeadTagsModel")(sequelize, DataTypes)
db.crm_internal_email_communication_status = require("./CrmInternalModels/EmailCommunicationStatusModel")(sequelize, DataTypes)
db.crm_internal_phone_communication_status = require("./CrmInternalModels/PhoneCommunicationStatusModel")(sequelize, DataTypes)
db.crm_internal_LinkedIn_communication_status = require("./CrmInternalModels/LinkedInCommunicationStatusModel")(sequelize, DataTypes)
db.crm_internal_communication_status = require("./CrmInternalModels/CommunicationStatusModel")(sequelize, DataTypes)
db.crm_internal_user_type = require("./CrmInternalModels/CrmUserTypeModel")(sequelize, DataTypes)

//user and userType relation
db.user_type.hasMany(db.user, { foreignKey: 'userTypeId', as: 'usertype' })
db.user.belongsTo(db.user_type, { foreignKey: 'userTypeId', as: 'usertype' });

//skill and secondary_skill relation
db.skill.belongsToMany(db.secondary_skill, { through: 'skill_secondary_skills', timestamps: false })
db.secondary_skill.belongsToMany(db.skill, { through: 'skill_secondary_skills', timestamps: false });

//user and skill relation
db.user.belongsToMany(db.skill, { through: 'tp_skills', timestamps: false });
db.skill.belongsToMany(db.user, { through: 'tp_skills', timestamps: false });

// user and secondary_skill relation
db.user.belongsToMany(db.secondary_skill, { through: 'tp_secondary_skills', timestamps: false, as: "secondarySkills" });
db.secondary_skill.belongsToMany(db.user, { through: 'tp_secondary_skills', timestamps: false, as: "secondarySkills" });

//user and availability relation    
db.user.hasMany(db.availability, { foreignKey: 'tpId' });
db.availability.belongsTo(db.user, { foreignKey: 'tpId' });

//availability relation with skill 
db.availability.belongsToMany(db.skill, { through: 'availability_skills', timestamps: false });
db.skill.belongsToMany(db.availability, { through: 'availability_skills', timestamps: false });

//availability relation with secondary_skill
db.availability.belongsToMany(db.secondary_skill, { through: 'availability_secondary_skills', timestamps: false, as: "availabilitySecondarySkills" });
db.secondary_skill.belongsToMany(db.availability, { through: 'availability_secondary_skills', timestamps: false, as: "availabilitySecondarySkills" });

//skill relation with zoho forms
db.skill.belongsToMany(db.zoho_form, { through: 'skill_zoho_forms', timestamps: false })
db.zoho_form.belongsToMany(db.skill, { through: 'skill_zoho_forms', timestamps: false });

// user relation with event table
db.user.hasMany(db.event, { foreignKey: 'userId' });
db.event.belongsTo(db.user, { foreignKey: 'userId' });

// user relation with event_color with different foreign keys
db.event_color.hasMany(db.user, { foreignKey: 'eventColorForEmail', as: 'colorForEmail1' });
db.user.belongsTo(db.event_color, { foreignKey: 'eventColorForEmail', as: 'colorForEmail1' });
db.event_color.hasMany(db.user, { foreignKey: 'eventColorForEmail2', as: 'colorForEmail2' });
db.user.belongsTo(db.event_color, { foreignKey: 'eventColorForEmail2', as: 'colorForEmail2' });
db.event_color.hasMany(db.user, { foreignKey: 'eventColorForEmail3', as: 'colorForEmail3' });
db.user.belongsTo(db.event_color, { foreignKey: 'eventColorForEmail3', as: 'colorForEmail3' });

//user relation with open availability
db.user.hasMany(db.open_availability, { foreignKey: 'userId' });
db.open_availability.belongsTo(db.user, { foreignKey: 'userId' });

//user relation with user_verification
db.user.hasMany(db.user_verification, { foreignKey: 'userId' });
db.user_verification.belongsTo(db.user, { foreignKey: 'userId' });

//availability relation with skill all searched
db.availability.belongsToMany(db.skill, { through: 'availability_skills_searched', timestamps: false, as: "availabilitySkillsSearched" });
db.skill.belongsToMany(db.availability, { through: 'availability_skills_searched', timestamps: false, as: "availabilitySkillsSearched" });

//availability relation with secondary_skill all searched
db.availability.belongsToMany(db.secondary_skill, { through: 'availability_secondary_skills_searched', timestamps: false, as: "availabilitySecondarySkillsSearched" });
db.secondary_skill.belongsToMany(db.availability, { through: 'availability_secondary_skills_searched', timestamps: false, as: "availabilitySecondarySkillsSearched" });

db.user.belongsToMany(db.skill, { through: 'user_general_skills', timestamps: false, as: "generalSkills" });
db.skill.belongsToMany(db.user, { through: 'user_general_skills', timestamps: false, as: "generalSkills" });

db.user.belongsToMany(db.secondary_skill, { through: 'user_general_secondary_skills', timestamps: false, as: "generalSecondarySkills" });
db.secondary_skill.belongsToMany(db.user, { through: 'user_general_secondary_skills', timestamps: false, as: "generalSecondarySkills" });

db.project.hasOne(db.timesheet, { foreignKey: 'projectId' });
db.timesheet.belongsTo(db.project, { foreignKey: 'projectId' });

//open availability relation with events
db.open_availability.hasMany(db.event, { foreignKey: 'meetingLink', sourceKey: 'meetingLink', constraints: false });


// availability relation with events
db.availability.hasMany(db.event, { foreignKey: 'meetingLink', sourceKey: 'meetingLink', constraints: false });
db.event.belongsTo(db.availability, { foreignKey: 'meetingLink', sourceKey: 'meetingLink', constraints: false })

//timezone and user relation
db.user.belongsTo(db.timezone, { foreignKey: 'timezoneId', as: 'timezone' })

// user relation with personality traits
db.user.hasOne(db.user_personality_trait, { foreignKey: 'userId', as: 'userPersonalityTrait' })
db.user_personality_trait.belongsTo(db.user, { foreignKey: 'userId', as: 'userPersonalityTrait' })

//user and designation relation
db.user.belongsTo(db.designation, { foreignKey: 'designationId', as: 'designation' })

//user and location relation
db.user.belongsTo(db.location, { foreignKey: 'locationId', as: 'location' })

//user and organization relation
db.user.belongsTo(db.organization, { foreignKey: 'organizationId', as: 'organization' })

db.contact.belongsToMany(db.group,{ through: 'group_members', timestamps: false, as: 'groupMembers' })
db.group.belongsToMany(db.contact,{ through: 'group_members', timestamps: false, as: 'groupMembers' })

// leadinfo and leadContactInfo relation
db.crm_internal_lead_info.hasOne(db.crm_internal_lead_contact_info, { foreignKey: 'leadId', as: 'leadContactInfo' })
db.crm_internal_lead_contact_info.belongsTo(db.crm_internal_lead_info, { foreignKey: 'leadId', as: 'leadContactInfo' })

// leadinfo and leadCompanyInfo relation
db.crm_internal_lead_info.hasOne(db.crm_internal_lead_company_info, { foreignKey: 'leadId', as: 'leadCompanyInfo' })
db.crm_internal_lead_company_info.belongsTo(db.crm_internal_lead_info, { foreignKey: 'leadId', as: 'leadCompanyInfo' })

// leadinfo and leadCompanyInfo relation
db.crm_internal_lead_info.hasOne(db.crm_internal_lead_notes, { foreignKey: 'leadId', as: 'leadNotes' })
db.crm_internal_lead_notes.belongsTo(db.crm_internal_lead_info, { foreignKey: 'leadId', as: 'leadNotes' })

db.crm_internal_lead_info.hasOne(db.crm_internal_lead_tag, { foreignKey: 'leadId', as: 'leadTags' })
db.crm_internal_lead_tag.belongsTo(db.crm_internal_lead_info, { foreignKey: 'leadId', as: 'leadTags' })

db.crm_internal_communication_status.hasOne(db.crm_internal_lead_info, { foreignKey: 'communicationStatus', as: 'communicationStatusDetails' })
db.crm_internal_lead_info.belongsTo(db.crm_internal_communication_status, { foreignKey: 'communicationStatus', as: 'communicationStatusDetails' })

db.user.hasMany(db.education_details, { foreignKey: 'userId' })
db.education_details.belongsTo(db.user, { foreignKey: 'userId' });

db.user.hasMany(db.experience_details, { foreignKey: 'userId' })
db.experience_details.belongsTo(db.user, { foreignKey: 'userId' });

//ExperienceDetails and designation relation
db.experience_details.belongsTo(db.designation, { foreignKey: 'designationId', as: 'experience_detailsDesignation' })
//ExperienceDetails and organization relation
db.experience_details.belongsTo(db.organization, { foreignKey: 'organizationId', as: 'experience_detailsOrganization' })
//ExperienceDetails and designation relation
db.experience_details.belongsTo(db.userSuggestedDesignation, { foreignKey: 'userSuggestedDesignationId', as: 'experience_detailsUserSuggestedDesignation' })
//ExperienceDetails and organization relation
db.experience_details.belongsTo(db.userSuggestedOrganization, { foreignKey: 'userSuggestedOrganizationId', as: 'experience_detailsUserSuggestedOrganization' })


//EducationDetails and institution relation
db.education_details.belongsTo(db.institution, { foreignKey: 'institutionId', as: 'education_detailsInstitution' })
//EducationDetails and course relation
db.education_details.belongsTo(db.course, { foreignKey: 'courseId', as: 'education_detailsCourse' })
//EducationDetails and institution relation
db.education_details.belongsTo(db.educationLevel, { foreignKey: 'educationLevelId', as: 'education_detailsEducationLevel' })

//EducationDetails and Field of study relation
db.education_details.belongsTo(db.fieldOfStudy, { foreignKey: 'fieldOfStudyId', as: 'education_detailsFieldOfStudy' })

db.education_details.belongsTo(db.userSuggestedInstitution, { foreignKey: 'userSuggestedInstitutionId', as: 'education_detailsUserSuggestedInsitution' })
//EducationDetails and course relation
db.education_details.belongsTo(db.userSuggestedCourse, { foreignKey: 'userSuggestedCourseId', as: 'education_detailsUserSuggestedCourse' })

//User Suggested Organization and city relation
db.userSuggestedOrganization.belongsTo(db.cities, { foreignKey: 'cityId'})
//User Suggested Organization and country relation
db.userSuggestedOrganization.belongsTo(db.countries, { foreignKey: 'countryId'})

//User current Location relation with City
db.user_current_location.belongsTo(db.cities, {foreignKey: 'currentCityId'})

//City realtion with states
db.cities.belongsTo(db.states, { foreignKey: 'stateId'})
//State relation with country
db.states.belongsTo(db.countries, { foreignKey: 'countryId'})

db.feature_list.hasMany(db.subscription_feature, { foreignKey: 'featureId' });
db.subscription_feature.belongsTo(db.feature_list, { foreignKey: 'featureId' });

db.tabs.hasMany(db.org_tabs, {foreignKey: 'tabId'})
db.org_tabs.belongsTo(db.tabs, {foreignKey: 'tabId'})

db.open_availability_tags.belongsToMany(db.user,{ through: 'tag_members', timestamps: false, as: 'tagMembers' })
db.user.belongsToMany(db.open_availability_tags,{ through: 'tag_members', timestamps: false, as: 'tagMembers' })

db.open_availability_tags.belongsToMany(db.question,{ through: db.open_availability_tag_question, timestamps: false, as: 'openAvailabilityQuestions' })
db.question.belongsToMany(db.open_availability_tags,{ through: db.open_availability_tag_question, timestamps: false, as: 'openAvailabilityQuestions' })

db.user_defined_email_template.belongsTo(db.predefined_meet_type, { foreignKey: 'predefinedMeetTypeId' })

db.predefined_event.belongsTo(db.predefined_meet, {foreignKey: 'predefinedMeetId'})

db.user_email_signature.belongsTo(db.organization, {foreignKey: 'organizationId'})

db.event_draft.belongsTo(db.predefined_meet, {foreignKey: 'predefinedMeetId'})

db.notification.belongsTo(db.open_availability, {foreignKey: 'openAvailabilityId', as: 'openAvailabilityData'})


db.open_availability_tags.hasMany(db.open_availability, {
    foreignKey: 'tagId',
    as: 'tagData', 
  });


db.open_availability.belongsTo(db.open_availability_tags, {
    foreignKey: 'tagId',
    as: 'tagData', 
  });


db.ba_organization.hasMany(db.user, { foreignKey: 'baOrgId', as: 'baOrgData' })
db.user.belongsTo(db.ba_organization, { foreignKey: 'baOrgId', as: 'baOrgData' });

db.user.hasMany(db.email_support, { foreignKey: 'userId', as: 'user' })
db.email_support.belongsTo(db.user, { foreignKey: 'userId', as: 'user' });

db.email_support_category.hasMany(db.email_support, { foreignKey: 'categoryId', as: 'category' })
db.email_support.belongsTo(db.email_support_category, { foreignKey: 'categoryId', as: 'category' });

db.user.hasMany(db.user_login_logs, { foreignKey: 'userId', as: 'userDetails' })
db.user_login_logs.belongsTo(db.user, { foreignKey: 'userId', as: 'userDetails' });

db.open_availability_tags.hasOne(db.blocked_email_by_slot_broadcaster, { foreignKey: 'tagId', as: 'tagDetails' })
db.blocked_email_by_slot_broadcaster.belongsTo(db.open_availability_tags, { foreignKey: 'tagId', as: 'tagDetails' })

db.user.belongsToMany(db.applications, { through: db.app_access, timestamps: false, as: 'appAccess' });
db.applications.belongsToMany(db.user, { through: db.app_access, timestamps: false, as: 'appAccess' });

db.open_availability.hasMany(db.open_availability_feedback, { foreignKey: 'openAvailabilityId', as: 'questionDetails' })
db.open_availability_feedback.belongsTo(db.open_availability, { foreignKey: 'openAvailabilityId', as: 'questionDetails' });

db.cities.hasOne(db.open_availability_tags, { foreignKey: 'city', as: 'cityDetails' })
db.open_availability_tags.belongsTo(db.cities, { foreignKey: 'city', as: 'cityDetails' })

db.states.hasOne(db.open_availability_tags, { foreignKey: 'state', as: 'stateDetails' })
db.open_availability_tags.belongsTo(db.states, { foreignKey: 'state', as: 'stateDetails' })

db.countries.hasOne(db.open_availability_tags, { foreignKey: 'country', as: 'countryDetails' })
db.open_availability_tags.belongsTo(db.countries, { foreignKey: 'country', as: 'countryDetails' })

db.cities.hasOne(db.open_availability, { foreignKey: 'city', as: 'cityDetail' })
db.open_availability.belongsTo(db.cities, { foreignKey: 'city', as: 'cityDetail' })

db.states.hasOne(db.open_availability, { foreignKey: 'state', as: 'stateDetail' })
db.open_availability.belongsTo(db.states, { foreignKey: 'state', as: 'stateDetail' })

module.exports = db;