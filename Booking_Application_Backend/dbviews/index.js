const { DataTypes } = require("sequelize");
const db = require("../models/index")

const dbviews = {}
dbviews.event_merge_calendar_view = require("./eventMergeCalendarView")(db.sequelize, DataTypes)
dbviews.event_hub_history_view = require("./eventHubHistoryView")(db.sequelize, DataTypes)
dbviews.frequently_met_people_tags_view = require("./frequentlyMetPeopleTagsView")(db.sequelize, DataTypes)

module.exports = dbviews