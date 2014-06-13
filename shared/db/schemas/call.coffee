mongoose = require '../connection'

CallSchema = new mongoose.Schema(
  Number: String
  Date: Date
  Duration: Number
  Type: String
)

CallSchema.index({Number: 1, Date: 1})

Call = mongoose.model('Call', CallSchema)

module.exports = Call
