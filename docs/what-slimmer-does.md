Slimmer is a piece of Rack Middleware that is inserted near the top of the middleware stack. Note that Slimmer is used in frontend apps such as finder-frontend, rather than publishing apps.

It takes a response from the Rails app, and a template from [Static](https://github.com/alphagov/static/), and combines these into a single response. This allows us to do things like add 'Sign in' / 'Sign out' links to the header (or, more accurately, remove whichever link is not applicable) prior to rendering the page. This can't be done natively in Static because it would mean we can't cache responses from Static, which is a hosted service (i.e. templates are downloaded over HTTP). Slimmer is local to the app, so just a means of sharing the code that interfaces with Static, and can cache the fetched templates, locales and components.

## How Slimmer works

- The Rails app defines the 'slimmer' gem as a dependency in the Gemfile.
- Slimmer [bundles all its `lib` files](https://github.com/alphagov/slimmer/blob/3cdf3bfb6db35c03992ecd9c1210e866f99464f3/slimmer.gemspec#L420) in the gem, so that they're available to the Rails app.
- The gem (and all its `lib/` files) is `require`'d in to the Rails app [via Bundler](https://github.com/alphagov/finder-frontend/blob/918bdd9c5539181e01229fc1e9a95f8db9e68b0c/config%2Fapplication.rb#L20). As an aside, Rails' `boot.rb` [calls Bundler's setup script](https://github.com/alphagov/finder-frontend/blob/68bb527f1658d1e1dd3e1d59c3bfa1fb9aa22e7e/config%2Fboot.rb#L3), which modifies the `GEM_PATH`, meaning we don't need to explicitly `require` our Slimmer classes before we include them in the Rails app.
- One of the pulled in classes is `Slimmer::Railtie`, which [adds initialization steps to the Rails boot process](https://api.rubyonrails.org/classes/Rails/Railtie.html#class-Rails::Railtie-label-Initializers) to [automatically invoke `Slimmer::App`](https://github.com/alphagov/slimmer/blob/5d760839a03db958bfdcfc5ac7582009aa4cab86/lib%2Fslimmer%2Frailtie.rb#L5-L11), which in turn [initialises `Slimmer::Skin`](https://github.com/alphagov/slimmer/blob/3cdf3bfb6db35c03992ecd9c1210e866f99464f3/lib%2Fslimmer%2Fapp.rb#L28) where much of the functionality happens.
- Back to the Rails app now. The Rails app [defines what Slimmer template it needs](https://github.com/alphagov/finder-frontend/blob/3d8cb97f0aa70cf5f54bac5520d39f5303378a0c/app%2Fcontrollers%2Fapplication_controller.rb#L3-L4), in the `ApplicationController`.
- Every request to the app goes through the `ApplicationController`, and every response from the app therefore gets proxied through `Slimmer::App`. The response is passed to its [`call` method](https://github.com/alphagov/slimmer/blob/3cdf3bfb6db35c03992ecd9c1210e866f99464f3/lib%2Fslimmer%2Fapp.rb#L31-L44), which delegates to `Slimmer::Skin` to rewrite the response. 
- `Slimmer::Skin` lists [all of the processors](https://github.com/alphagov/slimmer/blob/862dcd5bdd4b87f3db7196f1d491be76398dbe6d/lib%2Fslimmer%2Fskin.rb#L105-L119) to be applied to the response. Each processor has its own class (e.g. [`Slimmer::Processors::AccountsShower`](https://github.com/alphagov/slimmer/blob/53017b64aede73de04bda2d301adea282fbaa832/lib%2Fslimmer%2Fprocessors%2Faccounts_shower.rb#L2)) responsible for defining the HTML to be removed, replaced or added.
- `Slimmer::Skin` also determines which [template](https://github.com/alphagov/slimmer/blob/862dcd5bdd4b87f3db7196f1d491be76398dbe6d/lib%2Fslimmer%2Fskin.rb#L121) to mix the response with. The template name is determined via [mappings in `Slimmer::Headers`](https://github.com/alphagov/slimmer/blob/53017b64aede73de04bda2d301adea282fbaa832/lib%2Fslimmer%2Fheaders.rb#L21), which is ultimately set in the Rails app via its `slimmer_template` call earlier, defaulting to "core_layout".
- The template name is [converted to a URL](https://github.com/alphagov/slimmer/blob/862dcd5bdd4b87f3db7196f1d491be76398dbe6d/lib/slimmer/skin.rb#L39-L43) that points to Static.
- Requests to Static get [routed to the RootController](https://github.com/alphagov/static/blob/33be5158c3922516cadba9473609cccd5d85fdae/config%2Froutes.rb#L12), which route to the chosen template (e.g. [`views/root/core_layout.html.erb`](https://github.com/alphagov/static/blob/875b5a5c74bf85d324d9650bed0c4b173da26902/app%2Fviews%2Froot%2Fcore_layout.html.erb)).
- The template is fetched and then [cached using the Rails cache](https://github.com/alphagov/slimmer/blob/1d270026389f1d893c506c082c124501560ef03d/lib/slimmer.rb#L13).
- The [processors are mixed with the template](https://github.com/alphagov/slimmer/blob/862dcd5bdd4b87f3db7196f1d491be76398dbe6d/lib/slimmer/skin.rb#L81-L100), the [headers recalculated](https://github.com/alphagov/slimmer/blob/3cdf3bfb6db35c03992ecd9c1210e866f99464f3/lib%2Fslimmer%2Fapp.rb#L92) and the [response returned](https://github.com/alphagov/slimmer/blob/3cdf3bfb6db35c03992ecd9c1210e866f99464f3/lib%2Fslimmer%2Fapp.rb#L94).

## Templates

There are a few [different templates in Static](https://github.com/alphagov/static/tree/master/app/views/root) so that apps can render consistent error pages, core layout pages, pages without footer links and so on.

Apps can choose to look for templates somewhere other than Static by [specifying the `asset_host`](https://github.com/alphagov/slimmer/blob/3cdf3bfb6db35c03992ecd9c1210e866f99464f3/lib%2Fslimmer%2Fapp.rb#L24-L26).

## Processors

### TitleInserter

Takes the `<title>` content from the Rails response and copies it into the template.

### TagMover

Copies `<script>`, `<link>`, and `<meta>` tags from the Rails response into the template's `<head>`.

For `<script>` and `<link>` tags it only copies tags with a `src` and `href` attribute respectively, and only if a tag with a matching attribute doesn't already exist in the template.

For `<meta>` tags, it only copies tags with a `name`, and `content` attribute, and only if a tag with matching attributes (and a matching `http-eqiv` attribute) doesn't already exist.

### ConditionalCommentMover

Takes any conditional comments from the Rails response, and appends them to the template's `<head>`

### BodyInserter

Takes the entirety of the element `#wrapper` (by default), and replaces the corresponding `#wrapper` element in the template with it. Both the source and destination selector can be configured.

### BodyClassCopier

Takes any classes applied to the `<body>` element in the Rails response, and adds them to the `<body>` element in the template. This will add to any classes already existing in the template.

### HeaderContextInserter

Takes an element in the Rails response with a selector of `.header-context` (by default), and replaces the corresponding element in the template with it. Does nothing unless the selector exists in both.

The `.header-context` element typically wraps the 'breadcrumb' trail on the site.

### SearchPathSetter

If there is an `X-Slimmer-Search-Path` header in the Rails response, it finds the search form (`form#search`) in the template, and replaces the action attribute with the value of the header.
