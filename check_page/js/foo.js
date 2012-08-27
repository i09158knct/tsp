(function(w){
  /*
  context: canvasのcontext
  points: [x, y] の配列  ex) [[10,10], [20,30]]
  */
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
    var p_m = points.reduce(function(s, point){
      return [ point, dis(s[0], point) + s[1] ];
    }, [points[points.length - 1], 0]);
    return p_m[1];
  };


  w.initialRoute = [[37,52],[49,49],[52,64],[20,26],[40,30],[21,47],[17,63],[31,62],[52,33],[51,21],[42,41],[31,32],[5,25],[12,42],[36,16],[52,41],[27,23],[17,33],[13,13],[57,58],[62,42],[42,57],[16,57],[8,52],[7,38],[27,68],[30,48],[43,67],[58,48],[58,27],[37,69],[38,46],[46,10],[61,33],[62,63],[63,69],[32,22],[45,35],[59,15],[5,6],[10,17],[21,10],[5,64],[30,15],[39,10],[32,39],[25,32],[25,55],[48,28],[56,37],[30,40]];

})(this);


