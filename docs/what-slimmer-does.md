Slimmer is a piece of Rack Middleware that is inserted near the top of the middleware stack.

It takes the response from the Rails app, and a template from static, and combines these into a single response.  It does this be taking various bits from the Rails response and inserting them into the template.  It has a number of processor classes that are each called in turn, and are responsible for a single piece of the transformation.  The set of processors depends on the response.  Error responses (4xx and 5xx) have one set.  Admin layout templates (triggered by requesting the admin template), have a different set, and then everything else has the default set.

## Default Set

### TitleInserter

Takes the `<title>` content from the Rails response and copies it into the template.

### TagMover

Copies `<script>`, `<link>`, and `<meta>` tags from the Rails response into the template's `<head>`.

For `<script>` and `<link>` tags it only copies tags with a `src` and `href` attribute respectively, and only if a tag with a matching attribute doesn't already exist in the template.

For `<meta>` tags, it only copies tags with a `name`, and `content` attribute, and only if a tag with matching attributes (and a matching `http-eqiv` attribute) doesn't already exist.

### ConditionalCommentMover

Takes any conditional comments from the Rails response, and appends them to the template's `<head>`

### BodyInserter

Takes the entirety of the element `#wrapper` (by default), and replaces the corresponding `#wrapper` element in the template with it.  Both the source and destination selector can be configured.

### BodyClassCopier

Takes any classes applied to the `<body>` element in the Rails response, and adds them to the `<body>` element in the template.  This will add to any classes already existing in the template.

### HeaderContextInserter

Takes an element in the Rails response with a selector of `.header-context` (by default), and replaces the corresponding element in the template with it.  Does nothing unless the selector exists in both.

The `.header-context` element typically wraps the 'breadcrumb' trail on the site.

### SectionInserter

Used to add a content specific section links to the 'breadcrumb' trail

This looks at the artefact it's given, and finds the primary section.  It then adds links for this section and all its ancestors in reverse order.  It uses the tag's `web_url` property for the link.

### GoogleAnalyticsConfigurator

This appends lines to the Google analytics config JS content to add corresponding custom vars.  It adds the following items:

* Section - This is the title of the artefacts primary root section (aka base section).
* Format - This is set from the `X-Slimmer-Format` HTTP header
* NeedID - This is set from the artefact
* Proposition - This is set from the artefact.  If the `business_proposition` boolean entry is present, this is set to 'business' or 'citizen' based on it.
* ResultCount - This is set from the `X-Slimmer-Result-Count` HTTP header

### SearchPathSetter

If there is an `X-Slimmer-Search-Path` header in the Rails response, it finds the search form (`form#search`) in the template, and replaces the action attribute with the value of the header.

### RelatedItemsInserter

Populates the contents of the related items box.

If a related items placeholder (`body.mainstream div#related-items`) is present in the Rails response, and an artefact has been given, a related items block is rendered using the related.raw template from static, and the artefact data.  This is then inserted replacing the placeholder in the template.

## Error set

This just applies the TitleInserter processor

## Admin set

This applies the following set:

* TitleInserter
* TagMover
* AdminTitleInserter
* FooterRemover
* BodyInserter
* BodyClassCopier

These are documented above except for:

### AdminTitleInserter

Looks for a `#site-title` in the Rails template, and replaces the content of the template's `.gds-header h2` with it's content.

### FooterRemover

Removes the `#footer` element from the Rails response.
