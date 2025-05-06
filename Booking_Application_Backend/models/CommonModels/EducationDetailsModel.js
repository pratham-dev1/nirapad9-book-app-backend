module.exports = (sequelize, DataTypes) => {
    const EducationDetails = sequelize.define("education_details", {
        startDate: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        endDate: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        isCurrentlyPursuing: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        institutionId: {
            type: DataTypes.INTEGER,
        },
        courseId: {
            type: DataTypes.INTEGER
        },
        userSuggestedInstitutionId: {
            type: DataTypes.INTEGER,
        },
        userSuggestedCourseId: {
            type: DataTypes.INTEGER
        },
        educationLevelId: {
            type: DataTypes.INTEGER,
        },
        fieldOfStudyId: {
            type: DataTypes.INTEGER,
        }
    }, {
        timestamps: false
    });

    return EducationDetails;
};
