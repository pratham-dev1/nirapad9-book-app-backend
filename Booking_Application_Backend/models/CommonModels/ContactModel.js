module.exports = (sequelize, DataTypes) => {
    const Contact = sequelize.define("contact", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        firstname: {
            type: DataTypes.STRING,
        },
        lastname: {
            type: DataTypes.STRING,
        },
        email: {
            type: DataTypes.STRING,
            allowNull: false,
            validate: {
              isEmail: {
                msg: 'Invalid email address',
              },
            },
          },
        phone: {
            type: DataTypes.STRING,
            allowNull: true, // Make phone number optional
            validate: {
                isValidPhone(value) {
                    // Only validate if phone number is provided
                    if (value && !/^\d{10}$/.test(value)) {
                        throw new Error('Invalid Phone number');
                    }
                }
            }
        },
        title: {
            type: DataTypes.STRING,
        },
        company: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return Contact;
};
