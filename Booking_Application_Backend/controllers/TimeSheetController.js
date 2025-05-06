const db = require("../models");

exports.getProjects = async (req, res) => {
    try {
        const userId = req.user.userId;
        const projects = await db.project.findAll({where: {userId}});
        res.status(200).json({ success: true, data: projects });
    }
    catch (error) {
        res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.submitTimeSheet = async (req, res) => {
    try {
        const userId = req.user.userId
        const { projectId, weekStartDate, weekEndDate, totalHours, status, remarks } = req.body;
        await db.timesheet.create({ userId, projectId, weekStartDate, weekEndDate, totalHours, status, remarks })
        res.status(201).json({ success: true, message: 'Timesheet Submitted Successfully' });
    }
    catch (error) {
        res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getTimeSheet = async (req, res) => {
    try {
        const userId = req.user.userId
        const timesheet = await db.timesheet.findAll({
            where: { userId },
            include: {
                model: db.project,
            }
        });
        res.status(200).json({ success: true, data: timesheet });
    }
    catch (error) {
        res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.addProject = async (req, res) => {
    try {
        const userId = req.user.userId
        const { projectName, startDate, endDate, defaultHours } = req.body;
        await db.project.create({ userId, projectName, startDate, endDate, defaultHours })
        res.status(201).json({ success: true, message: 'Project Added Successfully' });
    }
    catch (error) {
        res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}