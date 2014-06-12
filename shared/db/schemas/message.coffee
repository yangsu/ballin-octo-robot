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

MessageSchema.index({'Phone Number': 1})

Message = mongoose.model('Message', MessageSchema)

module.exports = Message
