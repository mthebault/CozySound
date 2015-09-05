# See documentation on https://github.com/cozy/cozy-db

cozydb = require 'cozydb'

module.exports =
    track:
        all: cozydb.defaultRequests.all
        byRange: (doc) -> emit (doc.path + '/' + doc.name), doc
    album:
        all: cozydb.defaultRequests.all
