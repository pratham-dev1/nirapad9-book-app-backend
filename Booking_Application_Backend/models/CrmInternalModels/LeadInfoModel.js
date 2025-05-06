module.exports = (sequelize, DataTypes) => {
    const CrmLeadInfo = sequelize.define("crm_internal_lead_info", {
        firstname: {
            type: DataTypes.STRING,
        },
        lastname: {
            type: DataTypes.STRING,
        },
        title: {
            type: DataTypes.STRING,
        },
        company: {
            type: DataTypes.STRING,
        },
        email: {
            type: DataTypes.STRING,
        },
        accuracyForEmail: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForEmail: {
            type: DataTypes.INTEGER,
        },
        notesForEmail: {
            type: DataTypes.STRING,
        },
        phone: {
            type: DataTypes.STRING,
        },
        accuracyForPhone: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForPhone: {
            type: DataTypes.INTEGER,
        },
        notesForPhone: {
            type: DataTypes.STRING,
        },
        locality: {
            type: DataTypes.STRING,
        },
        state: {
            type: DataTypes.STRING,
        },
        country: {
            type: DataTypes.STRING,
        },
        communicationStatus: {
            type: DataTypes.INTEGER,
        },
        viableLead: {
            type: DataTypes.STRING,
        },
        createdBy: {
            type: DataTypes.INTEGER,
        },
        createdOn: {
            type: DataTypes.STRING,
            defaultValue: new Date().toISOString()
        },
    }, {
        timestamps: false,
    });

    return CrmLeadInfo;
};
