_ = require 'lodash'
async = require 'async'
glob = require 'glob'
ProgressBar = require 'progress'

{hash} = require '../shared/utils/'

class Importer
    name: 'Generic Importer'

    extension: '*'

    defaults:
        progress:
            width: 50
        parallelLimit:
            dir: 2
            read: 20
            write: 5

    constructor: (options = {}) ->
        @directory = options.directory
        @options = _.merge(@defaults, options)

    filter: _.identity
    parse: (file, cb) -> cb(null, file)
    save: (content, cb) -> cb(null, content)

    readDirectory: (callback) ->
        dirs = if _.isArray @directory then @directory else [@directory]

        readDirectoryTasks = _.map dirs, (dir) =>
            async.apply(glob, "#{dir}/**/*.#{@extension}")

        async.waterfall [
            async.apply(async.parallelLimit, readDirectoryTasks, @options.parallelLimit.dir)
            (files, cb) =>
                filtered = _.chain(files).flatten().filter(@filter).value()
                cb(null, filtered)
        ], callback

    dedup: (contents) -> _.uniq(contents, hash)

    read: (files, callback) ->
        progressBar = new ProgressBar('Reading :current/:total files [:bar] (:percent)', {
            width: @options.progress.width
            total: files.length
        })

        readTasks = _.map files, (file) => (cb) =>
            progressBar.tick()
            @parse(file, cb)

        async.waterfall [
            async.apply(async.parallelLimit, readTasks, @options.parallelLimit.read)
            (contents, cb) -> cb(null, _.flatten(contents))
            (flattenedContents, cb) => cb(null, @dedup(flattenedContents))
        ], callback

    write: (contents, callback) ->
        progressBar = new ProgressBar('Saving :current/:total entries [:bar] (:percent)', {
            width: @options.progress.width
            total: contents.length
        })
        writeTasks = _.map contents, (content) => (cb) =>
            progressBar.tick()
            @save(content, cb)

        async.parallelLimit(writeTasks, @options.parallelLimit.write, callback)

    execute: (callback) ->
        console.log "Running #{@name}..."
        async.waterfall [
            (cb) => @readDirectory(cb)
            (files, cb) => @read(files, cb)
            (contents, cb) => @write(contents, cb)
        ], callback

module.exports = Importer
