const passport = require('passport');
const { SERVER_URL } = require('./urlsConfig');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const MicrosoftStrategy = require('passport-microsoft').Strategy;

passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: `${SERVER_URL}/api/auth/google/callback`, // Adjust the URL accordingly
  },  
  async (accessToken, refreshToken, profile, done) => {
    return done(null, {profile, accessToken, refreshToken});
  }));

passport.use(new MicrosoftStrategy({
    clientID: process.env.MICROSOFT_CLIENT_ID,
    clientSecret: process.env.MICROSOFT_CLIENT_SECRET,
    callbackURL: `${SERVER_URL}/api/auth/microsoft/callback`,
 }, (accessToken, refreshToken, profile, done) => {
    return done(null, {profile, accessToken, refreshToken});
 }));

  passport.serializeUser((user, done) => {
    done(null, user);
  });
  
  passport.deserializeUser((obj, done) => {
    done(null, obj);
  });

  
module.exports = passport;
