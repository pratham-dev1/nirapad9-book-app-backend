const db = require("../models");

exports.getEmailSupportHistory = async (req, res) => {
    try {
      const data = await db.email_support.findAll({
        include: [
          {
            model: db.user,
            attributes: ['fullname', 'id'],
            as: 'user'
          },
          {
            model: db.email_support_category,
            attributes: ['name'],
            as: 'category'
          }
        ],
        order: [['id', 'desc']]
      });
      return res.status(200).json({success: true, data});
    } catch (error) {
      res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getAllUserList = async (req, res) => {
  try {
    const { searchText, page , pageSize, sortingOrder,sortingColumn, } = req.query
    const offset = page * pageSize;
    let whereCondition = {
      id: { [db.Sequelize.Op.ne]: req.user.userId },
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

exports.enableOrDisableCredentials = async (req, res) => {
  try {
    const {userId, value} = req.body;
    const user = await db.user.findByPk(userId)
    if(user.isDeleted) {
      throw {statusCode: 400, message: 'User is already deleted. Operations can not be done'}
    }
    user.isCredentialsDisabled = value
    user[value ? 'credentialDisabledTimeStamp' : 'credentialEnabledTimeStamp'] = new Date().toISOString()
    await user.save()
    return res.status(201).json({ success: true, message: 'Setting Updated'});
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getCredentialBlockedLogs = async (req, res) => {
  try {
    const data = await db.user_login_logs.findAll({
      include: {
        model: db.user,
        as: 'userDetails',
        attributes: ['lastLoginTimeStamp', 'username', 'subscriptionUpgradeTimeStamp', 'subscriptionDowngradeTimeStamp']
      },
      order: [['id', 'desc']]
    })
    return res.status(200).json({ success: true, data});
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getUsersTokenInfo = async (req, res) => {
  try {
    const data = await db.user.findAll({attributes: ['id', 'emailServiceProvider', 'email2ServiceProvider', 'email3ServiceProvider', 'emailSyncTimeStamp', 'email2SyncTimeStamp', 'email3SyncTimeStamp', 'emailSyncExpiration', 'email2SyncExpiration', 'email3SyncExpiration', 'firstTimeEmailSyncTimeStamp', 'firstTimeEmail2SyncTimeStamp', 'firstTimeEmail3SyncTimeStamp']})
    return res.status(200).json({ success: true, data});
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
} 