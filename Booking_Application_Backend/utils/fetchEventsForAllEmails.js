const { fetchGoogleEvents } = require("./fetchGoogleEvents")
const { fetchMicrosoftEvents } = require("./fetchMicrosoftEvents")

async function fetchEventsForAllEmails(user) {
  let failedEmails = []
  if (user.emailServiceProvider === 'google' && user.emailAccessToken) {
    await fetchGoogleEvents(user.emailAccessToken, user.emailRefreshToken, user.id, user.email, user.nextSyncTokenForEmail).catch((error) => {
      failedEmails.push(user.email)
    })
  }
  else if (user.emailServiceProvider === 'microsoft' && user.emailAccessToken) {
    await fetchMicrosoftEvents(user.emailAccessToken, user.emailRefreshToken, user.id, user.email, user.nextSyncTokenForEmail).catch((error) => {
      failedEmails.push(user.email)
    })
  }
  if (user.email2 && user.email2ServiceProvider === 'google' && user.email2AccessToken) {
    await fetchGoogleEvents(user.email2AccessToken, user.email2RefreshToken, user.id, user.email2, user.nextSyncTokenForEmail2).catch((error) => {
      failedEmails.push(user.email2)
    })
  }
  else if (user.email2 && user.email2ServiceProvider === 'microsoft' && user.email2AccessToken) {
    await fetchMicrosoftEvents(user.email2AccessToken, user.email2RefreshToken, user.id, user.email2, user.nextSyncTokenForEmail2).catch((error) => {
      failedEmails.push(user.email2)
    })
  }
  if (user.email3 && user.email3ServiceProvider === 'google' && user.email3AccessToken) {
    await fetchGoogleEvents(user.email3AccessToken, user.email3RefreshToken, user.id, user.email3, user.nextSyncTokenForEmail3).catch((error) => {
      failedEmails.push(user.email3)
    })
  }
  else if (user.email3 && user.email3ServiceProvider === 'microsoft' && user.email3AccessToken) {
    await fetchMicrosoftEvents(user.email3AccessToken, user.email3RefreshToken, user.id, user.email3,user.nextSyncTokenForEmail3).catch((error) => {
      failedEmails.push(user.email3)
    })
  }
  return failedEmails;
}

module.exports = { fetchEventsForAllEmails }