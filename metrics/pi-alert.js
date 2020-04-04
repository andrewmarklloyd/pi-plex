'use latest';
const express = require('express');
const { fromExpress } = require('webtask-tools');
const app = express();
app.use(express.json());
const Twilio = require('twilio');
const ALERT_USAGE = 80;

function sendText(secrets, message) {
  console.log(message)
  const client = new Twilio(secrets.ACCOUNT_SID, secrets.AUTH_TOKEN);
  client.messages.create({
    body: message,
    to: secrets.TO,
    from: secrets.FROM
  })
  .catch(e => {
    console.log(e);
  })
}

app.post('/api/metrics', (req, res) => {
  const secrets = req.webtaskContext.secrets;
  if (req.headers["x-api-key"] === secrets.API_TOKEN) {
    const keys = Object.keys(req.body.metrics)
    req.webtaskContext.storage.get(function (error, data) {
      if (error) return console.log(error);
      var volumes = ""
      req.body.metrics.forEach((metric) => {
        const key = Object.keys(metric);
        if (data.ack === false && parseInt(metric[key]) >= ALERT_USAGE) {
          volumes += `${key}: ${metric[key]}% `
        }
      });
      if (volumes !== "") {
        sendText(secrets, `Pi volume(s) are above ${ALERT_USAGE}% disk usage: ${volumes}. To acknowledge alert, set the ack to true in the Pi Metrics sheet.`)
      }
      res.set('Content-Type', 'application/json');
      res.status(200).json({result: 'success'});
    })
  } else {
    console.log("Unauthorized request")
    res.status(400).json({err: 'NOT AUTHORIZED'});
  }
});

app.post('/api/ack', (req, res) => {
  const secrets = req.webtaskContext.secrets;
  if (req.headers["x-api-key"] === secrets.API_TOKEN) {
    req.webtaskContext.storage.set({ ack: req.body.ack }, { force: 1 }, function (error) {
      if (error) return console.log(error);
    });
    res.set('Content-Type', 'application/json');
    res.status(200).json({result: 'success', ack: req.body.ack});
  } else {
    console.log("Unauthorized request")
    res.status(400).json({err: 'NOT AUTHORIZED'});
  }
});

module.exports = fromExpress(app);
