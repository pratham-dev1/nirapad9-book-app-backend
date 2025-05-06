const { Op } = require('sequelize');
const { CLIENT_URL, SERVER_URL } = require('../config/urlsConfig');
const db = require('../models');
const stripe = require('stripe')(process.env.STRIPE_TEST_SECRET_KEY);

exports.stripeCheckout = async (req, res) => {
  try {
    const { priceId, subscriptionId } = req.params
    const user = await db.user.findByPk(req.user.userId)
    // if (!user.stripeCustomerId) {
    //   const customer = await stripe.customers.create({
    //     name: user.fullname,
    //     email: user.email,
    //   });
    //   user.stripeCustomerId = customer.id
    //   await user.save()
    // }
    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: user.stripeCustomerId,
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: `${SERVER_URL}/api/payment/stripe-success?session_id={CHECKOUT_SESSION_ID}&subscription_id=${subscriptionId}`,
      // success_url: `http://localhost:5173/payment-success?session_id={CHECKOUT_SESSION_ID}&subscription_id=${subscriptionId}`,
      cancel_url: `${CLIENT_URL}/error?message=Error: Payment Cancelled`,
    });
    res.redirect(303, session.url);
  } catch (error) {
    console.log(error)
    res.redirect(`${CLIENT_URL}/error?message=Error: ${error.message || 'something went wrong'}`);
  }
}

exports.stripeSuccess = async (req, res) => {
  try {
    const { subscription_id, session_id } = req.query;
    try {
      const user = await db.user.findByPk(req.user.userId);
      const session = await stripe.checkout.sessions.retrieve(session_id);
      if (session.customer === user.stripeCustomerId) {
        if (user.stripeSubscriptionId) {
          const subscription = await stripe.subscriptions.cancel(
            user.stripeSubscriptionId
          );
        }
        user[user.subscriptionId > subscription_id ? 'subscriptionDowngradeTimeStamp' : 'subscriptionUpgradeTimeStamp'] = new Date().toISOString()
        user.subscriptionId = subscription_id;
        user.stripeSubscriptionId = session.subscription
        user.freeSubscriptionExpiration = null;
        await user.save()
        res.redirect(`${CLIENT_URL}/payment-success`)
      }
      else {
        res.redirect(`${CLIENT_URL}/error?message=Error: Payment Failed `);
      }
    }
    catch (err) {
      console.log(err)
      res.redirect(`${CLIENT_URL}/error?message=Error: Payment Failed `);
    }
  } catch (error) {
    res.redirect(`${CLIENT_URL}/error?message=Error: Payment Failed - ${error.message}`);
  }
}

// exports.stripeFailure = async (req, res) => {
//     try {
//         res.redirect(`${CLIENT_URL}/error?message=Error: Payment Failed`);
//     } catch (error) {
//         res.redirect(`${CLIENT_URL}/error?message=Error: Payment Failed - ${error.message}`);
//     }
// }

// exports.setupIntent = async (req, res) => {
//     try {
//     const intent = await stripe.setupIntents.create({
//         customer: 'cus_QUr4zOhecxBSO8',
//         automatic_payment_methods: {enabled: true},
//       });
//       res.json({client_secret: intent.client_secret});
//     }
//     catch (error) {
//         res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
//     }
// }


// exports.payViaSavedCard = async (req, res) => {
//     try {
//         console.log(req.body)
//         const {id: paymentMethodId, customer, amount} = req.body.id
//           const paymentIntent = await stripe.paymentIntents.create({
//             amount: amount * 100,
//     currency: 'usd',
//     // In the latest version of the API, specifying the `automatic_payment_methods` parameter is optional because Stripe enables its functionality by default.
//     automatic_payment_methods: {enabled: true},
//     customer: customer,
//     payment_method: paymentMethodId,
//     return_url: 'http://localhost:5173/payment-success',
//     off_session: true,
//     confirm: true,
//             });
//             res.json({ success:true, status:paymentIntent.status  });

//     } catch (error) {
//         res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
//     }
// }

