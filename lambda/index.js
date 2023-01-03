'use strict';
exports.handler = (event, context, callback) => {

  const request = event.Records[0].cf.request;

  const olduri = request.uri;
  let newuri = olduri;

  const country = request.headers["cloudfront-viewer-country"][0].value
  
  const strIsPrimary = request.origin.s3.customHeaders.primary[0].value
  const isPrimary = strIsPrimary === true || ['true','yes','1'].indexOf(strIsPrimary.toString().toLowerCase()) > -1
  
  if (isPrimary) {
    newuri = `/${country}${olduri}`;
  }

  console.log("IsPrimary : " + isPrimary + " Old URI: " + olduri + " New URI: " + newuri +  " country : " + country);

  request.uri = newuri;

  return callback(null, request);
};