mongoose = require '../connection'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

MessageSchema = new Schema(
  Name: String
  Subject: String
  Message: String
  Date: Date
  Phone: String
  Country: String
  Attachments: String
)

Message = mongoose.model('Message', MessageSchema)

module.exports = Message
