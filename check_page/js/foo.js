(function(w){

  w.drowLines = function(context, points){
    context.beginPath();

    context.moveTo.apply(context, points[0]);
    for(var i in points){
      context.lineTo.apply(context, points[i]);
    }
    context.lineTo.apply(context, points[0]);

    context.closePath();
    context.stroke();
  };

  var dis = function(p1, p2){
    var dx = p1[0] - p2[0];
    var dy = p1[1] - p2[1];

    return Math.sqrt( dx*dx + dy*dy );
  };

  w.totalDis = function(points){
    var result = points.reduce(function(prevPoint_sumDis, point){
      return [ point, dis(prevPoint_sumDis[0], point) + prevPoint_sumDis[1] ];
    }, [ points[points.length-1], 0 ]);
    return result[1];
  };

})(this);


