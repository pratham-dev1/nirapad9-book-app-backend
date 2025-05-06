module.exports = (sequelize, DataTypes) => {
    const CrmLeadTags = sequelize.define("crm_internal_lead_tag", {
        leadId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        tagName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false,
    });

    return CrmLeadTags;
};
