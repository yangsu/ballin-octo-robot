mongoose = require '../connection'

MessageSchema = new mongoose.Schema(
  Name: String
  Subject: String
  Message: String
  Date: Date
  'Phone Number': String
  Country: String
  Attachments: String
  hash: String
)

MessageSchema.statics.byCount = (cb) ->
    this.aggregate [
        {
            $group:
                _id: '$Phone Number'
                count: $sum: 1
        }
        {
            $sort:
                count: -1
        }
        {
            $project:
                'Phone Number': '$_id'
                count: 1
                _id: 0
        }
    ], cb

MessageSchema.index({'Phone Number': 1, Date: 1})
MessageSchema.index({hash: 1})

Message = mongoose.model('Message', MessageSchema)

module.exports = Message
