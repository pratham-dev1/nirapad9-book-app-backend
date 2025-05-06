const express = require("express");
const router = express.Router();
const { VerifyAccessToken } = require("../middlewares/auth/VerifyAccessToken");
const { stripeCheckout, stripeSuccess, stripeFailure, setupIntent, payViaSavedCard, getSavedCardList, createSubscription, customerPortal,getWebhookEvents } = require("../controllers/PaymentController");
const bp = require('body-parser')
router.post('/create-checkout-session/:priceId/:subscriptionId', [VerifyAccessToken], stripeCheckout )

router.get('/stripe-success', [VerifyAccessToken], stripeSuccess )

// router.get('/stripe-failure', [VerifyAccessToken], stripeFailure )

// router.post('/create-intent', [VerifyAccessToken], setupIntent )

// router.post("/pay-via-saved-cards", [VerifyAccessToken], payViaSavedCard)

// router.get('/get-saved-card-list', [VerifyAccessToken], getSavedCardList )

// router.post('/create-subscription', [VerifyAccessToken], createSubscription)

router.post('/customer-portal', [VerifyAccessToken], customerPortal)

router.post('/webhook', getWebhookEvents)

module.exports = router;
