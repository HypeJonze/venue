angular.module('VenueMobileApp')
.directive('mapLink', function(mapURLBuilder) {
  return {
    restrict: 'E',
    template: "<a ng-click='openMap(venue)' class='map-icon'><i class='ion-ios7-location'></i></a>",
    controller: function($scope, mapURLBuilder) {
      $scope.urlBuilder = new mapURLBuilder;
      $scope.openMap = function(venue) {
        $scope.urlBuilder.mapURL(venue);
      }
    }
  }
});