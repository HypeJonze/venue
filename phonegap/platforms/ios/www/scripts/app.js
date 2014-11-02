'use strict';

angular.module('VenueMobileApp', [
  'ionic',
  'ngAnimate',
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ui.router'
])
.constant('API_BASE_URL', "http://venuetoronto.herokuapp.com")
// .constant('API_BASE_URL', "http://127.0.0.1:3000")
.run(['$rootScope', '$state', '$stateParams', '$window', '$q', '$http', 'Neighbourhood', 'API_BASE_URL',
  function ($rootScope, $state, $stateParams, $window, $q, $http, Neighbourhood, API_BASE_URL) {
    $rootScope.$state = $state;
    $rootScope.$stateParams = $stateParams;

    $rootScope.menuDataLoaded = false;
    $rootScope.menuData = {
      venue_types: [],
      categories: {},
      keywords: {},
      neighbourhoods: Neighbourhood.query(),
    }

    // bundle main request and neighbourhoods request in one
    var keywordsHierarchyDeferred = $q.defer();
    $rootScope.dataLoadedPromise = $q.all([
      keywordsHierarchyDeferred.promise, 
      $rootScope.menuData.neighbourhoods.$promise
    ]);

    // Forward the 'completed' status to the scope variable being watched.
    $rootScope.dataLoadedPromise.then(function() { $rootScope.menuDataLoaded = true });

    $rootScope.fetchMetaData = function() {
      var menu_data_request = $http.get(API_BASE_URL + "/api/v1/search/meta")
        .success(function(data, status, headers, config) {
          var venue_types = [];

          // map categories by their ids
          for (var i = 0; i < data.categories.length; i++) {
            var category = data.categories[i];
            $rootScope.menuData.categories[category.id] = category;
          }

          // map keywords by their ids
          for (var i = 0; i < data.keywords.length; i++) {
            var keyword = data.keywords[i];
            $rootScope.menuData.keywords[keyword.id] = keyword;
          }

          // setup the venue_type -> category -> keyword heirarchy
          for (var i = 0; i < data.venue_types.length; i++) {
            var venue_type = data.venue_types[i];
            var v_type = {
              id: venue_type.id,
              name: venue_type.name,
              categories: []
            };
            for (var l = 0; l < venue_type.category_ids.length; l++) {
              var category_id = venue_type.category_ids[l];
              var category_keywords = [];
              for (var j = 0; j < venue_type.keyword_ids.length; j++) {
                var keyword = $rootScope.menuData.keywords[venue_type.keyword_ids[j]];
                if (keyword.category_id == category_id) {
                  category_keywords.push(keyword);
                }
              }
              v_type.categories.push({
                id: $rootScope.menuData.categories[category_id].id, 
                name: $rootScope.menuData.categories[category_id].name, 
                keywords: category_keywords
              });
            }
            venue_types.push(v_type);
          }
          $rootScope.menuData.venue_types = venue_types;
          keywordsHierarchyDeferred.resolve(true);
        })
        .error(function(data, status, headers, config) {
          console.debug(data);
        });
    }
    $rootScope.fetchMetaData();


    $rootScope.viewportWidth = function () {
      return $($window).width();
    }

    $rootScope.viewportHeight = function () {
      return $($window).height();
    }

    $rootScope.logoTitle = '<img src="img/logo.png" class="header-logo" />';

    $rootScope.safeStateName = function() {
      return $state.current.name.replace(".", "_");
    }
    
    $rootScope.rightButtons = [
      {
        type: 'button-dark',
        content: '<i class="icon ion-home"></i>',
        tap: function(e) {
          $state.go("start");
        }
      }
    ]
  }
]);