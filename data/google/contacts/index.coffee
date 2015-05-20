OAuth = require("OAuth")
OAuth2 = OAuth.OAuth2
twitterConsumerKey = "your key"
twitterConsumerSecret = "your secret"
oauth2 = new OAuth2(
    server.config.keys.twitter.consumerKey,
    twitterConsumerSecret,
    "https://api.twitter.com/",
    null,
    "oauth2/token",
    null)

oauth2.getOAuthAccessToken "", {grant_type: "client_credentials"}, (e, access_token, refresh_token, results) ->
console.log "bearer: ", access_token
done()

