# CH CH CH CHANGES #

## Friday the 25th of October 2013, v1.0.0 ##

* Updated backbone.js to v1.1.0.
* Moved the fallback scripts into versioned directories a la other rack-xxx libs.
* Decided that the API to this library is stable enough to move to v1.0.0 (see sermver).

----


## Saturday the 12th of October 2013, v0.1.1 ##

* Had a rogue newline since the fallback script was split. Fixed.

----


## Friday the 11th of October 2013, v0.1.0 ##

* Added option `debug` for getting the unminified version of the script, to help with debugging.

----


## Thursday the 10th of October 2013 ##

### v0.0.5 ###

* Can pass `false` to the `cdn` method to just get the fallback with no CDN, useful for working locally.
* Fixed problem with the :http_path option for the fallback route.

----


## Thursday the 19th of September 2013 ##

### v0.0.4 ###

* The source map URL given in the main script is unversioned, so the fallback map wasn't being found. Fixed.

----


### v0.0.3 ###

* The vendored scripts weren't in the gem because of a cheeky line in the .gitignore file. Maybe DHH got hold of it ;) Fixed now.

----


## Monday the 9th of September 2013 ##

### v0.0.2 ###

* Had wrong URL to Backbone project. Fixed.

----

### v0.0.1 ###

* First release.

----
