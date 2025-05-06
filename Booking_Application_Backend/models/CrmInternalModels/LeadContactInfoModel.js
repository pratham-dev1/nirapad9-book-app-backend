module.exports = (sequelize, DataTypes) => {
    const CrmLeadContactInfo = sequelize.define("crm_internal_lead_contact_info", {
        leadId: {
            type: DataTypes.INTEGER,
        },
        email1: {
            type: DataTypes.STRING,
        },
        accuracyForEmail1: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForEmail1: {
            type: DataTypes.INTEGER,
        },
        notesForEmail1: {
            type: DataTypes.STRING,
        },
        email2: {
            type: DataTypes.STRING,
        },
        accuracyForEmail2: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForEmail2: {
            type: DataTypes.INTEGER,
        },
        notesForEmail2: {
            type: DataTypes.STRING,
        },
        phone1: {
            type: DataTypes.STRING,
        },
        accuracyForPhone1: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForPhone1: {
            type: DataTypes.INTEGER,
        },
        notesForPhone1: {
            type: DataTypes.STRING,
        },
        phone2: {
            type: DataTypes.STRING,
        },
        accuracyForPhone2: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForPhone2: {
            type: DataTypes.INTEGER,
        },
        notesForPhone2: {
            type: DataTypes.STRING,
        },
        phone3: {
            type: DataTypes.STRING,
        },
        accuracyForPhone3: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForPhone3: {
            type: DataTypes.INTEGER,
        },
        notesForPhone3: {
            type: DataTypes.STRING,
        },
        phone4: {
            type: DataTypes.STRING,
        },
        accuracyForPhone4: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForPhone4: {
            type: DataTypes.INTEGER,
        },
        notesForPhone4: {
            type: DataTypes.STRING,
        },
        phone5: {
            type: DataTypes.STRING,
        },
        accuracyForPhone5: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForPhone5: {
            type: DataTypes.INTEGER,
        },
        notesForPhone5: {
            type: DataTypes.STRING,
        },
        linkedIn: {
            type: DataTypes.STRING,
        },
        accuracyForLinkedIn: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        communicationStatusForLinkedIn: {
            type: DataTypes.INTEGER,
        },
        notesForLinkedIn: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false,
    });

    return CrmLeadContactInfo;
};
