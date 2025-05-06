module.exports = (sequelize, DataTypes) => {
    const FrequentlyMetPeopleTags = sequelize.define("frequently_met_people_tags_view", {
        // id: {
        //     type: DataTypes.INTEGER,
        //     primaryKey: true,
        //     // autoIncremennt: true
        // },
        attendee: {
            type: DataTypes.TEXT,
        },
        userId: {
            type: DataTypes.INTEGER,
        },
        emailAccount: {
            type: DataTypes.STRING,
        },
        count: {
            type: DataTypes.INTEGER,
        },
        rank: {
            type: DataTypes.BIGINT,
        },
        tagName: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'frequently_met_people_tags_view',
        timestamps: false
    });

    return FrequentlyMetPeopleTags;
};