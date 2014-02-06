function(key, values, rereduce) {
  var result = {
    points: 0,
    reasons: []};

    for(i=0; i < values.length; i++) {
      currValue = values[i];
      result.points += currValue.points;
      reason = currValue.reason || null;
      from = currValue.awardedBy || null;

      if (reason && from) {
        var reasonObj = {
          points: currValue.points,
          awardedBy: from,
          reason: reason };

          result.reasons.push(reasonObj);
      }

    }
    return(result);
}
