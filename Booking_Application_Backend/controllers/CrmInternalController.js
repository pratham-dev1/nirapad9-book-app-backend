const db = require("../models")
const XLSX = require('xlsx');

exports.saveLeadInfo = async (req, res) => {
    try {
        const {formdata: {leadinfo, contactinfo, companyinfo, tags, notes}} = req.body
        const lead = await db.crm_internal_lead_info.create({...leadinfo, createdBy: 1})
        await db.crm_internal_lead_contact_info.create({...contactinfo, leadId: lead.id})
        await db.crm_internal_lead_company_info.create({...companyinfo, leadId: lead.id})
        await db.crm_internal_lead_notes.create({notes, leadId: lead.id})
        // await db.crm_internal_lead_tag.create({tagName: tags})
        return res.status(201).json({ success: true, message: 'Record Saved Successfully' });
    } 
    catch (error) {
        console.log(error)
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getCommunicationStatus = async (req, res) => {
    try {
        const data = await db.crm_internal_communication_status.findAll({})
        return res.status(200).json({ success: true, data: data });
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getCommunicationStatusForEmail = async (req, res) => {
    try {
        const data = await db.crm_internal_email_communication_status.findAll({})
        return res.status(200).json({ success: true, data: data });
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getCommunicationStatusForPhone = async (req, res) => {
    try {
        const data = await db.crm_internal_phone_communication_status.findAll({})
        return res.status(200).json({ success: true, data: data });
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getCommunicationStatusForLinkedin = async (req, res) => {
    try {
        const data = await db.crm_internal_LinkedIn_communication_status.findAll({})
        return res.status(200).json({ success: true, data: data });
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getAllLeads = async (req, res) => {
    try {
        const data = await db.crm_internal_lead_info.findAll({
            include: [
                {
                    model: db.crm_internal_communication_status,
                    as: 'communicationStatusDetails'
                },
                {
                    model: db.crm_internal_lead_contact_info,
                    as: 'leadContactInfo'
                },
                {
                    model: db.crm_internal_lead_company_info,
                    as: 'leadCompanyInfo'
                },
                {
                    model: db.crm_internal_lead_notes,
                    as: 'leadNotes'
                },
                {
                    model: db.crm_internal_lead_tag,
                    as: 'leadTags'
                },
            ]
        })
        return res.status(200).json({ success: true, data: data });
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.updateLeadInfo = async (req, res) => {
    try {
        const {formdata: {leadinfo, contactinfo, companyinfo, tags, notes, leadId}} = req.body
        await db.crm_internal_lead_info.update({...leadinfo}, {where: {id: leadinfo?.leadId}})
        await db.crm_internal_lead_contact_info.update({...contactinfo}, {where: {leadId: leadinfo?.leadId}})
        await db.crm_internal_lead_company_info.update({...companyinfo}, {where: {leadId: leadinfo?.leadId}})
        await db.crm_internal_lead_notes.update({notes}, {where: {leadId: leadinfo?.leadId}})
        return res.status(200).json({ success: true, message: 'Record Updated Successfully' });
    } 
    catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.saveLeadsThroughExcel = async (req, res) => {
    try {
        const {base64data} = req.body;
        console.log(base64data)
        const buffer = Buffer.from(base64data, 'base64');

        const workbook = XLSX.read(buffer, { type: 'buffer' });
        const sheetName = workbook.SheetNames[0];
        const sheet = workbook.Sheets[sheetName];

        const json = XLSX.utils.sheet_to_json(sheet);
        for (let item of json) {
            if(item.communicationStatus) {
                const communicationStatus = await db.crm_internal_communication_status.findOne({where: {status: item.communicationStatus}, raw: true})
                item = {...item, communicationStatus: communicationStatus?.id}
            }
            if(item.communicationStatusForEmail) {
                const communicationStatusForEmail = await db.crm_internal_email_communication_status.findOne({where: {status: item.communicationStatusForEmail}, raw: true})
                item = {...item, communicationStatusForEmail: communicationStatusForEmail?.id}
            }
            if(item.communicationStatusForPhone) {
                const communicationStatusForPhone = await db.crm_internal_phone_communication_status.findOne({where: {status: item.communicationStatusForPhone}, raw: true})
                item = {...item, communicationStatusForPhone: communicationStatusForPhone?.id}
            }
            if(item.communicationStatusForLinkedIn) {
                const communicationStatusForLinkedin = await db.crm_internal_LinkedIn_communication_status.findOne({where: {status: item.communicationStatusForLinkedIn}, raw: true})
                item = {...item, communicationStatusForLinkedIn: communicationStatusForLinkedin?.id}
            }
            if(item.communicationStatusForEmail1) {
                const communicationStatusForEmail1 = await db.crm_internal_email_communication_status.findOne({where: {status: item.communicationStatusForEmail1}, raw: true})
                item = {...item, communicationStatusForEmail1: communicationStatusForEmail1?.id}
            }
            if(item.communicationStatusForEmail2) {
                const communicationStatusForEmail2 = await db.crm_internal_email_communication_status.findOne({where: {status: item.communicationStatusForEmail2}, raw: true})
                item = {...item, communicationStatusForEmail2: communicationStatusForEmail2?.id}
            }
            if(item.communicationStatusForPhone1) {
                const communicationStatusForPhone1 = await db.crm_internal_phone_communication_status.findOne({where: {status: item.communicationStatusForPhone1}, raw: true})
                item = {...item, communicationStatusForPhone1: communicationStatusForPhone1?.id}
            }
            if(item.communicationStatusForPhone2) {
                const communicationStatusForPhone2 = await db.crm_internal_phone_communication_status.findOne({where: {status: item.communicationStatusForPhone2}, raw: true})
                item = {...item, communicationStatusForPhone2: communicationStatusForPhone2?.id}
            }
            if(item.communicationStatusForPhone3) {
                const communicationStatusForPhone3 = await db.crm_internal_phone_communication_status.findOne({where: {status: item.communicationStatusForPhone3}, raw: true})
                item = {...item, communicationStatusForPhone3: communicationStatusForPhone3?.id}
            }
            if(item.communicationStatusForPhone4) {
                const communicationStatusForPhone4 = await db.crm_internal_phone_communication_status.findOne({where: {status: item.communicationStatusForPhone4}, raw: true})
                item = {...item, communicationStatusForPhone4: communicationStatusForPhone4?.id}
            }
            if(item.communicationStatusForPhone5) {
                const communicationStatusForPhone5 = await db.crm_internal_phone_communication_status.findOne({where: {status: item.communicationStatusForPhone5}, raw: true})
                item = {...item, communicationStatusForPhone5: communicationStatusForPhone5?.id}
            }
            const lead = await db.crm_internal_lead_info.create({ ...item, createdBy: 1 })
            await db.crm_internal_lead_contact_info.create({ ...item, leadId: lead.id })
            await db.crm_internal_lead_company_info.create({ ...item, leadId: lead.id })
            await db.crm_internal_lead_notes.create({ ...item, leadId: lead.id })
        }
        return res.status(201).json({ success: true, message: 'Record Saved Successfully' });
    }
    catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}