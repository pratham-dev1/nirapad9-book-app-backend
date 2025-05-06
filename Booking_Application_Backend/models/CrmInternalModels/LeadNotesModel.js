module.exports = (sequelize, DataTypes) => {
    const CrmLeadNotes = sequelize.define("crm_internal_lead_note", {
        leadId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        notes: {
            type: DataTypes.STRING,
            // allowNull: false,
        },
    }, {
        timestamps: false,
    });

    return CrmLeadNotes;
};
