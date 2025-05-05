const functions = require("firebase-functions");
const express = require("express");
const admin = require("firebase-admin");
const Stripe = require("stripe");
const cors = require("cors")({origin: true});

const app = express();
admin.initializeApp();

// Enable CORS for all routes
app.use(cors);
app.options("*", cors); // Enable pre-flight requests for all routes

const stripe = new Stripe("sk_test_51Qz5ao08zT37J1Lv"+
"AVEStkl8UXiZtnC9dODkUz46SddQhYiz4Oxa9m59"+
"Uvsmapi9pPSShKBPcSX1x86nJjrZ0KXj00jeude7qO");

// Generate Connection Token for Stripe Terminal
app.post("/connection_token", async (req, res) => {
  try {
    const token = await stripe.terminal.connectionTokens.create();
    res.json({secret: token.secret});
  } catch (error) {
    res.status(500).json({msg: "Error generating connection token", error});
  }
});

// Create a Stripe Customer
app.post("/create_customer", async (req, res) => {
  // Get phone or userId from request
  const {phone, userId, email} = req.body;

  // Check if we have at least one identifier
  if (!phone && !userId && !email) {
    return res.json({
      msg: "Please provide phone, userId, or email",
      status: "failure",
    });
  }

  try {
    // Create customer data object
    const customerData = {};

    // If phone is provided, add it to metadata
    if (phone) {
      customerData.metadata = {phone};
    }

    // If userId is provided, add it to metadata
    if (userId) {
      customerData.metadata = {...customerData.metadata, userId};
    }

    // Set email - either from request or generate one using phone/userId
    if (email) {
      customerData.email = email;
    } else if (phone) {
      customerData.email = `${phone.replace(/[^0-9]/g, "")}@snacktag.app`;
    } else if (userId) {
      customerData.email = `${userId}@snacktag.app`;
    }

    // Create the customer in Stripe
    const customer = await stripe.customers.create(customerData);

    // Return success response
    res.json({customer: customer.id, status: "success"});
  } catch (error) {
    console.log("Error creating customer:", error);
    res.json({msg: "Unable to create customer", status: "failure", error});
  }
});

// Create an Ephemeral Key
app.post("/ephemeralKey", async (req, res) => {
  if (!req.body.api_version || !req.body.customer_id) {
    return res.json({msg: "Missing required fields", status: "failure"});
  }

  try {
    const key = await stripe.ephemeralKeys.create(
        {customer: req.body.customer_id},
        {apiVersion: req.body.api_version},
    );
    res.json({data: key});
  } catch (error) {
    res.json({msg: "Unable to create ephemeral key", status: "failure", error});
  }
});

// API Data Endpoint
app.get("/apidata", (req, res) => {
  res.json({msg: "Hello World"});
});

// Create a Stripe Express Account
app.get("/account", async (req, res) => {
  try {
    const account = await stripe.accounts.create({
      country: "MX",
      type: "express",
      capabilities: {
        card_payments: {requested: true},
        transfers: {requested: true},
      },
      business_type: "individual",
      business_profile: {
        product_description: "Renovision will use this "+
        "account URL to transfer "+
        "payments into the Contractor account.",
      },
    });

    const accountLink = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: "https://snacktag.com/reauth",
      return_url: "https://snacktag.com/success",
      type: "account_onboarding",
    });

    res.json({account, link: accountLink});
  } catch (error) {
    res.status(500).json({msg: "Error creating Stripe account", error});
  }
});

// Send Firebase Cloud Message (FCM)
app.post("/sendFCM", async (req, res) => {
  const {tokens, msg, title} = req.body;

  if (!tokens || !msg || !title) {
    return res.json({msg: "Missing required fields", status: "failure"});
  }

  let isSuccess = false;

  try {
    await Promise.all(
        tokens
            .filter((token) => token !== "")
            .map(async (token) => {
              const payload = {
                token,
                notification: {title, body: msg},
                data: {body: msg},
              };

              await admin.messaging().send(payload);
            }),
    );

    isSuccess = true;
  } catch (error) {
    console.log("Notification send failed:", error);
  }

  res.json({msg: isSuccess ? "Success" : "Failed",
    status: isSuccess ? "success" : "failed"});
});

