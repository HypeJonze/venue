'use strict';

angular.module('VenueAdminApp')
  .controller('LoginController', ['$scope', '$http', 'Auth', '$state', function($scope, $http, Auth, $state) {
    var handleLogin = function(user) {
      Auth.updateUser(user);
      var redirect_location = Auth.authorize(Auth.userRoles.admin) ? 'admin.venues': 'user';
      $state.transitionTo(redirect_location);
    }

    $scope.loginGooglePlus = function() {
      if (!$scope.gapiLoaded) {
        return;
      }
      $scope.processing = true;
      $scope.buttonText = "Connecting...";
      gapi.auth.authorize({
        response_type: 'code',
        approval_prompt: 'force',
        cookie_policy: 'http://localhost:3000',
        client_id: '616286677689-t3pclbc11spvvv34o3uas432801qf8s9.apps.googleusercontent.com',
        scope: 'email profile'
      }, function(response) {
        if (response && !response.error) {
          response['g-oauth-window'] = null;
          $scope.buttonText = "Authenticating...";
          $http.post("/api/v1/auth/google_oauth2_callback", response,
            { 
              headers: { 
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
              },
              transformRequest: function(data){ return $.param(data); }
            }
          ).success(function(result) {
            handleLogin(result);
          })
          .error(function(response) {
            $scope.resetState();
            console.log("Failure authenticating!");
          });
        } else {
          console.error("gapi.auth.authorize Failure...");
          $scope.resetState();
        }
      });
    };

    $scope.resetState = function() {
      $scope.processing = false;
      $scope.buttonText = "Login with Google";
    }

    $scope.resetState();

  }])
  .controller('AccountController', ['$scope', 'Auth', function ($scope, Auth) {
    $scope.user = Auth.user;
    $scope.logout = function() {
      Auth.logout();
      $scope.user = null;
    }
  }])
  .controller('VenuesController', ['$scope', 'Venue', 'VenueType', 'Neighbourhood', 'Keyword', 'Category','Auth', '$q', '$timeout', '$modal', function ($scope, Venue, VenueType, Neighbourhood, Keyword, Category, Auth, $q, $timeout, $modal) {
    // The venue currently being edited.
    $scope.venueTypesMapping = {};
    $scope.categoriesMapping = {};
    $scope.keywordsMapping = {};
    $scope.availableCategories = [];
    $scope.availableCategoryIds = [];
    $scope.selectedKeyword = null;
    $scope.visibleKeywordCategoryId = null;
    $scope.venueInOperation = null;
    $scope.logoSrc = null;
    $scope.venueTypesToAdd = [];
    $scope.venueTypesToRemove = [];
    $scope.originalVenueTypes = [];
    $scope.currentVenueTypes = [];
    $scope.venueTypeStates = {};
    $scope.venues = [];
    $scope.venuesCount = 0;
    $scope.noVenues = false;
    $scope.photoSlideInterval = 750;
    $scope.noSliderTransition = true;
    $scope.photos = {rows:[]};
    $scope.photo_data = null;
    $scope.photo_file_name = null;
    $scope.photo_file_type = null;
    $scope.photosToAdd = [];
    $scope.photosToRemove = [];
    $scope.numPages = 0;
    $scope.currentPage = 1;

    $scope.$watch("venueInOperation.logo_data", function(newValue, oldValue) {
      if (newValue) {
        $scope.logoSrc = newValue;
      }
    });

    //watches for photo drops and puts new images in 'photosToAdd'...
    $scope.$watch("photo_data", function(newValue, oldValue) {
      if (newValue && $scope.photo_file_type && $scope.photo_file_name) {
        $scope.photosToAdd.push({file_name: $scope.photo_file_name, file_type: $scope.photo_file_type, content: newValue});
        $scope.rebuildPhotos();
      }
      $scope.photo_data = null;
      $scope.photo_file_name = null;
      $scope.photo_file_type = null;
    });

    $scope.save = function() {
      if ($scope.venueInOperation) {
        // attach the array of venue types to remove...
        if ($scope.venueTypesToRemove.length > 0) {
          $scope.venueInOperation.remove_venue_types = $scope.venueTypesToRemove;
        }
        // and the 'to_add' ones...
        if ($scope.venueTypesToAdd.length > 0) {
          $scope.venueInOperation.add_venue_types = $scope.venueTypesToAdd;
        }

        // attach the array of keywords to remove...
        if ($scope.keywordsToRemove.length > 0) {
          $scope.venueInOperation.remove_keywords = $scope.keywordsToRemove;
        }
        // and the 'to_add' ones...
        if ($scope.keywordsToAdd.length > 0) {
          $scope.venueInOperation.add_keywords = $scope.keywordsToAdd;
        }

        // attach the array of photos to remove...
        if ($scope.photosToRemove.length > 0) {
          $scope.venueInOperation.remove_photos = $scope.photosToRemove;
        }
        // and the 'to_add' ones...
        if ($scope.photosToAdd.length > 0) {
          $scope.venueInOperation.add_photos = $scope.photosToAdd;
        }

        var savePromise;
        if (!$scope.venueInOperation.id) {
          savePromise = $scope.venueInOperation.$save();
        }
        else {
          savePromise = $scope.venueInOperation.$update();
        }
        $scope.waitForPromise(savePromise);
        var complete = function() {
          $scope.venueInOperation = null;
          $scope.fetchVenues(1);
        }
        savePromise.then(complete, complete);

      }
    }

    $scope.applyStringfilter = function() {
      $scope.fetchVenues(1);
    }

    $scope.removeStringfilter = function() {
      $scope.searchString = null;
      $scope.fetchVenues(1);
    }

    $scope.destroyVenue = function(venue) {
      var deleteModal = $modal.open({
        templateUrl: asset_path('partials/confirm_delete_modal.html'),
        controller: "ConfirmDeleteModalController",
        resolve: {
          message: function () {
            return "Are you sure you want to delete the Venue by ID: '" + venue.id + "' ?";
          }
        },
        backdrop: 'static'
      })
      deleteModal.result.then(function (result) {
        if (result === true) {
          var deletePromise = venue.$destroy();
          var refresh = function() {
            $scope.availableCategories = [];
            $scope.availableCategoryIds = [];
            $scope.selectedKeyword = null;
            $scope.visibleKeywordCategoryId = null;
            $scope.venueInOperation = null;
            $scope.logoSrc = null;
            $scope.venueTypesToAdd = [];
            $scope.venueTypesToRemove = [];
            $scope.originalVenueTypes = [];
            $scope.currentVenueTypes = [];
            $scope.venueTypeStates = {};
            $scope.venues = [];
            $scope.noVenues = false;
            $scope.noSliderTransition = true;
            $scope.photos = {rows:[]};
            $scope.photo_data = null;
            $scope.photo_file_name = null;
            $scope.photo_file_type = null;
            $scope.photosToAdd = [];
            $scope.photosToRemove = [];
            $scope.fetchVenues(1);
          }
          $scope.waitForPromise(deletePromise);
          deletePromise.then(refresh, refresh);
        }
      });
    }


    $scope.removePhoto = function(photo) {
      if ($scope.venueInOperation) {
        if (photo.id) {
          for (var i = 0; i < $scope.venueInOperation.photos.length; i++) {
            if (photo.id === $scope.venueInOperation.photos[i].id) {
              $scope.venueInOperation.photos.splice(i, 1);
              $scope.photosToRemove.push(photo.id);
            }
          }
        }
        else {
          $scope.photosToAdd.splice($.inArray(photo.src, $scope.photosToAdd), 1);
        }
        $scope.rebuildPhotos();
      }
    }

    $scope.rebuildPhotos = function() {
      $scope.photos = null;
      var photos = [];
      if ($scope.venueInOperation) {
        if ($scope.venueInOperation.photos) {
          for (var i = 0; i < $scope.venueInOperation.photos.length; i++) {
            var photo = $scope.venueInOperation.photos[i];
            if (photo.image && photo.image.filename) {
              photos.push({src: photo.image.path + 'landscape_large_' + photo.image.filename, id: photo.id});
            }
          }
        }
        if ($scope.photosToAdd) {
          for (var i = 0; i < $scope.photosToAdd.length; i++) {
            photos.push({src: $scope.photosToAdd[i].content, id: null, obj: $scope.photosToAdd[i]});
          }
        }
      }
      var rows = [];
      var cols = 2;
      var row_count = Math.ceil(photos.length/cols);
      for (var row_index = 0; row_index < row_count; row_index++) {
        rows[row_index] = [];
        for (var i = 0; i < cols; i++) {
          if (photos[row_index*cols+i]) {
            rows[row_index][i] = photos[row_index*cols+i];
          }
        }
      }

      $scope.photos = {objs: photos, rows: rows};
    }

    $scope.cancel = function() {
      $scope.venueInOperation = null;
    }

    $scope.addNewVenue = function() {
      var venue = new Venue();
      $scope.loadVenueForOperation(venue);
    }

    $scope.fetchVenues = function(page) {
      var pageLimit = 10;
      $scope.currentPage = page;
      $scope.numPages = 0;
      var params = {};
      var position_params = {
        limit: pageLimit,
        offset: (page - 1) * pageLimit
      }
      if (Auth.user.role.title === Auth.userRoles.user.title) {
        params['user_id'] = Auth.user.id;
      }
      if ($scope.searchString && $scope.searchString.length) {
        params['search_name'] = $scope.searchString;
      }
      $scope.venues = Venue.query(angular.extend(params, position_params));
      $scope.waitForPromise($scope.venues.$promise);
      Venue.count(params).$promise.then(function(result) {
        $scope.venuesCount = result.count;
        if ($scope.venuesCount == 0) $scope.noVenues = true;
        $scope.numPages = Math.ceil($scope.venuesCount/pageLimit);
      });
    }
    
    $scope.loadVenueForOperation = function(venue) {
      $scope.venueInOperation = angular.copy(venue);

      // venue types logic
      $scope.venueTypeStates = {};
      $scope.originalVenueTypes = [];
      $scope.currentVenueTypes = [];
      $scope.venueTypesToRemove = [];
      $scope.venueTypesToAdd = [];
      $scope.logoSrc = (venue.logo && venue.logo.filename) ? venue.logo.path + 'small_' + venue.logo.filename : null;
      if ($scope.venueInOperation.venue_types) {
        for (var i = 0; i < $scope.venueInOperation.venue_types.length; i++) {
          $scope.originalVenueTypes.push($scope.venueInOperation.venue_types[i].id);
          $scope.currentVenueTypes.push($scope.venueInOperation.venue_types[i].id);
        }
      }
      for (var i = 0; i < $scope.venueTypes.length; i++) {
        $scope.venueTypeStates[$scope.venueTypes[i].id] = $.inArray($scope.venueTypes[i].id, $scope.originalVenueTypes) > -1;
      }

      $scope.recalculateAvailableCategories();

      // keywords logic
      $scope.originalKeywords = [];
      $scope.currentKeywords = [];
      $scope.currentKeywordsMapping = {};
      $scope.keywordsToRemove = [];
      $scope.keywordsToAdd = [];

      if ($scope.venueInOperation.keywords) {
        for (var i = 0; i < $scope.venueInOperation.keywords.length; i++) {
          $scope.originalKeywords.push($scope.venueInOperation.keywords[i].id);
          $scope.currentKeywords.push($scope.venueInOperation.keywords[i].id);
          $scope.currentKeywordsMapping[$scope.venueInOperation.keywords[i].id] = $scope.venueInOperation.keywords[i];
        }
      }
      // photos logic
      $scope.photosToAdd = [];
      $scope.photosToRemove = [];
      $scope.rebuildPhotos();
    }

    $scope.recalculateAvailableCategories = function() {
      var newAvailableCategories = [];
      var newAvailableCategoryIds = [];
      for (var i = 0; i < $scope.currentVenueTypes.length; i++) {
        var venue_type = $scope.venueTypesMapping[$scope.currentVenueTypes[i]];
        for (var j = 0; j < venue_type.categories.length; j++) {
          var cat = venue_type.categories[j];
          if ($.inArray(cat.id, newAvailableCategoryIds) === -1) {
            newAvailableCategories.push(cat);
            newAvailableCategoryIds.push(cat.id);
          }
        }
      }
      $scope.availableCategories = newAvailableCategories;
      $scope.availableCategoryIds = newAvailableCategoryIds;
    }

    $scope.handleAddKeyword = function(keyword) {
      if ($.inArray(keyword.id, $scope.currentKeywords) == -1) {
        $scope.keywordToggled(keyword);
      }
    }

    $scope.keywordToggled = function(keyword) {
      if ($scope.venueInOperation) {
        
        // update current keywords
        var keywordIndex = $.inArray(keyword.id, $scope.currentKeywords);
        var keywordState = keywordIndex > -1;
        // console.log('State for keyword (' + keyword.id +'): ', keywordState)
        if (keywordState) {
          $scope.currentKeywords.splice(keywordIndex, 1);
          delete $scope.currentKeywordsMapping[keyword.id];
        }
        else {
          $scope.currentKeywords.push(keyword.id);
          $scope.currentKeywordsMapping[keyword.id] = keyword;
        }

        // update add/remove arrays
        $scope.keywordsToAdd = $($scope.currentKeywords).not($scope.originalKeywords).toArray();
        $scope.keywordsToRemove = $.grep($scope.originalKeywords, function(n, i) {
          return $.inArray(n, $scope.currentKeywords) == -1;
        });

        // console.log("Original Keywords: ", $scope.originalKeywords);
        // console.log("Current Keywords: ", $scope.currentKeywords);
        // console.log("Keywords to add...", $scope.keywordsToAdd);
        // console.log("Keywords to remove: ", $scope.keywordsToRemove);
      }
    }

    $scope.venueTypeToggled = function(venue_type) {
      // console.debug("Toggling Venue Type: ", venue_type);
      if ($scope.venueInOperation) {

        // update current venue types
        // console.log('State for ' + venue_type.name, $scope.venueTypeStates[venue_type.id])
        if ($scope.venueTypeStates[venue_type.id] && $scope.venueTypeStates[venue_type.id] === true) {
          $scope.currentVenueTypes.splice($.inArray(venue_type.id, $scope.currentVenueTypes), 1);
          $scope.recalculateAvailableCategories();
          $scope.removeInvalidKeywords();
        }
        else {
          $scope.currentVenueTypes.push(venue_type.id);
          $scope.recalculateAvailableCategories();
        }

        // update add/remove arrays
        $scope.venueTypesToAdd = $($scope.currentVenueTypes).not($scope.originalVenueTypes).toArray();
        $scope.venueTypesToRemove = $.grep($scope.originalVenueTypes, function(n, i) {
          return $.inArray(n, $scope.currentVenueTypes) == -1;
        });

        // console.log("Original Venue Types: ", $scope.originalVenueTypes);
        // console.log("Current Venue Types: ", $scope.currentVenueTypes);
        // console.log("Venue Types to add...", $scope.venueTypesToAdd);
        // console.log("Venue Types to remove: ", $scope.venueTypesToRemove);
      }
    }
    
    $scope.removeInvalidKeywords = function() {
      var currentKeywords = angular.copy($scope.currentKeywords);
      for (var i = 0; i < currentKeywords.length; i++) {
        var kw = $scope.keywordsMapping[currentKeywords[i]];
        var exists = $.inArray(kw.category_id, $scope.availableCategoryIds) > -1;
        if (!exists) {
          $scope.keywordToggled(kw);
        }
      } 
    }

    $scope.refreshCategoryKeywordVenueTypeData = function() {
      $scope.loaded = false;
      $scope.categories = Category.query();
      $scope.keywords = Keyword.query({limit: 200});
      $scope.venueTypes = VenueType.query();

      $scope.keywordsCategoriesVenueTypesDataLoaded = $q.all([
        $scope.categories.$promise,
        $scope.keywords.$promise,
        $scope.venueTypes.$promise
      ]);

      // do a bunch of stuff we'll need to handle complex relationship and other logic in the view
      $scope.keywordsCategoriesVenueTypesDataLoaded.then(function() {
        $scope.venueTypesMapping = {};
        $scope.categoriesMapping = {};
        $scope.keywordsMapping = {};

        // make  venue types array multi-dimensional for display rows
        var venue_types_data = $scope.venueTypes;
        var venue_types_results = [];
        var row_count = Math.ceil(venue_types_data.length/3);
        for (var row_index = 0; row_index < row_count; row_index++) {
          venue_types_results[row_index] = [];
          for (var j = 0; j < 3; j++) {
            if (venue_types_data[row_index*3+j]) {
              venue_types_results[row_index][j] = venue_types_data[row_index*3+j];
              $scope.venueTypesMapping[venue_types_data[row_index*3+j].id] = venue_types_data[row_index*3+j];
            }
          }
        }
        $scope.venueTypeRows = venue_types_results;
        for (var i = 0; i < $scope.categories.length; i++) {
          $scope.categoriesMapping[$scope.categories[i].id] = {category: $scope.categories[i], keywords: []};
        }
        for (var i = 0; i < $scope.keywords.length; i++) {
          if ($scope.categoriesMapping[$scope.keywords[i].category_id]) $scope.categoriesMapping[$scope.keywords[i].category_id].keywords.push($scope.keywords[i]);
          $scope.keywordsMapping[$scope.keywords[i].id] = $scope.keywords[i];
        }
        $scope.loaded = true;
      })

    }

    $scope.fetchVenues(1);
    $scope.neighbourhoods = Neighbourhood.query();
    $scope.refreshCategoryKeywordVenueTypeData();
  }])
  .controller('KeywordsController', ['$scope', 'Keyword', 'Category', 'VenueType', '$q', '$modal', function ($scope, Keyword, Category, VenueType, $q, $modal) {
    $scope.keywordInOperation = null;
    $scope.venueTypesToAdd = [];
    $scope.venueTypeStates = {};
    $scope.availableCategories = [];
    $scope.data = null;

    $scope.loadKeywordForOperation = function(keyword) {
      $scope.keywordInOperation = angular.copy(keyword);
      $scope.venueTypesToAdd = [];
      $scope.venueTypeStates = {};
      $scope.availableCategories = [];
      $scope.recalculateAvailableCategories();
    }

    $scope.addNewKeyword = function() {
      var newKeyword = new Keyword();
      $scope.loadKeywordForOperation(newKeyword);
    }

    $scope.save = function() {
      if ($scope.keywordInOperation) {
        if ($scope.venueTypesToAdd.length) {
          $scope.keywordInOperation.add_venue_types = $scope.venueTypesToAdd;
        }

        var savePromise;
        if (!$scope.keywordInOperation.id) {
          savePromise = $scope.keywordInOperation.$save();
        }
        else {
          savePromise = $scope.keywordInOperation.$update();
        }
        // $scope.waitForPromise(savePromise);
        var refresh = function() {
          $scope.refreshData();
          $scope.keywordInOperation = null;
          $scope.venueTypesToAdd = [];
          $scope.venueTypeStates = {};
          $scope.availableCategories = [];
        }
        savePromise.then(refresh, refresh);
      }
    }
    $scope.cancel = function() {
      $scope.keywordInOperation = null;
      $scope.venueTypesToAdd = [];
    }

    $scope.destroyKeyword = function(keyword) {
      var deleteModal = $modal.open({
        templateUrl: asset_path('partials/confirm_delete_modal.html'),
        controller: "ConfirmDeleteModalController",
        resolve: {
          message: function () {
            return "Are you sure you want to delete the Keyword by ID: '" + keyword.id + "' ?";
          }
        },
        backdrop: 'static'
      })
      deleteModal.result.then(function (result) {
        if (result === true) {
          var deletePromise = keyword.$destroy();
          var refresh = function() {
            $scope.refreshData();
            $scope.categoryInOperation = null;  
            $scope.venueTypesToAdd = [];
            $scope.venueTypeStates = {};
            $scope.availableCategories = [];
          }
          deletePromise.then(refresh, refresh);
        }
      });
    }

    $scope.venueTypeToggled = function(venue_type) {
      // console.debug("Toggling Venue Type: ", venue_type);
      if ($scope.keywordInOperation) {

        // update current venue types
        // console.log('State for ' + venue_type.id, $scope.venueTypeStates[venue_type.id])
        var venue_type_index = $.inArray(venue_type.id, $scope.venueTypesToAdd);
        var exists = venue_type_index > -1;
        if (exists) {
          $scope.venueTypesToAdd.splice(venue_type_index, 1);
        }
        else {
          $scope.venueTypesToAdd.push(venue_type.id);
        }
        // console.log("$scope.venueTypesToAdd: ", $scope.venueTypesToAdd)
        $scope.recalculateAvailableCategories();
      }
    }

    $scope.recalculateAvailableCategories = function() {
      var availableCategories = [];
      var availableCategoryIds = [];
      $scope.venueTypeStates = {};
      for (var i = 0; i < $scope.venueTypesToAdd.length; i++) {
        var venue_type = $scope.data.venue_types[$scope.venueTypesToAdd[i]];
        $scope.venueTypeStates[venue_type.id] = true;
        for (var j = 0; j < venue_type.categories.length; j++) {
          var category = venue_type.categories[j];
          if ($.inArray(category.id, availableCategoryIds) === -1) {
            availableCategories.push(category);
            availableCategoryIds.push(category.id)
          }
        }
      }
      $scope.availableCategories = availableCategories;
    }

    $scope.refreshData = function() {
      $scope.categories = Category.query({limit:200});
      $scope.keywords = Keyword.query({limit:200});
      $scope.venueTypes = VenueType.query({limit:200});
      var processData = function() {
        var categories = $scope.categories;
        var keywords = $scope.keywords;
        var venue_types = $scope.venueTypes;

        var data = {
          keywords: {},
          categories: {},
          venue_types: {}
        };

        for (var i = 0; i < categories.length; i++) {
          data.categories[categories[i].id] = categories[i];
        }

        for (var i = 0; i < keywords.length; i++) {
          data.keywords[keywords[i].id] = keywords[i];
        }

        // make  venue types array multi-dimensional for display rows
        var venue_types_data = $scope.venueTypes;
        var venue_types_results = [];
        var cols = 2;
        var row_count = Math.ceil(venue_types_data.length/cols);
        for (var row_index = 0; row_index < row_count; row_index++) {
          venue_types_results[row_index] = [];
          for (var j = 0; j < cols; j++) {
            if (venue_types_data[row_index*cols+j]) {
              venue_types_results[row_index][j] = venue_types_data[row_index*cols+j];
              data.venue_types[venue_types_data[row_index*cols+j].id] = venue_types_data[row_index*cols+j];
            }
          }
        }
        $scope.venueTypeRows = venue_types_results;
        $scope.data = data;
      }

      var dataPromise = $q.all([$scope.categories.$promise, $scope.keywords.$promise, $scope.venueTypes.$promise]);
      dataPromise.then(processData);
    }
    $scope.refreshData();
    
  }])
  .controller('ConfirmDeleteModalController', ['$scope', '$q', '$modalInstance', 'message', function ($scope, $q, $modalInstance, message) {
    $scope.message = message;
    $scope.cancel = function () {
      $modalInstance.close(false);
    }

    $scope.destroy = function () {
      $modalInstance.close(true);
    }
  }])
  .controller('CategoriesController', ['$scope', 'Category', 'VenueType', '$q', '$modal', function ($scope, Category, VenueType, $q, $modal) {
    $scope.categoryInOperation = null;
    $scope.venueTypesToAdd = [];
    $scope.venueTypeStates = {};
    $scope.availableCategories = [];
    $scope.data = null;

    $scope.destroyCategory = function(category) {
      var deleteModal = $modal.open({
        templateUrl: asset_path('partials/confirm_delete_modal.html'),
        controller: "ConfirmDeleteModalController",
        resolve: {
          message: function () {
            return "Are you sure you want to delete the Category by ID: '" + category.id + "' ?";
          }
        },
        backdrop: 'static'
      })
      deleteModal.result.then(function (result) {
        if (result === true) {
          var deletePromise = category.$destroy();
          var refresh = function() {
            $scope.refreshData();
            $scope.categoryInOperation = null;  
            $scope.venueTypesToAdd = [];
            $scope.venueTypeStates = {};
            $scope.availableCategories = [];
          }
          deletePromise.then(refresh, refresh);
        }
      });
    }

    $scope.addNewCategory = function() {
      var newCategory = new Category();
      $scope.loadCategoryForOperation(newCategory);
    }
    $scope.loadCategoryForOperation = function(category) {
      $scope.categoryInOperation = angular.copy(category);
      $scope.venueTypesToAdd = [];
    }

    $scope.venueTypeToggled = function(venue_type) {
      // console.debug("Toggling Venue Type: ", venue_type);
      if ($scope.categoryInOperation) {

        // update current venue types
        // console.log('State for ' + venue_type.id, $scope.venueTypeStates[venue_type.id])
        var venue_type_index = $.inArray(venue_type.id, $scope.venueTypesToAdd);
        var exists = venue_type_index > -1;
        if (exists) {
          $scope.venueTypesToAdd.splice(venue_type_index, 1);
          $scope.venueTypeStates[venue_type.id] = false;
        }
        else {
          $scope.venueTypesToAdd.push(venue_type.id);
          $scope.venueTypeStates[venue_type.id] = true;
        }
        // console.log("$scope.venueTypesToAdd: ", $scope.venueTypesToAdd)
      }
    }

    $scope.venueTypesOfCategory = function(category) {
      var array_of_venue_types = [];
      if (category && $scope.venueTypes) {
        for (var i = 0; i < $scope.venueTypes.length; i++) {
          var venue_type = $scope.venueTypes[i];
          for (var j = 0; j < venue_type.categories.length; j++) {
            if (category.id === venue_type.categories[j].id) {
              array_of_venue_types.push(venue_type);
              break;
            }
          }
        }
      }
      return array_of_venue_types;
    }

    $scope.save = function() {
      if ($scope.categoryInOperation) {
        if ($scope.venueTypesToAdd.length) {
          $scope.categoryInOperation.add_venue_types = $scope.venueTypesToAdd;
        }

        var savePromise;
        if (!$scope.categoryInOperation.id) {
          savePromise = $scope.categoryInOperation.$save();
        }
        else {
          savePromise = $scope.categoryInOperation.$update();
        }
        // $scope.waitForPromise(savePromise);
        var refresh = function() {
          $scope.refreshData();
          $scope.categoryInOperation = null;
          $scope.venueTypesToAdd = [];
          $scope.venueTypeStates = {};
          $scope.availableCategories = [];
        }
        savePromise.then(refresh, refresh);
      }
    }

    $scope.cancel = function() {
      $scope.categoryInOperation = null;
      $scope.venueTypesToAdd = [];
      $scope.venueTypeStates = {};
    }

    $scope.refreshData = function() {
      $scope.categories = Category.query({limit:200});
      $scope.venueTypes = VenueType.query({limit:200});
      var processData = function() {
        $scope.data = null;
        var categories = $scope.categories;
        var venue_types = $scope.venueTypes;

        var data = {
          categories: {},
          venue_types: {}
        };

        for (var i = 0; i < categories.length; i++) {
          data.categories[categories[i].id] = categories[i];
        }

        // make  venue types array multi-dimensional for display rows
        var venue_types_data = $scope.venueTypes;
        var venue_types_results = [];
        var cols = 2;
        var row_count = Math.ceil(venue_types_data.length/cols);
        for (var row_index = 0; row_index < row_count; row_index++) {
          venue_types_results[row_index] = [];
          for (var j = 0; j < cols; j++) {
            if (venue_types_data[row_index*cols+j]) {
              venue_types_results[row_index][j] = venue_types_data[row_index*cols+j];
              data.venue_types[venue_types_data[row_index*cols+j].id] = venue_types_data[row_index*cols+j];
            }
          }
        }
        $scope.venueTypeRows = venue_types_results;
        $scope.data = data;
      }

      var dataPromise = $q.all([$scope.categories.$promise, $scope.venueTypes.$promise]);
      dataPromise.then(processData);
    }
    $scope.refreshData();
  }])
  .controller('NeighbourhoodsController', ['$scope', 'Neighbourhood', '$modal', function ($scope, Neighbourhood, $modal) {
    $scope.neighbourhoodInOperation = null;
    $scope.data = null;

    $scope.destroyNeighbourhood = function(neighbourhood) {
      var deleteModal = $modal.open({
        templateUrl: asset_path('partials/confirm_delete_modal.html'),
        controller: "ConfirmDeleteModalController",
        resolve: {
          message: function () {
            return "Are you sure you want to delete the Neighbourhood by ID: '" + neighbourhood.id + "' ?";
          }
        },
        backdrop: 'static'
      })
      deleteModal.result.then(function (result) {
        if (result === true) {
          var deletePromise = neighbourhood.$destroy();
          var refresh = function() {
            $scope.refreshData();
            $scope.neighbourhoodInOperation = null;
          }
          deletePromise.then(refresh, refresh);
        }
      });
    }

    $scope.addNewNeighbourhood = function() {
      var newNeighbourhood = new Neighbourhood();
      $scope.loadNeighbourhoodForOperation(newNeighbourhood);
    }

    $scope.loadNeighbourhoodForOperation = function(neighbourhood) {
      $scope.neighbourhoodInOperation = angular.copy(neighbourhood);
    }

    $scope.save = function() {
      if ($scope.neighbourhoodInOperation) {
        var savePromise;
        if (!$scope.neighbourhoodInOperation.id) {
          savePromise = $scope.neighbourhoodInOperation.$save();
        }
        else {
          savePromise = $scope.neighbourhoodInOperation.$update();
        }
        var refresh = function() {
          $scope.neighbourhoodInOperation = null;
          $scope.refreshData();
        }
        savePromise.then(refresh, refresh);
      }
    }

    $scope.cancel = function() {
      $scope.neighbourhoodInOperation = null;
    }

    $scope.refreshData = function() {
      $scope.neighbourhoods = Neighbourhood.query({limit:200});

      $scope.neighbourhoods.$promise.then(function() {
        $scope.data = null;

        var data = {
          neighbourhoods: {}
        };

        for (var i = 0; i < $scope.neighbourhoods.length; i++) {
          data.neighbourhoods[$scope.neighbourhoods[i].id] = $scope.neighbourhoods[i];
        }

        $scope.data = data;
      });
    }
    $scope.refreshData();
  }])
  .controller('VenueTypesController', ['$scope', 'VenueType', '$modal', function ($scope, VenueType, $modal) {
    $scope.venueTypeInOperation = null;
    $scope.data = null;

    $scope.destroyVenueType = function(venue_type) {
      var deleteModal = $modal.open({
        templateUrl: asset_path('partials/confirm_delete_modal.html'),
        controller: "ConfirmDeleteModalController",
        resolve: {
          message: function () {
            return "Are you sure you want to delete the Venue Type by ID: '" + venue_type.id + "' ?";
          }
        },
        backdrop: 'static'
      })
      deleteModal.result.then(function (result) {
        if (result === true) {
          var deletePromise = venue_type.$destroy();
          var refresh = function() {
            $scope.refreshData();
            $scope.venueTypeInOperation = null;
          }
          deletePromise.then(refresh, refresh);
        }
      });
    }

    $scope.addNewVenueType = function() {
      var newVenueType = new VenueType();
      $scope.loadVenueTypeForOperation(newVenueType);
    }

    $scope.loadVenueTypeForOperation = function(venue_type) {
      $scope.venueTypeInOperation = angular.copy(venue_type);
    }

    $scope.save = function() {
      if ($scope.venueTypeInOperation) {
        var savePromise;
        if (!$scope.venueTypeInOperation.id) {
          savePromise = $scope.venueTypeInOperation.$save();
        }
        else {
          savePromise = $scope.venueTypeInOperation.$update();
        }
        var refresh = function() {
          $scope.venueTypeInOperation = null;
          $scope.refreshData();
        }
        savePromise.then(refresh, refresh);
      }
    }

    $scope.cancel = function() {
      $scope.venueTypeInOperation = null;
    }

    $scope.refreshData = function() {
      $scope.venueTypes = VenueType.query({limit:200});

      $scope.venueTypes.$promise.then(function() {
        $scope.data = null;

        var data = {
          venue_types: {}
        };

        for (var i = 0; i < $scope.venueTypes.length; i++) {
          data.venue_types[$scope.venueTypes[i].id] = $scope.venueTypes[i];
        }

        $scope.data = data;
      });
    }
    $scope.refreshData();
  }])
  ;
