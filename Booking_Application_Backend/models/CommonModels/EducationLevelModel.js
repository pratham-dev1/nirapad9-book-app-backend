module.exports = (sequelize, DataTypes) => {
    const educationLevel = sequelize.define("education_level", {
        name: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'education_level',
        timestamps: false
    });

    return educationLevel;
};
