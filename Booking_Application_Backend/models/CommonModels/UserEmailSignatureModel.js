module.exports = (sequelize, DataTypes) => {
    const Users = sequelize.define("user_email_signature", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        title: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        fullname: {
            type: DataTypes.STRING,
        },
        phonenumber: {
            type: DataTypes.STRING,
        },
        organizationId: {
            type: DataTypes.INTEGER,
        },
        website: {
            type: DataTypes.STRING,
        },
    }, {
      timestamps: false,
      tableName: 'user_email_signature'
    });
  
    return Users;
  };
  