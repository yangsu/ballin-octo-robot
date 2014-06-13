mongoose = require '../connection'

CallSchema = new mongoose.Schema(
  Number: String
  Date: Date
  Duration: Number
  Type: String,
  hash: String
)

CallSchema.index({Number: 1, Date: 1})
CallSchema.index({hash: 1})

Call = mongoose.model('Call', CallSchema)

module.exports = Call
