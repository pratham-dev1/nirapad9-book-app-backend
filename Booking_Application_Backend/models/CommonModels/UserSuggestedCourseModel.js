module.exports = (sequelize, DataTypes) => {
    const userSuggestedCourse = sequelize.define("user_suggested_course", {
        course: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
          },
        educationLevelId: {
            type: DataTypes.INTEGER,
        },
        fieldOfStudy: {
            type: DataTypes.STRING,  
        },
    }, {
        tableName: 'user_suggested_course',
        timestamps: false
    });

    return userSuggestedCourse;
};
