
//module.exports = require('./lib/mediacapture');

var static = require('node-static'),
	http = require('http'),
	fileserver = new static.Server('./', { cache: false });

require('http').createServer(function (request, response) {
    request.addListener('end', function () {
        fileserver.serve(request, response);
    });
}).listen(8080);
