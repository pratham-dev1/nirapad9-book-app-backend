module.exports = (sequelize, DataTypes) => {
  const Users = sequelize.define("user", {
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: {
        msg: 'Username is already in use',
      },
      validate: {
        noSpaces(value) {
          if (/\s/.test(value)) {
            throw new Error("Username can't contain spaces");
          }
        },
        noAtSymbol(value) {
          if (/@/.test(value)) {
            throw new Error("Username can't contain '@' symbol");
          }
        }
      }
    },
    fullname: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: {
        msg: 'Email address is already in use',
      },
      validate: {
        isEmail: {
          msg: 'Invalid email address',
        },
      },
    },
    emailServiceProvider: {
      type: DataTypes.STRING,
    },
    email2:{
      type: DataTypes.STRING,
    },
    email2ServiceProvider: {
      type: DataTypes.STRING,
    },
    email3:{
      type: DataTypes.STRING,
    },
    email3ServiceProvider: {
      type: DataTypes.STRING,
    },
    userTypeId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    isPasswordUpdated: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false
    },
    isDeleted: {
      type: DataTypes.BOOLEAN,
    },
    emailAccessToken: {
      type: DataTypes.TEXT,
    },
    emailRefreshToken: {
      type: DataTypes.TEXT,
    },
    email2AccessToken: {
      type: DataTypes.TEXT,
    },
    email2RefreshToken: {
      type: DataTypes.TEXT,
    },
    email3AccessToken: {
      type: DataTypes.TEXT,
    },
    email3RefreshToken: {
      type: DataTypes.TEXT,
    },
    passwordUpdatedCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    temporaryPassword: {
      type: DataTypes.STRING,
    },
    eventColorForEmail: {
      type: DataTypes.INTEGER,
    },
    eventColorForEmail2: {
      type: DataTypes.INTEGER,
    },
    eventColorForEmail3: {
      type: DataTypes.INTEGER,
    },
    profilePicture: {
      type: DataTypes.STRING,
    },
    nextSyncTokenForEmail: {
      type: DataTypes.TEXT,
    },
    nextSyncTokenForEmail2: {
      type: DataTypes.TEXT,
    },
    nextSyncTokenForEmail3: {
      type: DataTypes.TEXT,
    },
    lastPasswordUpdatedForSecurity: {
      type: DataTypes.STRING
    },
    designationId: {
      type: DataTypes.INTEGER,
    },
    organizationId: {
      type: DataTypes.INTEGER,
    },
    locationId: {
      type: DataTypes.INTEGER,
    },
    timezoneId: {
      type: DataTypes.INTEGER,
    },
    phonenumber: {
      type: DataTypes.STRING,
    },
    phonenumber2: {
      type: DataTypes.STRING,
    },
    phonenumber3: {
      type: DataTypes.STRING,
    },
    phonenumber4: {
      type: DataTypes.STRING,
    },
    phonenumber5: {
      type: DataTypes.STRING,
    },
    primaryPhonenumber: {
      type: DataTypes.STRING,
    },
    phonenumberCountryCode: {
      type: DataTypes.STRING,
    },
    phonenumber2CountryCode: {
      type: DataTypes.STRING,
    },
    phonenumber3CountryCode: {
      type: DataTypes.STRING,
    },
    phonenumber4CountryCode: {
      type: DataTypes.STRING,
    },
    phonenumber5CountryCode: {
      type: DataTypes.STRING,
    },
    theme: {
      type: DataTypes.STRING,
    },
    aboutMeText: {
      type: DataTypes.TEXT,
    },
    isNotificationDisabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    subscriptionId: {
      type: DataTypes.INTEGER,
      // defaultValue: 2
    },
    baOrgId: {
      type: DataTypes.INTEGER,
      defaultValue: 1
    },
    stripeCustomerId: {
      type: DataTypes.STRING,
    },
    stripeSubscriptionId: {
      type: DataTypes.STRING,
    },
    usernameUpdatedCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    googleResourceIdEmail1: {
      type: DataTypes.STRING
    },
    googleChannelIdEmail1: {
      type: DataTypes.STRING
    },
    googleWatchExpirationEmail1: {
      type: DataTypes.STRING
    },
    googleResourceIdEmail2: {
      type: DataTypes.STRING
    },
    googleChannelIdEmail2: {
      type: DataTypes.STRING
    },
    googleWatchExpirationEmail2: {
      type: DataTypes.STRING
    },
    googleResourceIdEmail3: {
      type: DataTypes.STRING
    },
    googleChannelIdEmail3: {
      type: DataTypes.STRING
    },
    googleWatchExpirationEmail3: {
      type: DataTypes.STRING
    },
    microsoftSubscriptionIdEmail1: {
      type: DataTypes.STRING
    },
    microsoftSubscriptionExpirationEmail1: {
      type: DataTypes.STRING
    },
    microsoftSubscriptionIdEmail2: {
      type: DataTypes.STRING
    },
    microsoftSubscriptionExpirationEmail2: {
      type: DataTypes.STRING
    },
    microsoftSubscriptionIdEmail3: {
      type: DataTypes.STRING
    },
    microsoftSubscriptionExpirationEmail3: {
      type: DataTypes.STRING
    },
    createdAt: {
      type: DataTypes.STRING
    },
    lastLoginTimeStamp: {
      type: DataTypes.STRING
    },
    freeSubscriptionExpiration: {
      type: DataTypes.STRING
    },
    isFreeTrialOver: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    mfaSecret: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    mfaEnabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    mfaConfigured: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    mfaManditory: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    isCredentialsDisabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    emailSyncTimeStamp: {
      type: DataTypes.STRING
    },
    email2SyncTimeStamp: {
      type: DataTypes.STRING
    },
    email3SyncTimeStamp: {
      type: DataTypes.STRING
    },
    credentialDisabledTimeStamp: {
      type: DataTypes.STRING
    },
    credentialEnabledTimeStamp: {
      type: DataTypes.STRING
    },
    subscriptionUpgradeTimeStamp: {
      type: DataTypes.STRING
    },
    subscriptionDowngradeTimeStamp: {
      type: DataTypes.STRING
    },
    firstTimeEmailSyncTimeStamp: {
      type: DataTypes.STRING
    },
    firstTimeEmail2SyncTimeStamp: {
      type: DataTypes.STRING
    },
    firstTimeEmail3SyncTimeStamp: {
      type: DataTypes.STRING
    },
    emailSyncExpiration: {
      type: DataTypes.STRING
    },
    email2SyncExpiration: {
      type: DataTypes.STRING
    },
    email3SyncExpiration: {
      type: DataTypes.STRING
    },
    isUsernameUpdated: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    business: {
      type: DataTypes.STRING
    },
    industry: {
      type: DataTypes.INTEGER
    },
    isMergeCalendarGuideChecked: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    }
  }, {
    timestamps: false,
  });

  return Users;
};
