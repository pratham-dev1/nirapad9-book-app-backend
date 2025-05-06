module.exports = (sequelize, DataTypes) => {
    const CrmLeadCompanyInfo = sequelize.define("crm_internal_lead_company_info", {
        leadId: {
            type: DataTypes.INTEGER,
        },
        companyName: {
            type: DataTypes.STRING,
        },
        website: {
            type: DataTypes.STRING,
        },
        linkedIn: {
            type: DataTypes.STRING,
        },
        companySize: {
            type: DataTypes.INTEGER,
        },
        totalEmployees: {
            type: DataTypes.INTEGER,
        },
        annualRevenue: {
            type: DataTypes.STRING,
        },
        industry: {
            type: DataTypes.STRING,
        },
        description: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false,
    });

    return CrmLeadCompanyInfo;
};
