var http = require('http');
var url  = require('url');
var fs   = require('fs');
var path = require('path');
var neededstats = [];

http.createServer(function(request, response) {
    console.log(path.join(__dirname,'./'+request.url))
    if (request.url == '/') {
        response.end('HelloWorld');
    } else {
        fs.readFile(path.join(__dirname,'./'+request.url+'.txt'), function(err, data) {
            console.log(data);
            response.end(data);
        });
    }
}).listen(3000);
console.log('Server running.');
