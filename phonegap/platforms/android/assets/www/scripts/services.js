angular.module('VenueMobileApp')
.service('mapURLBuilder', function() {
  return function() {

    var platform;
    var isWebIntentLoaded = false;

    if (window.device) {
      platform = window.device.platform;
    } else {
      platform = 'Desktop';
    }

    if (window.plugins && window.plugins.webintent) {
      isWebIntentLoaded = true;
    }

    this.mapURL = function(venue) {
      if (isWebIntentLoaded) {
        return mobileURLForVenue(venue);
      } else {
        return window.open(venue.googlemap_url);
      }
    };

    var mobileURLForVenue = function(venue) {
      if (platform == 'Android') {
        return androidURL(venue);
      } else {
        return iosURL(venue);
      }
    };

    var androidURL = function(venue) {
      window.plugins.webintent.startActivity({
        action: window.plugins.webintent.ACTION_VIEW,
        url: 'geo:' + venue.latitude + ',' + venue.longitude + '?q=' + venue.full_address
      },
      function() {},
      function() {
        alert('Failed to open URL via Android Intent');
      });
    };

    var iosURL = function(venue) {
      window.open('maps://?ll=' + venue.latitude + ',' + venue.longitude + '&q=' + venue.full_address);
    };
  }
});