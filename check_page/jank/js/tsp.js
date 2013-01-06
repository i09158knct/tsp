;(function _tsp() {
  function distance(point1, point2) {
    var
      dx = point1[0] - point2[0],
      dy = point1[1] - point2[1];

    return Math.sqrt(dx * dx + dy * dy);
  }


  function totalDistance(points) {
    var
      total = 0,
      length = points.length,
      i;

    for (i = 1; i < length; i++) {
      total += distance(points[i], points[i - 1]);
    }

    total += distance(points[0], points[length - 1]);
    return total;
  }


  function swap(array, index1, index2) {
    var
      tmp;

    tmp = array[index1];
    array[index1] = array[index2];
    array[index2] = tmp;
  }


  function hillclimb(route, maxIterations) {
    var
      numOfCities = route.length,

      transitions = {},
      distances = transitions.distances = [],
      selectedIndexHistory = transitions.selectedIndexHistory = [],

      currentIterations,
      currentTotalDistance,
      newTotalDistance,
      randomIndex1,
      randomIndex2;

    currentTotalDistance = totalDistance(route);

    for (currentIterations = 0; currentIterations < maxIterations; currentIterations++) {
      randomIndex1 = Math.floor(Math.random() * numOfCities);
      randomIndex2 = Math.floor(Math.random() * numOfCities);

      swap(route, randomIndex1, randomIndex2);

      newTotalDistance = totalDistance(route);

      if (newTotalDistance < currentTotalDistance) {
        currentTotalDistance = newTotalDistance;
        selectedIndexHistory.push([randomIndex1, randomIndex2]);
      } else {
        swap(route, randomIndex1, randomIndex2);
        selectedIndexHistory.push([0, 0]);
      }

      distances.push(currentTotalDistance);
    }

    return transitions;
  }

  function sa(route, params) {

    function shouldChange(delta, t) {
      if (delta <= 0) return true;
      if (Math.random() < Math.exp(- delta / t)) return true;
      return false;
    }

    var
      numOfCities = route.length,

      transitions = {},
      distances = transitions.distances = [],
      selectedIndexHistory = transitions.selectedIndexHistory = [],

      defaults,
      t,
      finalT,
      freq,
      coolingRate,
      currentTotalDistance,
      newTotalDistance,
      randomIndex1,
      randomIndex2,
      i;

    params = params || {};

    defaults = {
      initialT: 100,
      finalT: 0.8,
      freq: 1000,
      coolingRate: 0.9
    };

    t = params.initialT || defaults.initialT;
    finalT = params.finalT || defaults.finalT;
    freq = params.freq || defaults.freq;
    coolingRate = params.coolingRate || defaults.coolingRate;

    currentTotalDistance = totalDistance(route);

    for (; t > finalT; t *= coolingRate) {
      for (i = 0; i < freq; i++) {
        randomIndex1 = Math.floor(Math.random() * numOfCities);
        randomIndex2 = Math.floor(Math.random() * numOfCities);

        swap(route, randomIndex1, randomIndex2);

        newTotalDistance = totalDistance(route);

        if (shouldChange(newTotalDistance - currentTotalDistance, t)) {
          currentTotalDistance = newTotalDistance;
          selectedIndexHistory.push([randomIndex1, randomIndex2]);
        } else {
          swap(route, randomIndex1, randomIndex2);
          selectedIndexHistory.push([0, 0]);
        }

        distances.push(currentTotalDistance);
      }
    }

    return transitions;
  }

  var
    root = this,
    tsp = root.tsp = {};

  tsp.distance = distance;
  tsp.totalDistance = totalDistance;
  tsp.swap = swap;
  tsp.hillclimb = hillclimb;
  tsp.sa = sa;

}).call(this);
