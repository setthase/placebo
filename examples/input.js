var logger = require("..");

logger.connect(3030);

process.stdin.on("data", function (data) {
  logger.debug(data.toString());
});
