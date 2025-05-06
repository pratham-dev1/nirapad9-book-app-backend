module.exports = (sequelize, DataTypes) => {
    const Course = sequelize.define("course", {
        courseName: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'course',
        timestamps: false
    });

    return Course;
};
