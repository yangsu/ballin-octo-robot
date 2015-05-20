_ = require("lodash")
express = require("express")
OAuth = require("oauth").OAuth
querystring = require("querystring")

# Setup the Express.js server
app = express()
app.use express.logger()
# app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session(secret: "skjghskdjfhbqigohqdiouk")


require_google_login = (req, res, next) ->
    unless req.session.oauth_access_token
        res.redirect "/google_login?action=" + querystring.escape(req.originalUrl)
        return
    next()

# Home Page
app.get "/", (req, res) ->
    unless req.session.oauth_access_token
        res.redirect "/google_login"
    else
        res.redirect "/google_contacts"


# Request an OAuth Request Token, and redirects the user to authorize it
app.get "/google_login", (req, res) ->
    getRequestTokenUrl = "https://www.google.com/accounts/OAuthGetRequestToken"
    # GData specifid: scopes that wa want access to
    gdataScopes = [
        querystring.escape("https://www.google.com/m8/feeds/")
        querystring.escape("https://www.google.com/calendar/feeds/")
    ]
    oa = new OAuth(
        getRequestTokenUrl + "?scope=" + gdataScopes.join("+")
        "https://www.google.com/accounts/OAuthGetAccessToken"
        "anonymous"
        "anonymous"
        "1.0"
        "http://localhost:3000/google_cb" + ((if req.param("action") and req.param("action") isnt "" then "?action=" + querystring.escape(req.param("action")) else ""))
        "HMAC-SHA1"
    )
    oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
        if error
            console.log "error"
            console.log error
        else
            # store the tokens in the session
            req.session.oa = oa
            req.session.oauth_token = oauth_token
            req.session.oauth_token_secret = oauth_token_secret
            # redirect the user to authorize the token
            res.redirect "https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token=" + oauth_token


# Callback for the authorization page
app.get "/google_cb", (req, res) ->
    {session} = req
    # get the OAuth access token with the 'oauth_verifier' that we received
    oa = new OAuth(
        session.oa._requestUrl
        session.oa._accessUrl
        session.oa._consumerKey
        session.oa._consumerSecret
        session.oa._version
        session.oa._authorize_callback
        session.oa._signatureMethod
    )
    console.log oa
    # store the access token in the session
    oa.getOAuthAccessToken(
        session.oauth_token
        session.oauth_token_secret
        req.param("oauth_verifier")
        (error, oauth_access_token, oauth_access_token_secret, results2) ->
            if error
                console.log "error"
                console.log error
            else
                session.oauth_access_token = oauth_access_token
                session.oauth_access_token_secret = oauth_access_token_secret
                res.redirect (if (req.param("action") and req.param("action") isnt "") then req.param("action") else "/google_contacts")
    )


app.get "/google_contacts", require_google_login, (req, res) ->
    oa = new OAuth(
        req.session.oa._requestUrl
        req.session.oa._accessUrl
        req.session.oa._consumerKey
        req.session.oa._consumerSecret
        req.session.oa._version
        req.session.oa._authorize_callback
        req.session.oa._signatureMethod
    )
    console.log oa

    # Example using GData API v3
    # GData Specific Header
    oa._headers["GData-Version"] = "3.0"
    oa.getProtectedResource(
        "https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=5000"
        "GET"
        req.session.oauth_access_token
        req.session.oauth_access_token_secret
        (error, data, response) ->
            feed = JSON.parse(data)
            console.log feed.feed.entry.length
            res.send feed
    )

app.get "/google_calendars", require_google_login, (req, res) ->
    oa = new OAuth(
        req.session.oa._requestUrl
        req.session.oa._accessUrl
        req.session.oa._consumerKey
        req.session.oa._consumerSecret
        req.session.oa._version
        req.session.oa._authorize_callback
        req.session.oa._signatureMethod
    )

    # Example using GData API v2
    # GData Specific Header
    oa._headers["GData-Version"] = "2"
    oa.getProtectedResource(
        "https://www.google.com/calendar/feeds/default/allcalendars/full?alt=jsonc"
        "GET"
        req.session.oauth_access_token
        req.session.oauth_access_token_secret
        (error, data, response) ->
            feed = JSON.parse(data)
            res.send feed
    )


app.listen 3000
console.log "listening on http://localhost:3000"
