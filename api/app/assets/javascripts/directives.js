'use strict';

angular.module('VenueAdminApp')
.directive('processingbutton', function() {
  return {
    restrict: 'EA',
    scope: {
      onClick: '&',
      processing: '=processing',
      buttonStyle: '@buttonStyle',
      buttonText: '=buttonText'
    },
    transclude: true,
    templateUrl: asset_path("partials/processing_button.html"),
    controller: function ($scope, $timeout, $q) {
      $scope.buttonClicked = function () {
        $scope.onClick();
      }
    }
  };
})
.directive('chkboxButton', function() {
  return {
    restrict: 'EA',
    scope: {
      onChange: '&',
      checkboxModel: '=checkboxModel',
      buttonText: '@buttonText'
    },
    transclude: true,
    templateUrl: asset_path("partials/chkbox_button.html"),
    link: function(scope, element, attrs) {
      element.bind("click", function(e) {
        scope.$apply(function() {
          if (e.target.type !== 'checkbox') {
            scope.checkboxModel = !scope.checkboxModel;
          }
          else {
            e.stopPropagation();
          }
          scope.onChange();
        });
      });
   }
  };
})
.directive('fileDropzone', function() {
  return {
    restrict: 'A',
    scope: {
      file: '=',
      fileName: '=',
      fileType: '='
    },
    link: function(scope, element, attrs) {
      var checkSize, getDataTransfer, isTypeValid, processDragOverOrEnter, validMimeTypes;
      getDataTransfer = function(event) {
        var dataTransfer;
        return dataTransfer = event.dataTransfer || event.originalEvent.dataTransfer;
      };
      processDragOverOrEnter = function(event) {
        if (event) {
          if (event.preventDefault) {
            event.preventDefault();
          }
          if (event.stopPropagation) {
            return false;
          }
        }
        getDataTransfer(event).effectAllowed = 'copy';
        return false;
      };
      validMimeTypes = attrs.fileDropzone;
      checkSize = function(size) {
        var _ref;
        if (((_ref = attrs.maxFileSize) === (void 0) || _ref === '') || (size / 1024) / 1024 < attrs.maxFileSize) {
          return true;
        } else {
          alert("File must be smaller than " + attrs.maxFileSize + " MB");
          return false;
        }
      };
      isTypeValid = function(type) {
        if ((validMimeTypes === (void 0) || validMimeTypes === '') || validMimeTypes.indexOf(type) > -1) {
          return true;
        } else {
          alert("Invalid file type.  File must be one of following types " + validMimeTypes);
          return false;
        }
      };
      element.bind('dragover', processDragOverOrEnter);
      element.bind('dragenter', processDragOverOrEnter);
      return element.bind('drop', function(event) {
        var file, name, reader, size, type;
        if (event != null) {
          event.preventDefault();
        }
        reader = new FileReader();
        reader.onload = function(evt) {
          if (checkSize(size) && isTypeValid(type)) {
            scope.$apply(function() {
              scope.file = evt.target.result;
              if (angular.isString(name)) {
                scope.fileName = name;
                scope.fileType = type;
                return
              }
            });
            return scope.$emit('file-dropzone-drop-event', {
              file: scope.file,
              type: type,
              name: name,
              size: size
            });
          }
        };
        file = getDataTransfer(event).files[0];
        name = file.name;
        type = file.type;
        size = file.size;
        reader.readAsDataURL(file);
        return false;
      });
    }
  };
});
