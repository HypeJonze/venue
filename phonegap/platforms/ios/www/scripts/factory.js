angular.module('VenueMobileApp')
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
