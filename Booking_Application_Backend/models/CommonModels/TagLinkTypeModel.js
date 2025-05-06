module.exports = (sequelize, DataTypes) => {
    const TagLinkType = sequelize.define("tag_link_type", {
        typeId: {
            type: DataTypes.STRING,
        },
        name: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return TagLinkType;
};
