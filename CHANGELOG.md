# 2.0.0

Backwards-incompatible changes:

* Artefact has to be explicitly passed to slimmer.
* RelatedItemsInserter uses passed artefact instead of calling out to panopticon.
* Slimmer now strips all X-Slimmer-* HTTP headers from the final response.

Other changes

* new LogoClassInserter module - adds classes to the `#wrapper` element to control the appearence of the directgov and businesslink logos
* Rounded Corners!!! (it is 2.0 after all)

# 0.9.0

* Moved templates into slimmer rather than using separate static project
* Added railtie so that slimmer can be dropped into a rails app without configuration
* Began to write *gasp* tests!
