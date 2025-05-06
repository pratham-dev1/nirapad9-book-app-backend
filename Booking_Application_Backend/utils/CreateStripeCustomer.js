const db = require('../models');
const stripe = require('stripe')(process.env.STRIPE_TEST_SECRET_KEY);

async function CreateStripeCustomer(userId) {
    const user = await db.user.findByPk(userId)
    const customer = await stripe.customers.create({
        name: user.fullname,
        email: user.email,
      });
      user.stripeCustomerId = customer.id
      await user.save()
}

module.exports = { CreateStripeCustomer }