;(function(){

  function drawDistancesGraph(svg, data, svgWidth, svgHeight) {
    var
      margin,
      width,
      height,
      x,
      y,
      xAxis,
      yAxis,
      line;

    margin = {
      top: 20,
      right: 20,
      bottom: 20,
      left: 20
    };
    width = svgWidth - margin.left - margin.right;
    height = svgHeight - margin.top - margin.bottom;

    x = d3.scale.linear()
        .domain([0, data[data.length - 1].x])
        .range([0, width]);

    y = d3.scale.linear()
        .domain([0, 1500])
        .range([height, 0]);

    xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    yAxis = d3.svg.axis()
        .scale(y)
        .orient("right");

    this.d3line = line = d3.svg.line()
        .x(function(d) { return x(d.x); })
        .y(function(d) { return y(d.y); });

    svg
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis);

    svg.append("path")
        .datum(data)
        .attr("class", "line")
        .attr("d", line);
  }

  var
    root = this,
    app = root.app = root.app || {};

  var TSPViewBase = Backbone.View.extend({
    events: {
      "click .execute": "execute",
      "click .clear": "clear"
    },

    initialize: function(options) {
      this.tsp = options.tsp;

      this.$distancesGraph = this.$el.find(".distances-graph svg");
      this.d3svg = d3.select(this.$distancesGraph[0]);

      this.$routeGraph = this.$el.find(".route-graph canvas");
      this.canvasContext = this.$routeGraph[0].getContext("2d");
      this.initializeCanvasContext(this.canvasContext);

      this.$totalDistance = this.$el.find(".total-distance");
      this.$finalRoute = this.$el.find(".final-route");

      this.$step = this.$el.find(".step");
      this.$initialRoute = this.$el.find(".initial-route");
    },

    initializeCanvasContext: function(context) {
      var
        width = context.canvas.width,
        height = context.canvas.height;
      context.setTransform(width / 70, 0, 0, -height / 70, 0, height);
      context.lineJoin ="round";
      context.lineWidth = 0.75;
    },

    execute: function() {
    },

    drawTransitions: function(route, transitions) {
      this.clear();
      this.drawDistances(transitions.distances);
      this.drawRoute(route);
    },

    drawDistances: function(distances) {
      var
        step = Number(this.$step.val()),
        svg = this.d3svg,
        width = svg.attr("width"),
        height = svg.attr("height"),
        data;

      data = _.compact(distances.map(function(distance, i) {
        if (i % step === 0) {
          return {
            x: i,
            y: distance
          };
        }
      }));

      drawDistancesGraph(svg, data, width, height);
    },

    drawRoute: function(route) {
      var
        context = this.canvasContext;

      context.beginPath();

      context.moveTo.apply(context, route[0]);
      for(var i in route){
        context.lineTo.apply(context, route[i]);
      }
      context.lineTo.apply(context, route[0]);

      context.closePath();
      context.stroke();
    },

    clear: function() {
      this.clearTransitions();
      this.clearRoute();
    },

    clearTransitions: function() {
      this.$distancesGraph.children().remove();
    },

    clearRoute: function() {
      var
        context = this.canvasContext,
        width = context.canvas.width,
        height = context.canvas.height;

      context.clearRect(0, 0, width, height);
    }

  });


  app.HillclimbView = TSPViewBase.extend({
    el: "#hillclimb",

    initialize: function(options) {
      TSPViewBase.prototype.initialize.call(this, options);

      this.$iterations = this.$el.find(".iterations");
    },

    execute: function() {
      var
        iterations = Number(this.$iterations.val()),
        route = eval(this.$initialRoute.val()),
        hillclimb = this.tsp.hillclimb,
        transitions;

      transitions = hillclimb(route, iterations);

      this.drawTransitions(route, transitions);
      this.$totalDistance.text(this.tsp.totalDistance(route));
      this.$finalRoute.text(JSON.stringify(route));

    }

  });

  app.SimulatedAnnealingView = TSPViewBase.extend({
    el: "#simulated-annealing",

    initialize: function(options) {
      TSPViewBase.prototype.initialize.call(this, options);

      this.$initialT = this.$el.find(".initial-t");
      this.$finalT = this.$el.find(".final-t");
      this.$freq = this.$el.find(".freq");
      this.$coolingRate = this.$el.find(".cooling-rate");
    },

    execute: function() {
      var
        initialT = Number(this.$initialT.val()),
        finalT = Number(this.$finalT.val()),
        freq = Number(this.$freq.val()),
        coolingRate = Number(this.$coolingRate.val()),
        route = eval(this.$initialRoute.val()),
        options,
        sa = this.tsp.sa,
        transitions;

      options = {
        initialT: initialT,
        finalT: finalT,
        freq: freq,
        coolingRate: coolingRate
      };

      transitions = sa(route, options);
      this.drawTransitions(route, transitions);
      this.$totalDistance.text(this.tsp.totalDistance(route));
      this.$finalRoute.text(JSON.stringify(route));

    }

  });


}).call(this);


