# Unreleased

* Raise more specific error when wrapper not found

# 18.4.0

* Drop support for Ruby 3.0. Ruby 3.2 is now required.

# 18.3.0

* Enforce requirement for Rack 3

# 18.2.0

* Drop support for Ruby 2.7.
* Update reference to deprecated Rack::Utils::HeaderHash

# 18.1.0

* Decorate inline script elements with nonce attribute for appropriately configured Rails requests

# 18.0.0

* BREAKING: Drop support for determining Rails < 6 application names
* BREAKING: Remove `bin/render_slimmer_error` as a feature - it's expected that this is unused.
* Require Ruby >= 2.7.0
* Resolve deprecation warning for Plek.current

# 17.0.0

* BREAKING: Set default template to `gem_layout` and remove references to the deprecated `core_layout`.

# 16.0.1
* Resolve Nokogiri deprecation warning (#277)

# 16.0.0
* BREAKING: Remove NavigationMover processor (#275)

# 15.6.1
* Use safe navigation operator in feedback url swapper (#273)

# 15.6.0

* Add feedback url swapper (#271)

# 15.5.1
* Update gem_layout template support (#267)

# 15.5.0
* Add support for gem layout in static (#265)

# 15.4.1

* Add support for layout header component in static (#263)

# 15.4.0

* Hoist `<async>` and `<defer>` JS Script tags to `<head>`. (#261)

# 15.3.0

* Introduce separate, internal exception class for intermittent
template retrieval errors.

# 15.2.0

* Add X-Slimmer-Show-Accounts header to choose between accounts
  header components. (#255)
* Update to Ruby 2.7.2. (#254)

# 15.1.1

* Amend toggle button selector (#251)

# 15.1.0

* Add `<base>` tag into the `<head>`.

# 15.0.0

* BREAKING: Test templates no longer embed links to production JavaScript files,
  apps should provide their own dependencies.

# 14.0.0

* Remove handling of non-200 responses (#245)

# 13.4.0

* Revert X-Slimmer-Ignore-Error header (#246)

# 13.3.0

* Add X-Slimmer-Ignore-Error header flag to prevent overriding non-200 status responses

# 13.2.2

* Fix bug where parent_name was called without app

# 13.2.1

* Fix deprecation warning: `Module#parent_name` has been renamed to
  `module_parent_name`. `parent_name` is deprecated and will be removed in
  Rails 6.1. (#237)
* Migrate from govuk-lint to rubocop-govuk (#237)
* Remove lint rake task (#237)
* Fix linting issues (#237)
* Fix deprecation warning: Mocha deprecation warning at
  /my/local/path/to/test/test_helper.rb:6:in 'require': Require
  'mocha/test_unit', 'mocha/minitest' or 'mocha/api' instead of 'mocha/setup'.
  (#237)

# 13.2.0

* Upgrade Ruby version to 2.6.5. (#234)
* Fix linting issues. (#234)

# 13.1.0

* Add `js-enabled` to body tag of test templates. (#226)

# 13.0.0

* Drop cache TTL to 60 seconds.
* BREAKING: Remove the component system, components are now consumed via the [govuk_publishing_components gem](https://github.com/alphagov/govuk_publishing_components)

# 12.1.0

* Make sure that the metatags defined in the application are inserted at the
  top of the page. This means that third parties will see the custom metatags
  like `og:image` first, and template tags like the default sharing image second (#218)

# 12.0.0

* Remove the "report a problem" feature. This is now being covered by the
  feedback component (#213)

# 11.1.1

* Make the 'Inside Header Inserter' more resillient so that it doesn't throw
 exceptions in a test context (#212)

# 11.1.0

* Allow components in static to be loaded locally rather than over the network (#208)
* Replace deprecated `after_filter` in slimmer_template (#209)

# 11.0.2

* Add missing class tags to test templates for including Slimmer in tests

# 11.0.1

* Stop catching errors from Slimmer processors (#203)
* Removes all references to Airbrake

# 11.0.0

* Drops support for nokogiri versions < 1.7.0

# 10.1.5

* bugfix on airbrake to work on airbrake v4 or v5

# 10.1.4

* Adjust airbrake to work on airbrake v4 or v5

# 10.1.3

* Fix memory leak in components

# 10.1.2

* Bugfix for request URI's encoded as ASCII

# 10.1.1

* Bugfix for caching behaviour

# 10.1.0

* Use `Rails.cache` as the cache for templates, locales and components. You can
  remove `config.slimmer.use_cache` for your application, as you can no longer
  opt-out of caching.
* Add a `User-Agent` header to all outgoing API requests

# 10.0.0

* Removes the need_id meta tag, which is no longer used.
* Removes the functionality for breadcrumbs, related links and artefact-powered
  metatags.
* Drop support for old Rails & Ruby versions. This gem now supports Rails 4.2 and 5.X
  on Ruby 2.1 and 2.2.
* Renames `Slimmer::SharedTemplates` to `Slimmer::GovukComponents`

# 9.6.0

* Adds an 'inside header inserter' processor which allows an application to
  inject a block of HTML after the logo by including a .inside-header element
  in their application’s output.
  (PR #167 https://github.com/alphagov/slimmer/pull/167)

* Remove `MetaViewportRemover` processor as it is no longer used.
  (PR #166 https://github.com/alphagov/slimmer/pull/166)

# 9.5.0

* Adds a Cucumber helper that makes it easy for host applications to
  configure Slimmer correctly under test.

  (PR #162 https://github.com/alphagov/slimmer/pull/162)

# 9.4.0

* Adds an RSpec helper that makes it easy for host applications to
  configure Slimmer correctly under test.

  Fixes `stub_shared_component_locales` helper to correctly stub HTTP
  requests to fetch locale information when rendering its templates.

  (PR #159 https://github.com/alphagov/slimmer/pull/159)

# 9.3.2

* Bugfix: Over time, the I18n backend would be chained in each request,
  causing the stack to grow too large and use too much memory

  (PR #157 https://github.com/alphagov/slimmer/pull/157)

# 9.3.1

* Allows frontend apps to stub component locales for example

  ```ruby
  class ActiveSupport::TestCase
    include Slimmer::TestHelpers::SharedTemplates

    def setup
      stub_shared_component_locales
    end
  end
  ```

  (PR #155 https://github.com/alphagov/slimmer/pull/155)

# 9.3.0

* Integrates translations from GOVUK Components to be used in applications

  When including `Slimmer::SharedComponents`, the I18nBackend will be chained to `Slimmer::I18nBackend` allowing translations in `static` to work in the frontend applications

  (PR #152 https://github.com/alphagov/slimmer/pull/152)

# 9.2.1

* Replaces deprecated `before_filter` calls in shared templates.

# 9.2.0

* Raise a custom `CouldNotRetrieveTemplate` exception when a connection to the assets server can't be made because of an SSL problem (PR #143).

# 9.1.0

* Allow applications to request components using full or partial component
  paths, eg "name", "name.raw" and "name.raw.html.erb". This allows
  components to be nested within other components.

# 9.0.1

* Change the find_templates method signature to add an optional arg that
  Rails now calls after CVE-2016-0752. No functionality changes.

# 9.0.0

* Change default template to `core_layout` from `wrapper`.
  Any application that doesn't define a custom template should have
  `slimmer_template 'wrapper'` added to its `application_controller` to
  maintain the old functionality

# 8.4.0

* Add support for moving `meta` tags that use `property` attribute

  Previously only meta tags using the `name` attribute were moved into the
  `head` of the page. This allows OpenGraph-style meta tags to be included
  by an application using Slimmer.

# 8.3.0

* Add support for 403 error page.

# 8.2.1

* Update rendering app meta tag to use GOVUK_APP_NAME env variable if available

# 8.2.0

* Add meta tag for currently running application

# 8.1.0

* Add remove_search header which strips out the search box in the header.

# 8.0.0

* Switch from JS custom variables to HTML meta tags

  Slimmer now appends page metadata as meta tags instead of setting Google
  custom variables within a script tag. The Google-specific implementation
  details have been removed.

  Any apps that need to report analytics events will require additional
  Javascript that reads the meta tags and sends the relevant data to the
  analytics platform. The current best practice for doing this is using
  the GOV.UK Analytics API - you can find the [code, examples and documentation
  in `govuk_frontend_toolkit`](https://github.com/alphagov/govuk_frontend_toolkit/blob/master/docs/analytics.md).

* Remove Proposition header, since this information wasn't being used

# 7.0.0

* Remove AlphaLabelInserter, BetaNoticeInserter, BetaLabelInserter. These are
  now better handled by govuk_components
* Remove LogoClassInserter. BusinessLink and DirectGov branding is being
  removed so we don't need to insert their logos
* Loosen Nokogiri dependency. Rails 4.2 needs Nokogiri 1.6.0 and above.

# 6.0.0

* Change ComponentResolver to use a bespoke tag - `test-govuk-component` - when
  running in a test, rather than `script`. Use `data-template` rather than
  `class` to identify which template was used.
* Fix bug where Slimmer::TestHelpers::SharedTemplates#shared_component_selector
  returned the wrong selector.

# 5.1.0

* `ComponentResolver#test_body` returns a JSON blob of the components keys and values instead of just the values.

* Add an I18n backend to load translations over the network from static

# 5.0.1

* Fix MetaViewportRemover to not raise an exception if there is no meta
  viewport tag. Issue became apparent in 4.3.1.

# 5.0.0

This release contains breaking changes.

* The report-a-problem form is now zero-configuration; it's no longer necessary
  to add a `div class="report-a-problem"` or extra styling to the app. Slimmer
  appends the form to the `wrapper` div by default (the default CSS selector for
  the wrapper div is `#wrapper`, but this id can be overwritten by defining
  `config.slimmer.wrapper_id` in the app's `application.rb`).

* The report-a-problem form is now opt-out; it's added by default, but can be
  skipped by setting the `Slimmer::Headers::REPORT_A_PROBLEM_FORM` header value
  to `false`.

* The steps for upgrading an app that already has report-a-problem are:

  1. Remove all `div class="report-a-problem"` from the app
  2. Remove all CSS relating to `report-a-problem` or `report-a-problem-toggle`
  3. Set `Slimmer::Headers::REPORT_A_PROBLEM_FORM` to `false` for any controllers
  or actions where you don't want the form to appear.

# 4.3.1

* When running tests, don't hide exceptions in the processors. Fix a bug in the
  Search-Parameters processor's handling of missing headers revealed by this.

# 4.3.0

* Add a Search-Parameters header, to allow apps to add extra parameters to
  search requests made from the page.

# 4.2.2

* Remove unused include

# 4.2.1

* Use a shared cache between shared templates and skin templates so that they
  all update together

# 4.2.0

* Add ability to load shared erb templates over the network

# 4.1.1

* Assets are loaded from production instead of preview environment in test mode

# 4.1.0

* Add ALPHA_LABEL functionality

# 4.0.1

* Improve exception reporting by including rack_env

# 4.0.0

* Remove search-index header as there are no longer tabs on search

# 3.29.0

* Send processor exceptions to errbit via Airbrake gem if present

# 3.28.1

* Added nil check for multivalue custom vars in google analytics configurator

# 3.28.0

* Report multiple need ids to Google analytics and Performance tracking
* Removed unused need_id header

# 3.27.0

* Added BETA_LABEL header and deprecated BETA_NOTICE header.

# 3.26.0

* Added X-Slimmer-World-Location header, value of which will be passed onto Google Analytics.

# 3.25.0

* Pass on GOVUK-Request-Id HTTP header when fetching templates
* Use correct asset host in test templates
* Remove a redundant ERB pass over fetched templates

# 3.24.0

* Removed CampaignNotificationInserter.  The homepage no longer needs these inserted.

# 3.1.0

* 'Breadcrumb' trail is now populated from the artefact data. It adds the section and subsection.

# 3.0.0

Backwards-incompatible changes:
* Artefact is expected to follow the format emitted by the Content API

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
