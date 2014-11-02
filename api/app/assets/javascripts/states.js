'user strict';

angular.module('VenueAdminApp').config(['$stateProvider', '$urlRouterProvider',
  function ($stateProvider, $urlRouterProvider) {

    var access = routingConfig.accessLevels;

    // default route for invalid requests
    $urlRouterProvider.otherwise('/login');

    //////////////////////////
    // State Configurations //
    //////////////////////////

    // Use $stateProvider to configure your states.
    $stateProvider

      ///////////////
      // Directory //
      ///////////////

      // Auth/Account pages
      .state("login", {
        url: "/login",
        data: {
          access: access.public
        },
        views: {
          main: {
            templateUrl: asset_path('login.html'),
            controller: "LoginController"
          }
        }
      })

      // Admin Pages
      .state("admin", {
        url: "/admin",
        data: {
          access: access.admin
        },
        views: {
          menu: {
            templateUrl: asset_path('partials/admin_menu.html'),
          },
          main: {
            template: '<ui-view/>'
          }
        }
      })
      .state("admin.venues", {
        url: "/venues",
        templateUrl: asset_path('venues.html'),
        controller: "VenuesController"
      })
      .state("admin.keywords", {
        url: "/keywords",
        templateUrl: asset_path('keywords.html'),
        controller: "KeywordsController"
      })
      .state("admin.categories", {
        url: "/categories",
        templateUrl: asset_path('categories.html'),
        controller: "CategoriesController"
      })
      .state("admin.neighbourhoods", {
        url: "/neighbourhoods",
        templateUrl: asset_path('neighbourhoods.html'),
        controller: "NeighbourhoodsController"
      })
      .state("admin.venue_types", {
        url: "/venue-types",
        templateUrl: asset_path('venue_types.html'),
        controller: "VenueTypesController"
      })

      // User pages
      .state("user", {
        url: "/venues",
        data: {
          access: access.user
        },
        views: {
          main: {
            templateUrl: asset_path('venues.html'),
            controller: "VenuesController"
          }
        }
      })
  }
])
