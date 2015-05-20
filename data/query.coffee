schemas = require '../shared/db/schemas/'

# schemas.Message.byCount console.log


glob = require 'glob'

dir = '/Users/yang/Dropbox/Settings/Messages/Attachments'
results = glob.sync("**/*.*", cwd: dir)
