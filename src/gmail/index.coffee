secret = require '../secret'
console.log secret

openInbox = (cb) ->
    imap.openBox 'INBOX', true, cb
processEmail = (seqno, header, email) ->
    boundary = email.match(/boundary=\'([^']+)\'/)[1]
    parts = email.split(boundary)
    body = parts[2]
    _.each parts, (part, i) ->
        console.log body.slice(0, 50)
        fs.writeFile seqno + '-' + i + '.txt', part, (err) ->
            throw err  if err
            console.log 'It\'s saved!'


fs = require('fs')
_ = require('lodash')
Imap = require('imap')
inspect = require('util').inspect
MailParser = require('mailparser').MailParser
imap = new Imap(
    user: secret.gmail.username
    password: secret.gmail.password
    host: 'imap.gmail.com'
    port: 993
    tls: true
    tlsOptions:
        rejectUnauthorized: false
)
imap.once 'ready', ->
    openInbox (err, box) ->
        throw err  if err
        imap.search [['x-gm-labels', 'Newsletters']], (err, results) ->
            throw err  if err
            f = imap.fetch(results,
                bodies: ''
            )
            f.on 'message', (msg, seqno) ->
                console.log 'Message #%d', seqno
                mailparser = new MailParser()

                # setup an event listener when the parsing finishes
                mailparser.on 'end', (mail_object) ->
                    #[{address:'sender@example.com',name:'Sender Name'}]
                    console.log 'From:', mail_object.from
                    console.log 'Subject:', mail_object.subject # Hello world!
                    console.log 'Text body:', mail_object.text # How are you today?

                prefix = '(#' + seqno + ') '
                msg.on 'body', (stream, info) ->
                    console.log prefix + 'Body' + ' xxx '
                    console.log info
                    console.log prefix + 'Body [%s] found, %d total bytes', inspect(info.which), info.size  if info.which is ''
                    buffer = ''
                    count = 0
                    stream.on 'data', (chunk) ->
                        count += chunk.length
                        buffer += chunk.toString('utf8')
                        console.log prefix + 'Body [%s] (%d/%d)', inspect(info.which), count, info.size  if info.which is ''

                    stream.once 'end', ->
                        unless info.which isnt ''
                            console.log prefix + 'Body [%s] Finished', inspect(info.which)
                            processEmail seqno, Imap.parseHeader(buffer), buffer

                    console.log info
                    stream.pipe fs.createWriteStream('msg-' + seqno + '-body.txt')
                    buffer = ''
                    stream.on 'data', (chunk) ->
                        buffer += chunk.toString('utf8')

                    stream.once 'end', ->
                        console.log prefix + 'Parsed header: %s', inspect(Imap.parseHeader(buffer))
                        mailparser.write ''

                        # send the email source to the parser
                        mailparser.end()


                msg.once 'attributes', (attrs) ->
                    console.log prefix + 'Attributes: %s', inspect(attrs, false, 8)

                msg.once 'end', ->
                    console.log prefix + 'Finished'


            f.once 'error', (err) ->
                console.log 'Fetch error: ' + err

            f.once 'end', ->
                console.log 'Done fetching all messages!'
                imap.end()


    openInbox (err, box) ->
        throw err  if err
        f = imap.seq.fetch('1:3',
            bodies: 'HEADER.FIELDS (FROM TO SUBJECT DATE)'
            struct: true
        )
        f.on 'message', (msg, seqno) ->
            console.log 'Message #%d', seqno
            prefix = '(#' + seqno + ') '
            msg.on 'body', (stream, info) ->
                buffer = ''
                stream.on 'data', (chunk) ->
                    buffer += chunk.toString('utf8')

                stream.once 'end', ->
                    console.log prefix + 'Parsed header: %s', inspect(Imap.parseHeader(buffer))


            msg.once 'attributes', (attrs) ->
                console.log prefix + 'Attributes: %s', inspect(attrs, false, 8)

            msg.once 'end', ->
                console.log prefix + 'Finished'


        f.once 'error', (err) ->
            console.log 'Fetch error: ' + err

        f.once 'end', ->
            console.log 'Done fetching all messages!'
            imap.end()



imap.once 'error', (err) ->
    console.log err

imap.once 'end', ->
    console.log 'Connection ended'
    process.exit 0

# imap.connect()
