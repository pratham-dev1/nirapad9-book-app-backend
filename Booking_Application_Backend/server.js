const express = require("express");
const app = express();
app.set('trust proxy', true);
const port = 5000;
require('dotenv').config();
const db = require("./models/index");
const cors = require("cors")
const cookieParser = require('cookie-parser');
const session = require('express-session');
const passport = require('./config/passport');
const { CLIENT_URL } = require("./config/urlsConfig");
const { initializeSocket, getIo, getConnectedUsers } = require("./utils/socket");
require("./utils/EventReminder")
// require("./utils/CronJobForNewTokens")
require("./utils/AutomaticAcceptOpenSlotBooking")
require("./utils/EmailReminderForBookedSlot")
require("./utils/AutomaticEmailWebhookRenew")
const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');
dayjs.extend(utc);
dayjs.extend(timezone);

const http = require('http')
const server = http.createServer(app)
initializeSocket(server)

//Routes
const talentPartnerRoutes = require("./routes/TalentPartnerRoutes");
const adminRoutes = require("./routes/AdminRoutes");
const authRoutes = require("./routes/AuthRoutes")
const commonRoutes = require("./routes/CommonRoutes")
const recruiterRoutes = require("./routes/RecruiterRoutes");
const timeSheetRoutes = require("./routes/TimeSheetRoutes")
const crmInternalRoutes = require("./routes/CrmInternalRoutes")
const paymentRoutes = require("./routes/PaymentRoutes")
const googleWebhookRoutes = require("./routes/GoogleWebhookRoutes");
const reportsRoutes = require("./routes/ReportsRoutes");
const microsoftWebhookRoutes = require("./routes/MicrosoftWebhookRoutes")
const productOwnerRoutes = require("./routes/ProductOwnerRoutes")
const aiModelRoutes = require("./routes/AIModelRoutes")
const { stopGoogleWatch } = require("./utils/stopGoogleWatch");
const { deleteMicrosoftSubscription } = require("./utils/deleteMicrosoftSubscription");
// const { stopGoogleWatch } = require("./utils/stopGoogleWatch");

//Middlewares
app.use(cors({origin: true, credentials: true}));
app.use('/api/payment/webhook', express.raw({ type: 'application/json' }));  // placed this before - app.use(express.json());
app.use(express.json({limit: '1mb'}));
app.use(cookieParser());
app.use(session({ secret: 'your-secret-key', resave: true, saveUninitialized: true }));
app.use(passport.initialize());
app.use(passport.session());
app.use('/public', express.static('public'));  // with this config it will show images on frontend

//Contollers
app.use("/api/talent-partner", talentPartnerRoutes);
app.use("/api/admin", adminRoutes)
app.use("/api/auth", authRoutes)
app.use("/api/common", commonRoutes)
app.use("/api/recruiter", recruiterRoutes)
app.use("/api/timesheet", timeSheetRoutes)
app.use("/api/crm-internal", crmInternalRoutes)
app.use("/api/payment", paymentRoutes)
app.use("/api/google", googleWebhookRoutes)
app.use("/api/reports",reportsRoutes)
app.use("/api/microsoft", microsoftWebhookRoutes)
app.use("/api/product-owner", productOwnerRoutes)
app.use("/api/ai-model", aiModelRoutes)

// db.sequelize
//   .sync({alter:true})
//   .then(() => {
//     console.log("Synced db");
//   })
//   .catch((err) => {
//     console.log("Failed to sync db: " + err.message);
//   });


// db.user.findByPk(24).then(user => {
//   stopGoogleWatch(user.emailAccessToken, user.emailRefreshToken, user.googleChannelIdEmail1, user.googleResourceIdEmail1, 'googleResourceIdEmail1', 'googleChannelIdEmail1', 'googleWatchExpirationEmail1', user)
// })

server.listen(process.env.PORT || port, async() => {
  console.log(`Server is running on port ${port}`);
  // deleteMicrosoftSubscription()
});
