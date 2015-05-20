
messages = {}

freqAnalysis = (data) ->
    _.each data, (ms, i) ->
        _.merge messages, ms.getTimestamps()
    freq = _.chain(messages)
        .map((timestamps, name) ->
            last = moment.unix(_.last(timestamps)).fromNow()
            [name, timestamps.length, last])
        .sortBy('1')
        .reverse()
        .value()
    console.log freq



console.log _.chain(rows)
    .groupBy('Number')
    .each((calls, number) ->
        times = _.chain(calls)
            .pluck('Date')
            .map((date) -> moment(date))
            .sortBy((date) -> date.unix())
            .value()
        calls.splice.apply(calls, [0, calls.length].concat([number, times.length, _.last(times).fromNow()]))
    )
    .sortBy(1)
    .reverse()
    .value()
