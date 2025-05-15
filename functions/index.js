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
    // Log the request for debugging
    console.log("Creating Stripe account via /account endpoint");

    // Ensure we're creating an account for Mexico
    const country = "MX"; // Mexico country code

    console.log(`Creating Stripe account for country: ${country} (Mexico) via /account endpoint`);

    // Create the account with enhanced capabilities for Mexico
    const account = await stripe.accounts.create({
      country: country,
      type: "express",
      capabilities: {
        card_payments: {requested: true},
        transfers: {requested: true},
        // Note: legacy_payments is deprecated, using transfers as recommended by Stripe
      },
      business_type: "individual",
      business_profile: {
        product_description: "SnackTag will use this account for receiving payments and payouts.",
        // Add more Mexican-specific details
        url: "https://snacktag.com",
      },
      // Set default currency to MXN (Mexican Peso)
      default_currency: "mxn",
    });

    // Log the created account details
    console.log("Stripe account created successfully via /account endpoint:", {
      id: account.id,
      country: account.country,
      capabilities: account.capabilities,
      businessType: account.business_type,
      defaultCurrency: account.default_currency,
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


// Create Stripe Account for SnackTag
app.post("/createSnackTagStripeAccount", async (req, res) => {
  try {
    // Log the request for debugging
    console.log("Creating Stripe account with request:", req.body);

    // Ensure we're creating an account for Mexico
    const country = "MX"; // Mexico country code

    console.log(`Creating Stripe account for country: ${country} (Mexico)`);

    // Create the account with enhanced capabilities for Mexico
    const account = await stripe.accounts.create({
      country: country,
      type: "express",
      capabilities: {
        card_payments: {requested: true},
        transfers: {requested: true},
        // Note: legacy_payments is deprecated, using transfers as recommended by Stripe
      },
      business_type: "individual",
      business_profile: {
        product_description: "SnackTag will use this account for Payouts",
        // Add more Mexican-specific details

        url: "https://snacktag.com",
      },
      // Set default currency to MXN (Mexican Peso)
      default_currency: "mxn",
    });

    // Log the created account details
    console.log("Stripe account created successfully:", {
      id: account.id,
      country: account.country,
      capabilities: account.capabilities,
      businessType: account.business_type,
      defaultCurrency: account.default_currency,
    });
    const accountLink = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: "https://snacktag.com/reauth",
      return_url: "https://snacktag.com/success",
      type: "account_onboarding",
    });
    res.json({account, link: accountLink});
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
    // Extract parameters from request body
    const amount = req.body.amount;
    // Check for both parameter formats (stripeAccountId and stripe_account_id)
    const stripeAccountId = req.body.stripeAccountId || req.body.stripe_account_id;

    // Log the request details
    console.log("Payout request received:", {
      amount,
      stripeAccountId,
      requestBody: req.body,
    });

    if (!amount) {
      return res.status(400).json({
        error: "Missing required parameter: amount",
        details: "The amount parameter is required for processing a payout",
      });
    }

    if (!stripeAccountId) {
      return res.status(400).json({
        error: "Missing required parameter: stripeAccountId",
        details: "The stripeAccountId parameter is required for processing a payout",
      });
    }

    // Check if the Stripe account exists and has the necessary capabilities
    try {
      const account = await stripe.accounts.retrieve(stripeAccountId);

      // Enhanced logging for account details
      console.log("Stripe account retrieved - DETAILED INFO:", {
        id: account.id,
        country: account.country,
        capabilities: account.capabilities,
        payoutsEnabled: account.payouts_enabled,
        chargesEnabled: account.charges_enabled,
        detailsSubmitted: account.details_submitted,
        requirementsDisabled: account.requirements.disabled,
        requirementsPastDue: account.requirements.past_due,
        requirementsPending: account.requirements.pending_verification,
        requirementsCurrentlyDue: account.requirements.currently_due,
        requirementsEventuallyDue: account.requirements.eventually_due,
        businessType: account.business_type,
        businessProfile: account.business_profile,
        settings: account.settings,
        tosAcceptance: account.tos_acceptance,
      });

      // Log the full account object for debugging (sensitive info redacted by Stripe)
      console.log("Full account object:", JSON.stringify(account, null, 2));

      // Check if the account has the necessary capabilities
      if (!account.payouts_enabled) {
        // Determine what's missing for payouts to be enabled
        const missingRequirements = [];

        // Check country - should be MX for Mexico
        if (account.country !== "MX") {
          missingRequirements.push(`Country is set to ${account.country} instead of MX (Mexico)`);
        }

        // Check if details are submitted
        if (!account.details_submitted) {
          missingRequirements.push("Account details not submitted");
        }

        // Check for pending requirements
        if (account.requirements && account.requirements.currently_due &&
            account.requirements.currently_due.length > 0) {
          missingRequirements.push(
              `Missing requirements: ${account.requirements.currently_due.join(", ")}`,
          );
        }

        // Check capabilities
        const missingCapabilities = [];
        // Note: legacy_payments is deprecated, only check for transfers as recommended by Stripe
        const requiredCapabilities = ["transfers"];

        requiredCapabilities.forEach((cap) => {
          if (!account.capabilities ||
              !account.capabilities[cap] ||
              account.capabilities[cap] !== "active") {
            missingCapabilities.push(cap);
          }
        });

        if (missingCapabilities.length > 0) {
          missingRequirements.push(`Missing capabilities: ${missingCapabilities.join(", ")}`);
        }

        return res.status(400).json({
          error: "Account not enabled for payouts",
          details: "Please complete the account setup to enable payouts.",
          country: account.country,
          detailsSubmitted: account.details_submitted,
          missingRequirements: missingRequirements,
          capabilities: account.capabilities,
        });
      }
    } catch (accountError) {
      console.error("Error retrieving Stripe account:", accountError);
      return res.status(500).json({
        error: "Failed to retrieve Stripe account",
        details: accountError.message,
      });
    }

    // Process the payout
    const payout = await stripe.payouts.create({
      amount: amount,
      currency: "mxn",
    }, {
      stripeAccount: stripeAccountId,
    });

    console.log("Payout created successfully:", payout);
    res.json({data: payout});
  } catch (error) {
    console.error("Error creating payout:", error);

    // Provide more detailed error information
    const errorDetails = {
      message: error.message,
      type: error.type,
      code: error.code,
    };

    if (error.raw) {
      errorDetails.raw = {
        code: error.raw.code,
        message: error.raw.message,
        type: error.raw.type,
      };
    }

    res.status(500).json({
      error: "Failed to create payout",
      details: errorDetails,
    });
  }
});

// Export Express App as Firebase Function
exports.app = functions.https.onRequest(app);

