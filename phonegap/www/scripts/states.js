angular.module('VenueMobileApp').config(['$stateProvider', '$urlRouterProvider',
  function ($stateProvider, $urlRouterProvider) {

    // default route for invalid requests
    $urlRouterProvider.otherwise('/');

    //////////////////////////
    // State Configurations //
    //////////////////////////

    // Use $stateProvider to configure your states.
    $stateProvider

      ///////////
      // start //
      ///////////
      .state("start", {
        url: "/",
        templateUrl: "views/start.html",
        controller: "StartController"
      })

      ////////////
      // Search //
      ////////////
      .state("search", {
        abstract: true,
        url: "/search",
        template: '<div ui-view autoscroll="false"></div>',
        controller: "SearchController"
      })    

      /////////////////////
      // Search - Step 1 //
      /////////////////////
      .state("search_choose_venue_type", {
        url: "/choose-venue-type",
        templateUrl: "views/search-choose-venue-type.html",
        controller: "ChooseVenueTypeController"
      })    

      /////////////////////
      // Search - Step 2 //
      /////////////////////
      .state("search_choose_location", {
        url: "/choose-location/:venueTypeId",
        templateUrl: "views/search-choose-location.html",
        controller: "ChooseLocationController"
      })

      /////////////////////
      // Search - Step 3 //
      /////////////////////
      .state("search_choose_keywords", {
        url: "/choose-keywords/:venueTypeId/:neighbourhoodId",
        templateUrl: "views/search-choose-keywords.html",
        controller: "ChooseKeywordsController"
      })

      //////////////////////
      // Search - Results //
      //////////////////////
      .state("search_results", {
        url: "/results/:venueTypeId/:neighbourhoodId/:keywordIds",
        templateUrl: "views/search-results.html",
        controller: "SearchResultsController"
      })

      /////////
      // Cab //
      /////////
      .state("cab", {
        url: "/cab",
        templateUrl: "views/cab.html",
        controller: "CabController"
      })    


      ///////////
      // About //
      ///////////
      .state("about", {
        url: "/about",
        templateUrl: "views/about.html",
        controller: "AboutController"
      })    

      //////////////
      // Featured //
      //////////////
      .state("featured", {
        url: "/featured",
        templateUrl: "views/featured.html",
        controller: "FeaturedController"
      })    
      //////////
      // View //
      //////////
      .state("view_venue", {
        url: "/view-venue/:venueId",
        templateUrl: "views/view-venue.html",
        controller: "VenueViewController"
      })    
  }
])
