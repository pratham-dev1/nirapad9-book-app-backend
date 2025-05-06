const express = require("express");
const { analyzeText } = require("../controllers/AIModelController");
const router = express.Router();

router.post('/analyze-text', analyzeText)

module.exports = router;