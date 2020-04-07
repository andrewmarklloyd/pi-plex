var ss = SpreadsheetApp.getActiveSpreadsheet();
var configSheet = ss.getSheets()[0];
const ALERT_USAGE = 80;

function doPost(e) {
  const body = JSON.parse(e.postData.contents)
  error = ""
  if (body["x-api-key"] === getAPIKey()) {
    var volumes = ""
    const keys = Object.keys(body.metrics)
    for (var i = 0; i < keys.length; i++){
      usage = body.metrics[keys[i]].substring(0, body.metrics[keys[i]].length - 1)
      if (usage > ALERT_USAGE) {
        volumes += keys[i] + " " + usage + "%, "
      }
      configSheet.getRange('A' + (i + 3)).setValue(keys[i] + ": " + usage + "%")
    }
    if (volumes != "" && getACK() === false) {
      sendMessage(volumes)
      configSheet.getRange('C1').setValue("message sent")
    } else {
      configSheet.getRange('C1').setValue("not sending message");
    }
  } else {
    error = "Unauthorized"
  }

   var response = {
     error: error
   };

  
  var JSONString = JSON.stringify(response);
  var JSONOutput = ContentService.createTextOutput(JSONString);
  JSONOutput.setMimeType(ContentService.MimeType.JSON);
  return JSONOutput
}

function sendMessage(volumes) {
  message = `Pi volume(s) are above ${ALERT_USAGE}% disk usage: ${volumes}. To acknowledge alert, set the ack to true in the Pi Metrics sheet.`
  
  var messages_url = getTwilioURL()

  var payload = {
    "To": getTwilioTO(),
    "Body" : message,
    "From" : getTwilioFrom()
  };

  var options = {
    "method" : "post",
    "payload" : payload
  };

  options.headers = { 
    "Authorization" : "Basic " + Utilities.base64Encode(getTwilioAuth())
  };

  UrlFetchApp.fetch(messages_url, options);
}

function getACK() {
  return configSheet.getRange('B1').getValue();
}

function doGet(e) {
  var appData = {
    "text": "Hello world!"
  };

  var JSONString = JSON.stringify(appData);
  var JSONOutput = ContentService.createTextOutput(JSONString);
  JSONOutput.setMimeType(ContentService.MimeType.JSON);
  return JSONOutput
}
