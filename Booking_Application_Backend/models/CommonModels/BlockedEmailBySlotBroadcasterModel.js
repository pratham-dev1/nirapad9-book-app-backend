module.exports = (sequelize, DataTypes) => {
    const BlockedEmailBySlotBroadcaster = sequelize.define("blocked_email_by_slot_broadcaster", {
      email: {
        type: DataTypes.STRING,
        allowNull: false
      },
      tagOwnerUserId: {
        type: DataTypes.INTEGER,
        allowNull: false
      },
      tagId: {
        type: DataTypes.INTEGER,
        allowNull: false
      }
    }, {
        timestamps: false
    });
    return BlockedEmailBySlotBroadcaster;
  };