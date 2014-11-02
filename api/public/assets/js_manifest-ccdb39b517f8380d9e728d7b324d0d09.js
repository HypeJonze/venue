// https://github.com/johnnypez/assets_js - modified by Steven Sherrie (steve@wasteofpaper.com)

// Copyright (c) 2012 jbutler

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



'use strict';

!function(window, document, undefined){
  
  var asset_host = null;
  var manifest = {"account.html":"account-c19ce0de65b0d8e20cf5a6f3163e12a9.html","categories.html":"categories-e3e1f29261b428ede053c0d7f3c127a3.html","keywords.html":"keywords-cdcc6efc677564c09d1e767e4a60d713.html","login.html":"login-58c30c5309688fc27a2741af47f0345e.html","neighbourhoods.html":"neighbourhoods-a94bf27db7599bf7cd8652d2703c9238.html","partials/admin_menu.html":"partials/admin_menu-c2af629ced65cc8cd34b9ffaa6fd757b.html","partials/chkbox_button.html":"partials/chkbox_button-d8e63f26769e4d2e1e2da67b60bf7bed.html","partials/confirm_delete_modal.html":"partials/confirm_delete_modal-b2ca7b37629ac58d7a62740a11234472.html","partials/loading_modal.html":"partials/loading_modal-be9eb6e34e99b324570c6452f46d7238.html","partials/processing_button.html":"partials/processing_button-7b7118f5de82623c561294033e85217c.html","venue_types.html":"venue_types-18e31d4515c720e9ffd754c440954095.html","venues.html":"venues-29cdcb83f03d5cae8dff23715e6a3518.html","logo.png":"logo-77184f01e59844caa1e7fb1cdf15e3af.png","access.js":"access-21fbc8cb175f5c6f4c833d6a1cc86669.js","app.js":"app-ecf4917d5cea00828298b748bc2aa55e.js","application.js":"application-06179f0cd8bb86c18d01bb66982d5487.js","controllers.js":"controllers-f3c299ebfb9f7a2a6ef2d1593b06d4f0.js","directives.js":"directives-eafd03efc597a28a0603b122e75ccd69.js","factory.js":"factory-63082fedb0369e8ee723069145d54d8d.js","js_manifest.js":"js_manifest-154a63413359974936adf0ba5b405ccb.js","states.js":"states-4ebd7b66caf2704bd468b3fc0df08671.js","application.css":"application-2b1c18bc18d9eb39d58365d52d86edeb.css","angular-animate.js":"angular-animate-f612e40080ba61841fa9828e40bf7407.js","angular-cookies.js":"angular-cookies-39cb70a7e8fa05922026507a14fc6cae.js","angular-resource.js":"angular-resource-7195f4c27b62a9ecf896a73b28a7226a.js","angular-route.js":"angular-route-03ad5305927613fa7bbceb04f38d1992.js","angular-sanitize.js":"angular-sanitize-a6ef2fbe9501c68df6886b350e282b40.js","angular-ui-router.js":"angular-ui-router-bae658143b80a7f7a323da745fbe3570.js","angular.js":"angular-828aeb57dabc3c71458812a1e33560b9.js","ui-bootstrap-tpls.min.js":"ui-bootstrap-tpls.min-732d7fdd03630883717d4d829d36c1b4.js","bootstrap.css":"bootstrap-d911816ddf2a4d3118bb55ac9eaf9d00.css","bootstrap/_alerts.css":"bootstrap/_alerts-b95506d528faa461f13a9ab7d48fa097.css","bootstrap/_badges.css":"bootstrap/_badges-3559d2de92ece243937973d44cca240f.css","bootstrap/_breadcrumbs.css":"bootstrap/_breadcrumbs-07a54daa59eaf626cb10ad545f5bfd99.css","bootstrap/_button-groups.css":"bootstrap/_button-groups-29db191e62f5a67085846fac05db95c9.css","bootstrap/_buttons.css":"bootstrap/_buttons-440e860f528abced8b6d3464d7042bff.css","bootstrap/_carousel.css":"bootstrap/_carousel-28c979e7042a9f22a3ea93cf46ee0482.css","bootstrap/_close.css":"bootstrap/_close-c4db56d4ac2a708c28c0715800429c94.css","bootstrap/_code.css":"bootstrap/_code-8e94a2af05a9639c89c299c38ab38109.css","bootstrap/_component-animations.css":"bootstrap/_component-animations-4feba1f068614d40e74e7421a999cee4.css","bootstrap/_dropdowns.css":"bootstrap/_dropdowns-a822d8fd4e0087feb669368f42589327.css","bootstrap/_forms.css":"bootstrap/_forms-83976a8bdf3355d2ebc7b7dbfc2edd00.css","bootstrap/_glyphicons.css":"bootstrap/_glyphicons-d9ae9d2cf9fc1bc4b2e6245dc82d4f52.css","bootstrap/_grid.css":"bootstrap/_grid-354ec5a2c4b9126bc846ee245d26dfb3.css","bootstrap/_input-groups.css":"bootstrap/_input-groups-b1cd24470a5c235d12c203be379412cf.css","bootstrap/_jumbotron.css":"bootstrap/_jumbotron-74072812b66f775125d762ce2c482f6e.css","bootstrap/_labels.css":"bootstrap/_labels-c016930f27e53d94d0c0de60ce8584d5.css","bootstrap/_list-group.css":"bootstrap/_list-group-3caaca9f1cbe38e13940ec1911c3b882.css","bootstrap/_media.css":"bootstrap/_media-a200a37248e9054cd93ccd08896ac10c.css","bootstrap/_mixins.css":"bootstrap/_mixins-29cf91a7ed586506d35e08cc495dafac.css","bootstrap/_modals.css":"bootstrap/_modals-d8a968905562df14280b8cb9889617e7.css","bootstrap/_navbar.css":"bootstrap/_navbar-7830f8a1af7e6aa9cd047d945779c273.css","bootstrap/_navs.css":"bootstrap/_navs-29975976a1eb89e9bbe608246d872fef.css","bootstrap/_normalize.css":"bootstrap/_normalize-73a1758d638ecca89ffd3b8fbcd962b9.css","bootstrap/_pager.css":"bootstrap/_pager-2d512d7ae1596275a231510ec8d20e0b.css","bootstrap/_pagination.css":"bootstrap/_pagination-7709115e710b71ab6ddfea969ffbc1ed.css","bootstrap/_panels.css":"bootstrap/_panels-1fd7fbb0b78847320a7a39f26857c9b3.css","bootstrap/_popovers.css":"bootstrap/_popovers-4fcc487c4c5cb08d9d30d085e421b799.css","bootstrap/_print.css":"bootstrap/_print-d838ae224c1296645c577e4000adbda2.css","bootstrap/_progress-bars.css":"bootstrap/_progress-bars-7747b0807e1a5c2486164be817fb1826.css","bootstrap/_responsive-utilities.css":"bootstrap/_responsive-utilities-0b5fecb4015c37b3d66f4b9e2134809c.css","bootstrap/_scaffolding.css":"bootstrap/_scaffolding-92ece908ac878eb453e87da88aabed49.css","bootstrap/_tables.css":"bootstrap/_tables-4cf7b992da57e5df46b409f4c44cce84.css","bootstrap/_theme.css":"bootstrap/_theme-718ca7e903be3a46562a75e411e7bbf7.css","bootstrap/_thumbnails.css":"bootstrap/_thumbnails-f280821bd70967e4ed19f836f9c6afdc.css","bootstrap/_tooltip.css":"bootstrap/_tooltip-4c4ff8d4dce5966b9ad6129b82540818.css","bootstrap/_type.css":"bootstrap/_type-a465c49b38f281e784fe580202083b0a.css","bootstrap/_utilities.css":"bootstrap/_utilities-11435e972c28d3b9c1d20dc3842984c1.css","bootstrap/_variables.css":"bootstrap/_variables-456586cdcc3385b1a5e89b90b6978697.css","bootstrap/_wells.css":"bootstrap/_wells-ee36eaa0840782cd8a3e3baba0122a50.css","bootstrap/bootstrap.css":"bootstrap/bootstrap-79477c7c2811992cac960a6b4da90c97.css","FontAwesome.otf":"FontAwesome-75900c2f88b61149125a164c388e4dbe.otf","fontawesome-webfont.eot":"fontawesome-webfont-f56504f061caa6896d66c73b119e4904.eot","fontawesome-webfont.svg":"fontawesome-webfont-0f6bb74760f60020208520aaffe7178a.svg","fontawesome-webfont.ttf":"fontawesome-webfont-90e987e197e36d15cfcaba1cf968abe2.ttf","fontawesome-webfont.woff":"fontawesome-webfont-c666813ae8d577f1e04b4faf99e990da.woff","font-awesome.css":"font-awesome-bd974af4ab693361495d2675a80c3cbb.css","dropzone/spritemap.png":"dropzone/spritemap-74afc84ef8f43fcf8a5616367459fda0.png","dropzone/spritemap@2x.png":"dropzone/spritemap@2x-4816ebd72fde3f3790fc1263c0aa0cb0.png","dropzone.js":"dropzone-ab8a8419460d90008cd850c7e45f0212.js","dropzone/basic.css":"dropzone/basic-f88bf7c973f3378f8272c05021ff10d9.css","dropzone/dropzone.css":"dropzone/dropzone-0f0b55cc8cc4ce02de6688bcdf1acc07.css"};
  
  function asset_path(path){
    if(manifest.hasOwnProperty(path)){
      return '/assets/' + manifest[path];
    }
    else{
      throw Error('missing asset: ' + path);
    }
  };

  function asset_url(path){
    if (asset_host){
      return  window.location.protocol + asset_host + asset_path(path);
    } else {
      return window.location.protocol + '//' + window.location.host + asset_path(path);
    }
  };

  window.asset_path = asset_path;
  window.asset_url = asset_url;
  window.manifest = manifest;
  
}(window, document);
