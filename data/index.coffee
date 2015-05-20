_ = require 'lodash'
async = require 'async'
ProgressBar = require 'progress'

CallsImporter = require './calls'
MessagesImporter = require './messages'
ImagesImporter = require './images'
secret = require './secret'

callsImporter = new CallsImporter(directory: secret.calls.dir)
messagesImporter = new MessagesImporter(directory: secret.messages.dir)
imagesImporter = new ImagesImporter(directory: secret.images.dir)

async.series
    # calls: (cb) -> callsImporter.execute(cb)
    # messages: (cb) -> messagesImporter.execute(cb)
    images: (cb) -> imagesImporter.execute(cb)
, (e, d) ->
    if e?
        console.trace(e)
    else
        # return console.log d

