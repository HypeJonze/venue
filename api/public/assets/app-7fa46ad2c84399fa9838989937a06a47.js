'use strict';

window.gpAsyncInit = function() {
  angular.element('body').scope().gapiLoaded = true;
};
angular.module('VenueAdminApp', [
  'ngAnimate',
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ui.router',
  'ui.bootstrap'
])
.constant('API_BASE_URL', "http://venuetoronto.herokuapp.com")
// .constant('API_BASE_URL', "http://localhost:3000")
.run(['$rootScope', '$state', '$stateParams', '$window', '$q', '$http', 'API_BASE_URL', 'Auth', '$modal', '$timeout',
  function ($rootScope, $state, $stateParams, $window, $q, $http, API_BASE_URL, Auth, $modal, $timeout) {
    // Should be switched to true when gapi is ready...
    $rootScope.gapiLoaded = false;

    $rootScope.loadingModal = null;
    $rootScope.loadingPromises = [];

    $rootScope.waitForPromise = function(promise) {
      var isFirst = $rootScope.loadingPromises.length === 0;
      $rootScope.loadingPromises.push(promise);
      if (isFirst) {
        $rootScope.loadingModal = $modal.open({
          templateUrl: asset_path('partials/loading_modal.html'),
          backdrop: 'static',
          keyboard: false,
          resolve: {
            promises: function () {
              return $rootScope.loadingPromises;
            }
          },
          controller: ['$modalInstance', 'promises', function($modalInstance, promises) {
            var handlePromiseDone = function() {
              if (promises.length) {
                attachPromise(promises.pop());
              }
              else {
                $modalInstance.dismiss('wait over...');
              }
            }
            var attachPromise = function(promise) {
              promise.then(handlePromiseDone, handlePromiseDone);
            }
            handlePromiseDone();
          }]
        });
      }
    }

    $rootScope.logoUrl = function() {
      return asset_path('logo.png');
    }

    $rootScope.userRole = function() {
      if (Auth.user) {
        return Auth.user.role;
      }
      return Auth.userRoles.public;
    }

    $rootScope.logout = function() {
      Auth.logout();
      $state.go('login');
    }
  
    $rootScope.$on("$stateChangeStart", function (event, toState, toParams, fromState, fromParams) {
      if (!Auth.authorize(toState.data.access)) {
        event.preventDefault();
        if(fromState.url === '^') {
          if(Auth.isLoggedIn()) {
            $state.go(Auth.user.role.title === 'admin' ? "admin.venues" : 'venues');
          } 
          else {
            $state.go('login');
          }
        }
      }
    });
  }
]);
