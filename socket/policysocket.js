var net = require("net"), sys = require('sys');
var server = net.createServer(function (stream) {
stream.setEncoding("utf8");
stream.on("connect", function () {
});
stream.on("data", function (data) {

if (data == "<policy-file-request/>\0")
{
    var secure = "<?xml version=\"1.0\"?><cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0"; //
    stream.write(secure);
}
else
{
    stream.write(data);
}
});
stream.on("end", function () {
stream.end();
});
});
server.listen(843, "0.0.0.0");
