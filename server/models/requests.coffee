# See documentation on https://github.com/cozy/cozy-db

cozydb = require 'cozydb'

module.exports =
    track:
        all: cozydb.defaultRequests.all
