module.exports = (sequelize, DataTypes) => {
    const fieldOfStudy = sequelize.define("field_of_studies", {
        name: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'field_of_studies',
        timestamps: false
    });

    return fieldOfStudy;
};
