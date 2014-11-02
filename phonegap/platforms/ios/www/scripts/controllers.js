angular.module('VenueMobileApp')
  .controller('StartController', ['$scope', function ($scope) {
  }])
  .controller('AboutController', ['$scope', 'API_BASE_URL', '$http', function ($scope, API_BASE_URL, $http) {
    $scope.submitting = false;
    $scope.contact = {};
    $scope.contact.name = "";
    $scope.contact.comment = "";
    $scope.submit = function() {
      $scope.submitting = true;
      $http.post(API_BASE_URL + "/contact", { name: $scope.contact.name, comment: $scope.contact.comment }, {headers: {'Content-Type': 'application/json'}})
        .success(function() {
          $scope.contact.name = "";
          $scope.contact.comment = "";
          $scope.submitting = false;
        }).error(function() {
          $scope.contact.name = "";
          $scope.contact.comment = "";
          $scope.submitting = false;
        });
    };
  }])
  .controller('CabController', ['$scope', '$state', '$window', function ($scope, $state, $window) {
  }])
  .controller('FeaturedController', ['$scope', 'Venue', '$ionicSlideBoxDelegate', '$timeout', function ($scope, Venue, $ionicSlideBoxDelegate, $timeout) {
    $scope.dataLoaded = false;
    $scope.featured = Venue.query({featured: 'true', limit: 5});
    $scope.featured.$promise.then(function(result) {
      $timeout(function() {
        $scope.$apply(function() {
          $scope.dataLoaded = true;
          $ionicSlideBoxDelegate.update()
        })
      }, 1000);
    });
  }])
  .controller('ChooseKeywordsController', ['$scope', '$timeout', function ($scope, $timeout) {
    $scope.selected_category_id = null;
    $scope.selected_keywords = [];
    $scope.selectCategory = function (categoryId) {
      $scope.selected_category_id = (categoryId == $scope.selected_category_id) ? null : categoryId;
      $timeout(function() {$scope.$broadcast('scroll.resize')});
    }
    $scope.selectKeyword = function (keywordId) {
      var index = $scope.keywordIndex(keywordId);
      if (index < 0) {
        $scope.selected_keywords.push(keywordId);
        if ($scope.selected_keywords.length > 6) {
          $scope.selected_keywords.shift();
        }
      }
      else {
        $scope.selected_keywords.splice(index, 1);
      }
    }

    $scope.getCategories = function(venueTypeId) {
      for (var i = 0; i < $scope.menuData.venue_types.length; i++) {
        if ($scope.menuData.venue_types[i].id == venueTypeId) return $scope.menuData.venue_types[i].categories
      }
    }

    $scope.keywordIndex = function(keywordId) {
      return jQuery.inArray(keywordId, $scope.selected_keywords);
    }
    $scope.performSearch = function() {
      $scope.$state.transitionTo("search_results", { venueTypeId: $scope.$stateParams.venueTypeId, neighbourhoodId: $scope.$stateParams.neighbourhoodId, keywordIds: $scope.buildKeywordIds() });
    }
    $scope.buildKeywordIds = function() {
      return $scope.selected_keywords.join(',');
    }
  }])
  .controller('ChooseVenueTypeController', ['$scope', function ($scope) {
  }])
  .controller('ChooseLocationController', ['$scope', function ($scope) {
  }])
  .controller('VenueViewController', ['$scope', 'Venue', 'API_BASE_URL', '$ionicSlideBoxDelegate', '$timeout', 
    function ($scope, Venue, API_BASE_URL, $ionicSlideBoxDelegate, $timeout) {
    $scope.attributes = [
      {key: "date", title: "Date"},
      {key: "food", title: "Food"},
      {key: "music", title: "Music"},
      {key: "style", title: "Style"},
      {key: "crowd", title: "Crowd"},
      {key: "specialty", title: "Specialty"},
      {key: "specials", title: "Specials"},
      {key: "price_range", title: "Price Range"},
      {key: "dress_code", title: "Dress Code"},
      {key: "entry_fee", title: "Entry Fee"},
      {key: "hours", title: "Hours"},
      {key: "parking", title: "Parking"}
    ];
    $scope.venueLoaded = false;
    // if (window.plugins && window.plugins.webintent) {
    //   $scope.hasIntent = true;
    //   $scope.platform = window.device.platform;

    //   $scope.mapURL = function(lat, lng, address, label) {
    //     if ($scope.platform == 'Android') {
    //       window.plugins.webintent.startActivity({
    //         action: window.plugins.webintent.ACTION_VIEW,
    //         url: 'geo:' + lat + ',' + lng + '?q=' + address + '(' + label + ')'
    //       },
    //       function() {},
    //       function() {
    //         alert('Failed to open URL via Android Intent')
    //       });
    //     } else {
    //       window.open('maps://?ll=' + lat + ',' + lng + '&q=' + address);
    //     }
    //   };
    // }
    Venue.get({id: $scope.$stateParams.venueId}).$promise.then(function(data) {
      $scope.venue = data;
      $scope.venueLoaded = true;
      $timeout(function(){ $ionicSlideBoxDelegate.update() });
    });

  }])
  .controller('SearchResultsController', ['$scope', 'API_BASE_URL', 'Venue', function ($scope, API_BASE_URL, Venue) {
    $scope.contentLoading = true;
    $scope.noMatches = false;
    $scope.keywordIdsForSearch = [];

    $scope.countKeywordMatches = function(venue) {
      var count = 0;
      for (var i = 0; i < venue.keywords.length; i++) {
        if ($.inArray(venue.keywords[i].id, $scope.keywordIdsForSearch) > -1) {
          count ++;
        }
      }
      return count;
    }

    var params = { venue_type_id: $scope.$stateParams.venueTypeId };
    // add optional neighbourhood id
    if ($scope.$stateParams.neighbourhoodId) params['neighbourhood_id'] = $scope.$stateParams.neighbourhoodId;
    if ($scope.$stateParams.keywordIds) { 
      params['sort_keywords'] = $scope.$stateParams.keywordIds;
      var ids = params["sort_keywords"].split(",");
      for (var i = 0; i < ids.length; i++) {
        $scope.keywordIdsForSearch.push(parseInt(ids[i]));
      }
    }
    var parseResults = function(data) {
      var results = [];
      var rowCount = Math.ceil(data.length/2);
      for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        results[rowIndex] = [];
        for (var j = 0; j < [0, 1].length; j++) {
          if (data[rowIndex*2+j]) results[rowIndex][j] = data[rowIndex*2+j];
        }
      }
      $scope.results = results;
      $scope.contentLoading = false;
    }

    Venue.query(params).$promise.then(function(data) {
      if (data.length == 0 && $scope.keywordIdsForSearch.length > 0) {
        delete params["sort_keywords"];
        $scope.noMatches = true;
        $scope.keywordIdsForSearch = [];
        Venue.query(params).$promise.then(function(data) {
          parseResults(data);
        }, 
        function(reason) { 
          console.log("Error fetching results!!"); 
        });
      }
      else {
        parseResults(data);
      }
    }, 
    function(reason) { 
      console.log("Error fetching results!!"); 
    })

  }]);
