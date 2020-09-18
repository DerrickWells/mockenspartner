const AESEncryptor = require('./lib/AESEncryptor')
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const dateFormat = require('dateformat');
const express = require('express');
const logger = require('morgan');

var app = express();
var rawParser = bodyParser.raw();

// view engine setup
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

// error handler <-- will send error trace to anyone atm
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  // res.render('error'); // <-- for gui rendering disabled due to doesnt exist atm.
});

app.all('*', rawParser, (req, res, next) => {
  var aes = new AESEncryptor;
  var now = new Date();
  var decryptedBody = aes.decrypt(req.body.toString('utf8'), 'password1!');
  setTimeout(()=>{
    console.log(process.env.PORT + ': ' + dateFormat(now, "dddd, mmmm dS, yyyy, h:MM:ss:l TT") + ' - ' + JSON.parse(decryptedBody).GUID);
    res.send(JSON.parse(decryptedBody).GUID);
  }, getTimeout());
});

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getTimeout() {
  return parseInt(process.env.LAT, 10);
}

module.exports = app;
