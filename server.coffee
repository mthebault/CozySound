americano = require 'americano'

port = process.env.PORT || 9250
americano.start name: 'Sound', port: port
