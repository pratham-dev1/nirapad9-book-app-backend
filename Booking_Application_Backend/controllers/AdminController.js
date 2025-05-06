const db = require("../models");
const { hashPassword } = require("../utils/bcrypt");
const { Op } = require('sequelize');
const { emailNotification } = require("../utils/emailNotification");
const crypto = require('crypto');
const { CLIENT_URL } = require("../config/urlsConfig");
const { sendNotification } = require("../utils/mailgun");
const csv = require('csv-parser')
const { Readable } = require('stream');
const { generateRandomPassword } = require("../utils/generateRandomPassword");
const dayjs = require("dayjs");
const { CreateStripeCustomer } = require("../utils/CreateStripeCustomer");
const Applications = require("../constants/Applications");

exports.getUserTypes = async (req, res) => {
  try {
    const response = await db.user_type.findAll({
      order: [['id', 'ASC']],
    });
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getSkills = async (req, res) => {
  try {
    const response = await db.skill.findAll();
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getSecondarySkills = async (req, res) => {
  try {
    const {  primarySkillIds  } = req.query;
    let whereClause = {};
    if (primarySkillIds && primarySkillIds.length>0) {
      whereClause = {
        id: primarySkillIds
      };
    }
    const response = await db.secondary_skill.findAll({
      attributes: ['id', 'secondarySkillName'],
      include: [
        {    
          model: db.skill,
          attributes: [],
          where: whereClause,
       },]
    });
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error:true,message: error.message || 'Something went wrong' });
  }
}

exports.createUser = async (req, res) => {
  try {
    let { username, fullname, email, usertype, password, skills, secondarySkills, orgId, appAccess, business, industry } = req.body;
    email = email.toLowerCase();
    username = username.toLowerCase();
    const isStrongPassword = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+])[A-Za-z\d!@#$%^&*()_+]{8,28}$/;
    if (!isStrongPassword.test(password)) {
      return res.status(400).json({ error: true, message: 'Password must be 8 to 28 characters long and contain at least one lowercase letter, one uppercase letter, one number, and one special character.' });
    }
    const hashedPassword = await hashPassword(password);

    const user = await db.user.create({ username, fullname, email, userTypeId: usertype, password: hashedPassword,temporaryPassword: password, eventColorForEmail: 1, baOrgId: orgId, theme: 'thm-blue', createdAt: new Date().toISOString(), isUsernameUpdated: true, business, industry });
    if (skills) {
      await user.setSkills(skills); // will create record in relation table (tp_skills) for each skillId
    }
    if (secondarySkills) {
      await user.setSecondarySkills(secondarySkills)
    }
    if(appAccess) {
      await user.setAppAccess(appAccess)
    }
    else {
      await user.setAppAccess([Applications.SLOT_BROADCAST])  // providing slot broadcast access by default
    }
    await CreateStripeCustomer(user.id)
    let key = crypto.randomBytes(40).toString('hex');
    await db.user_verification.create({email, accountVerifyKey: key, userId: user.id})
    const ClientUrl = req.headers.origin;
    const content = `Click on below link to verify your account <br/> <a href=${ClientUrl}/verify-account/${user.id}/${key}>${ClientUrl}/verify-account/${user.id}/${key}</a>`
    sendNotification(user.email,'Verify Your account', content)
    // await emailNotification(user.email, 'Verify Your account', content);
    return res.status(200).json({ success: true, data: user, message: 'User Created Successfully!!!' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editUser = async (req, res) => {
  try {
    let { id, username, fullname, email, usertype, password, skills, secondarySkills, subscription, appAccess } = req.body;
    email = email.toLowerCase();
    username = username.toLowerCase();
    const isStrongPassword = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+])[A-Za-z\d!@#$%^&*()_+]{8,28}$/;
    if (password && !isStrongPassword.test(password)) {
      return res.status(400).json({ error: true, message: 'Password must be 8 to 28 characters long and contain at least one lowercase letter, one uppercase letter, one number, and one special character.' });
    }
    const user = await db.user.findByPk(id);
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }

    user.username = username;
    user.fullname = fullname;
    user.email = email;
    user.userTypeId = usertype;
    user.subscriptionId = subscription

    if (password) {
      const hashedPassword = await hashPassword(password);
      user.password = hashedPassword;
    }

    await user.save();
    if(password) {                                 // Making sure password should be updated in db first then email will trigger
      const content = `<p>Your Password has been reset by Admin</p> <br/> <p>New Password: ${password}<b></b> </p>`
      sendNotification(user.email, 'Password Updated', content)
    }

    if (skills) {
      await user.setSkills(skills); // will create record in relation table (tp_skills) for each skillId
    }
    if (secondarySkills) {
      await user.setSecondarySkills(secondarySkills)
    }
    if(appAccess) {
      await user.setAppAccess(appAccess)
    }
    return res.status(200).json({ success: true, data: user, message: 'User Updated Successfully!!!' });
  } catch (error) {
    return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.getUserList = async (req, res) => {
  try {
    const { searchText, page , pageSize, sortingOrder,sortingColumn, } = req.query
    const offset = page * pageSize;
    let whereCondition = {
      id: { [db.Sequelize.Op.ne]: req.user.userId },
      baOrgId: req.user.orgId
    }
    if (searchText) {
      whereCondition[db.Sequelize.Op.or] = [
        db.Sequelize.where(db.Sequelize.col('user.username'), 'ILIKE', `%${searchText}%`),
        db.Sequelize.where(db.Sequelize.col('user.fullname'), 'ILIKE', `%${searchText}%`),
        db.Sequelize.where(db.Sequelize.col('user.email'), 'ILIKE', `%${searchText}%`),
        db.Sequelize.where(db.Sequelize.cast(db.Sequelize.col('user.id'), 'text'), 'ILIKE', `%${searchText}%`),
      ];
    }
    const users = await db.user.findAndCountAll({
      attributes: { exclude: ['password', 'emailAccessToken', 'emailRefreshToken', 'email2AccessToken', 'email2RefreshToken', 'email3AccessToken', 'email3RefreshToken'] },
      include: [
        { model: db.user_type, as: 'usertype' },
        { model: db.skill, as: 'skills', through: { attributes: [] } },
        { model: db.secondary_skill, as: 'secondarySkills', through: { attributes: [] } },
        { model: db.user_verification, attributes: ['isAccountVerified','email']},
        { model: db.applications, as: 'appAccess', through: { attributes: [] }}
      ],
      where: whereCondition,
      limit: pageSize,
      offset: offset,
      order: [[sortingColumn, sortingOrder]]
    })
    return res.status(200).json({ success: true, data: users.rows , totalCount: users.count});

  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.updateUserType = async (req, res) => {
  const { id, userType } = req.body;
  try {
    await db.user_type.update({ userType }, { where: { id } })
    return res.status(200).json({ success: true, message: 'UserType updated successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addSkill = async (req, res) => {
  try {
    const { skill } = req.body;
    await db.skill.create({ skillName: skill });

    return res.status(200).json({ success: true, message: 'Skill added Successfully!!!' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addSecondarySkill = async (req, res) => {
  try {
    const { secondarySkill } = req.body;
    await db.secondary_skill.create({ secondarySkillName: secondarySkill });

    return res.status(200).json({ success: true, message: 'Secondary Skill added Successfully!!!' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getSecondarySkillsAll = async (req, res) => {
  try {
    const response = await db.secondary_skill.findAll();
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createSkillSecondarySkillRelation = async (req, res) => {
  try {
    const { skillId, secondarySkillIds } = req.body;
    const skill = await db.skill.findOne({
      where: {
        id: skillId
      }
    });
    if (secondarySkillIds) {
      await skill.setSecondary_skills(secondarySkillIds);
    }

    return res.status(200).json({ success: true, message: 'Relation Created Successfully!!!' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteSingleOrMultipleUsers = async (req, res) => {
  try {
    const { ids } = req.body;
    const [deletedCount, deletedRecords] = await db.user.update({ isDeleted: true }, { where: { id: ids }, returning: true });
    for (const item of deletedRecords) {
      sendNotification(item.email,'Account Deleted', 'Your account has been deleted')
      // await emailNotification(item.email, 'Account Deleted', 'Your account has been deleted');
    }
    return res.status(201).json({ success: true, message: 'Users deleted successfully' });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.restoreSingleOrMultipleUsers = async (req, res) => {
  try {
    const { userIds } = req.body;
    const [restoredCount, restoreRecords] = await db.user.update({ isDeleted: null }, { where: { id: userIds }, returning: true });
    for (const item of restoreRecords) {
      sendNotification(item.email,'Account Restored', 'Your account has been Restored')
    }
    return res.status(201).json({ success: true, message: 'Users Restored successfully' });
    
  } 
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createBulkUsers = async (req, res) => {
  try {
    const { csvFileBase64Data } = req.body;
    const csvData = Buffer.from(csvFileBase64Data, 'base64').toString('utf-8');
    const results = [];
    const stream = Readable.from(csvData.split('\n'));
    stream.pipe(csv()).on('data', (data) => {
      results.push(data);
    }).on('end', async () => {
      try {
    let failedRecords = []
    let savedRecords = []
        for (const item of results) {
      const usertype = await db.user_type.findOne({ where: { userType: item?.usertype } })
      const email = item?.email.toLowerCase();
      const username = item?.username.toLowerCase();
      const randomPassword = generateRandomPassword();
      const hashedPassword = await hashPassword(randomPassword);
      let transaction;
      try {
        transaction = await db.sequelize.transaction();
        const userData = { ...item, email: email, username: username, userTypeId: usertype?.id, password: hashedPassword, temporaryPassword: randomPassword }
        const createdUser = await db.user.create(userData, { transaction });
        savedRecords.push(createdUser);
        await transaction.commit();
      } catch (error) {
        if (transaction) await transaction.rollback();
        failedRecords.push({ userData: item, message: error.message });
      }
    }
    const ClientUrl = req.headers.origin;
    for (const user of savedRecords) {
      let key = crypto.randomBytes(40).toString('hex');
      await db.user_verification.create({ email: user.email, accountVerifyKey: key, userId: user.id })
      const content = `Click on below link to verify your account <br/> <a href=${ClientUrl}/verify-account/${user.id}/${key}>${ClientUrl}/verify-account/${user.id}/${key}</a>`
      sendNotification(user.email, 'Verify Your account', content)
    }
    if (failedRecords.length > 0) {
      return res.status(200).json({ warning: true, message: 'Some records were not saved', failedRecords: failedRecords });
    }
    return res.status(200).json({ success: true, message: 'Users Added successfully' })
      }
      catch (error) {
        console.error('Error : ', error);
        return res.status(500).json({ error: true, message: error?.message || 'Something went wrong' });
      }
    })
      .on('error', (error) => {
        console.error('Error parsing CSV:', error);
        return res.status(500).json({ error: true, message: 'Internal Server Error' }); // Send error status
      });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getAllTabs = async (req, res) => {
  const orgId = req.user.orgId;
  try {
    const data = await db.org_tabs.findAll({
      where: {orgId}, 
      attributes: ['id','tabNameOrgGiven', 'tabId'],
      order: [['tabId', 'asc']],
      include: {
        model: db.tabs,
        attributes: []
      }
    });
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editTabName = async (req, res) => {
  try {
    const {tabId, tabNameOrgGiven} = req.body;
    const orgId = req.user.orgId;
    await db.org_tabs.update({tabNameOrgGiven}, {where: {tabId, orgId}})
    return res.status(201).json({success: true, message: "Tab name updated"});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.updateTagLogoSetting = async (req, res) => {
  try {
    const {isDisabled, orgId} = req.body;
    await db.ba_organization.update({isOrgDisabledTagLogo: isDisabled}, {where: {id: orgId}})
    return res.status(201).json({success: true, message: 'Updated'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getApplicationList = async (req, res) => {
  try {
    const data = await db.applications.findAll()
    return res.status(200).json({success: true, data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}