'use strict';

angular.module('VenueAdminApp')
  .factory('Auth', function($http, $cookieStore) {
    var accessLevels = routingConfig.accessLevels
        , userRoles = routingConfig.userRoles
        , currentUser = $cookieStore.get('user') || { role: userRoles.public };

    $http.defaults.headers.common['X-AuthToken'] = currentUser.api_token;

    function changeUser(user) {
      console.debug(user);
      user.role = user.role === 'admin' ? userRoles.admin : userRoles.user;
      currentUser = user;
      $http.defaults.headers.common['X-AuthToken'] = currentUser.api_token;
      $cookieStore.put("user", user);
    }

    return {
      logout: function() {
        $cookieStore.remove('user');
        delete $http.defaults.headers.common['X-AuthToken'];
        currentUser = null;
        this.user = null;
      },
      authorize: function(accessLevel, role) {
        if(role === undefined) {
          role = currentUser ? currentUser.role : userRoles.public;
        }
        console.log("authorize called for accessLevel: " + JSON.stringify(accessLevel) + ", by role: " + role.title);

        return accessLevel.bitMask & role.bitMask;
      },
      isLoggedIn: function(user) {
        if(user === undefined) {
          user = currentUser;
        }
        return user.role.title === userRoles.user.title || user.role.title === userRoles.admin.title;
      },
      updateUser: function(user) {
        changeUser(user);
        this.user = user;
      },
      accessLevels: accessLevels,
      userRoles: userRoles,
      user: currentUser
    };
  })
  .factory('VenueType', ['$resource', 'API_BASE_URL', function($resource, API_BASE_URL) {
    return $resource(API_BASE_URL + '/api/v1/venue_types/:id', 
      {
        id: '@id'
      }, 
      {
        update: { method:'PUT' },
        destroy: { method:'DELETE' },
        count: { 
          method:'GET', 
          url:'/api/v1/venue_types/count'
        }
      });
  }])
  .factory('Venue', ['$resource', 'API_BASE_URL', function($resource, API_BASE_URL) {
    return $resource(API_BASE_URL + '/api/v1/venues/:id', 
      {
        id: '@id'
      }, 
      {
        update: { method:'PUT' },
        destroy: { method:'DELETE' },
        count: { 
          method:'GET', 
          url:'/api/v1/venues/count'
        }
      });
  }])
  .factory('Category', ['$resource', 'API_BASE_URL', function($resource, API_BASE_URL) {
    return $resource(API_BASE_URL + '/api/v1/categories/:id', 
      {
        id: '@id'
      }, 
      {
        update: { method:'PUT' },
        destroy: { method:'DELETE' },
        count: { 
          method:'GET', 
          url:'/api/v1/categories/count'
        }
      });
  }])
  .factory('Keyword', ['$resource', 'API_BASE_URL', function($resource, API_BASE_URL) {
    return $resource(API_BASE_URL + '/api/v1/keywords/:id', 
      {
        id: '@id'
      }, 
      {
        update: { method:'PUT' },
        destroy: { method:'DELETE' },
        count: { 
          method:'GET', 
          url:'/api/v1/keywords/count'
        }
      });
  }])
  .factory('Neighbourhood', ['$resource', 'API_BASE_URL', function($resource, API_BASE_URL) {
    return $resource(API_BASE_URL + '/api/v1/neighbourhoods/:id', 
      {
        id: '@id'
      }, 
      {
        update: { method:'PUT' },
        destroy: { method:'DELETE' },
        count: { 
          method:'GET', 
          url:'/api/v1/neighbourhoods/count'
        }
      });
  }])
  ;
