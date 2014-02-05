function(key, values, rereduce) {
  var reason = [];
  var result = {
    points: 0,
    reasons: []};

    for(i=0; i < values.length; i++) {
      currValue = values[i];
      result.points += currValue.points;
      from = currValue.awardedBy || null;

      // if we have reasons we need to loop through them
      // and pass it into a reasons object
      if (currValue.reason && from) {
        var reasonObj = {
          points: currValue.points,
          awardedBy: from,
          reason: currValue.reason
        };

        result.reasons.push(reasonObj);
      }

    }
    return(result);
}
