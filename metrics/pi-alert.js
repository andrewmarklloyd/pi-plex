'use latest';
const express = require('express');
const { fromExpress } = require('webtask-tools');
const app = express();
app.use(express.json());
const Twilio = require('twilio');
const ALERT_USAGE = 80;

function sendText(secrets, message) {
  console.log(message)
  // const client = new Twilio(secrets.ACCOUNT_SID, secrets.AUTH_TOKEN);
  // client.messages.create({
  //   body: message,
  //   to: secrets.TO,
  //   from: secrets.FROM
  // })
  // .catch(e => {
  //   console.log(e);
  // })
}

app.post('/api/metrics', (req, res) => {
  const secrets = req.webtaskContext.secrets;
  if (req.headers["x-api-key"] === secrets.API_TOKEN) {
    const keys = Object.keys(req.body.metrics)
    req.body.metrics.forEach((metric) => {
      const key = Object.keys(metric);
      if (metric[key] >= ALERT_USAGE) {
        sendText(secrets, `Pi volume ${key} alert, disk usage ${metric[key]}% is above ${ALERT_USAGE}%`)
      }
    });

    res.set('Content-Type', 'application/json');
    res.status(200).json({result: 'success'});
  } else {
    console.log("Unauthorized request")
    res.status(400).json({err: 'NOT AUTHORIZED'});
  }
});

module.exports = fromExpress(app);