// Create Payment Intent
app.post("/createPaymentIntent", async (req, res) => {
  const {amount, customer_id: customerId} = req.body;

  if (!amount || !customerId) {
    return res.json({msg: "Amount and Customer ID required",
      status: "failure"});
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: "mxn",
      customer: customerId,
    });

    res.json({data: {paymentIntent,
      clientSecret: paymentIntent.client_secret}});
  } catch (error) {
    res.status(500).json({msg: "Error creating PaymentIntent", error});
  }
});

// Create Payment Intent with Ephemeral Key
app.post("/create_payment_intent", async (req, res) => {
  const {amount, customer} = req.body;

  if (!amount || !customer) {
    return res.json({
      msg: "Amount and Customer ID required",
      status: "failure",
    });
  }

  try {
    // Create a PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: parseInt(amount),
      currency: "mxn",
      customer: customer,
    });

    // Create an Ephemeral Key for the customer
    const ephemeralKey = await stripe.ephemeralKeys.create(
        {customer: customer},
        {apiVersion: "2024-04-10"},
    );

    // Return all the data needed by the client
    res.json({
      clientSecret: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer,
      status: "success",
    });
  } catch (error) {
    console.log("Error creating payment intent:", error);
    res.status(500).json({
      msg: "Error creating payment intent",
      error: error.message,
      status: "failure",
    });
  }
});

// Refund Payment
app.post("/refund", async (req, res) => {
  const {amount, payment_intent: paymentIntent} = req.body;


  if (!amount || !paymentIntent) {
    return res.json({msg: "Amount and Payment Intent required",
      status: "failure"});
  }

  try {
    const refund = await stripe.refunds.create({
      paymentIntent,
      amount,
    });

    res.json({data: refund});
  } catch (error) {
    res.status(500).json({msg: "Error processing refund", error});
  }
});

// Payout to a Stripe Account
app.post("/payout", async (req, res) => {
  const {amount, stripe_account_id: stripeAccountId} = req.body;


  if (!amount || !stripeAccountId) {
    return res.json({msg: "Amount and Stripe Account ID required",
      status: "failure"});
  }

  try {
    const payout = await stripe.payouts.create(
        {amount, currency: "mxn"},
        {stripeAccount: stripeAccountId},
    );

    res.json({data: payout});
  } catch (error) {
    res.status(500).json({msg: "Error processing payout", error});
  }
});

// Create Stripe Account for SnackTag
app.post("/createSnackTagStripeAccount", async (req, res) => {
  try {
    const account = await stripe.accounts.create({
      country: "MX",
      type: "express",
      capabilities: {
        card_payments: {requested: true},
        transfers: {requested: true},
      },
      business_type: "individual",
      business_profile: {
        product_description: "SnackTag will use this account for Payouts",
      },
    });
    const accountLink = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: "https://snacktag.com/reauth",
      return_url: "https://snacktag.com/success",
      type: "account_onboarding",
    });
    res.json({account: account, link: accountLink});
  } catch (error) {
    console.error("Error creating Stripe account:", error);
    res.status(500).json({
      error: "Failed to create Stripe account",
      details: error.message,
    });
  }
});

// Create Payout
app.post("/payout", async (req, res) => {
  try {
    const payout = await stripe.payouts.create({
      amount: req.body.amount,
      currency: "mxn",
    }, {
      stripeAccount: req.body.stripeAccountId,
    });
    res.json({data: payout});
  } catch (error) {
    console.error("Error creating payout:", error);
    res.status(500).json({
      error: "Failed to create payout",
      details: error.message,
    });
  }
});

// Export Express App as Firebase Function
exports.app = functions.https.onRequest(app);