// exports.getSavedCardList = async (req, res) => {
//     try {
//         const user = await db.user.findByPk(req.user.userId)
//         const paymentMethods = await stripe.paymentMethods.list({
//             customer: user.stripeCustomerId || 'cus_QUr4zOhecxBSO8',
//             type: 'card',
//           });
//           res.status(200).json({succes: true, data: paymentMethods });
//     } catch (error) {
//         res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
//     }
// }

// exports.createSubscription = async (req, res) => {
//     try {
//         const customer = await stripe.customers.create({
//             name: req.body.name,
//             email: req.body.email,
//             payment_method: req.body.paymentMethod,
//             invoice_settings: {
//               default_payment_method: req.body.paymentMethod,
//             },
//           });


//           // get the price id from the front-end
//           const priceId = req.body.priceId;

//           // create a stripe subscription
//           const subscription = await stripe.subscriptions.create({
//             customer: customer.id,
//             items: [{ price: priceId }],
//             payment_behavior: 'default_incomplete',
//             payment_settings: {
//               payment_method_types: ['card'],
//               save_default_payment_method: 'on_subscription',
//             },
//             expand: ['latest_invoice.payment_intent'],
//           });

//           // return the client secret and subscription id
//             const json =  {
//             clientSecret: subscription.latest_invoice.payment_intent.client_secret,
//             subscriptionId: subscription.id,
//           };
//           res.status(200).json({success: true, data: json})

//     } catch (error) {
//         res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
//     }
// }

exports.customerPortal = async (req, res) => {
  try {
    const user = await db.user.findByPk(req.user.userId);
    const portalSession = await stripe.billingPortal.sessions.create({
      customer: user.stripeCustomerId,
      return_url: `${CLIENT_URL}/settings`,
    });
    res.redirect(303, portalSession.url);
  } catch (error) {
    res.redirect(`${CLIENT_URL}/error?message=${error.message}`);
  }
}

exports.getWebhookEvents = async (req, res) => {
  const sig = req.headers['stripe-signature'];

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, 'whsec_b254b9555399559b5b09cd14429d2cd3bd81fd4c31f0d8eaf9a3c9e77a4d4a07');
  } catch (err) {
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }
  const subscription = event.data.object;
  // console.log(event.data.object, event.data.previous_attributes)
  switch (event.type) {
    case 'customer.subscription.updated':
      if (subscription.cancel_at_period_end) {
        // Handle cancellation at the end of the billing period
        console.log('cancellation at the end of the billing period')
      }
      else if (event?.data?.previous_attributes?.plan?.id && (subscription?.plan.id !== event?.data?.previous_attributes?.plan?.id)) {
        const subscriptionPlan = await db.subscription.findOne({
          where: {
            [Op.or]: [
              { monthlyPriceId: subscription?.plan.id },
              { yearlyPriceId: subscription?.plan.id }
            ]
          }, attributes: ['id']
        })
        console.log('subscriptionId', subscriptionPlan.id)
        const user = await db.user.findOne({where: {stripeCustomerId: subscription.customer}})
        user[user.subscriptionId > subscriptionPlan.id ? 'subscriptionDowngradeTimeStamp' : 'subscriptionUpgradeTimeStamp'] = new Date().toISOString()
        user.stripeSubscriptionId = subscription.id;
        user.subscriptionId = subscriptionPlan.id;
        await user.save()
        // await db.user.update({ stripeSubscriptionId: subscription.id, subscriptionId: subscriptionPlan.id, subscriptionUpdateTimeStamp: new Date().toISOString() }, { where: { stripeCustomerId: subscription.customer } })
      }
      else if (subscription.status === 'active' && event?.data?.previous_attributes?.cancel_at_period_end) {
        // Handle manual subscription renewal
        console.log('manually subscription renewal')
      }
      break;

    case 'invoice.payment_succeeded':
      if (subscription.billing_reason === 'subscription_create') {
        //Handle new created subscription
      }
      else if (subscription.billing_reason === 'subscription_cycle') {
        //Handle only auto renew subscription - not manual renew
      }
      break;

    case 'customer.subscription.deleted':
      // Handle immediate cancellation 
      await db.user.update({ stripeSubscriptionId: null, subscriptionId: 1, freeSubscriptionExpiration: null }, { where: { stripeSubscriptionId: subscription.id } });
      break;
    // ... handle other event types
    default:
      break;
  }

  res.json({ received: true });
}