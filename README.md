Rails Lite
==========

Rails Lite is a reimplementation of core Rails functionality from scratch.

ActiveRecord
------------

- the basic model model (whoa)
- assocations 
  - `belongs_to`
  - `has_one`
  - `has_many`
  - `has_one :through`
  - `has_many :through`
- relations, including lazy and stackable `where`s
- validations


Application API
---------------

- `Router`
    - generates new routes
    - takes in Rails-style paths and converts them to `RegExp`s with named groups, e.g. converts `/posts/:id` to `/^\/posts\/(?<id>[^\/]+)$/`
    - holds a collection of routes and passes the request to the first one which matches
    - includes an implementation of `resources` to quickly define standard RESTful routes; supports nesting
- `Route`
    - holds its path RegExp, HTTP method, controller class and action method
    - when called, instantiates a new controller and passes the request and response objects, as well as any route parameters
- `ControllerBase`
    - `render` finds an appropriately named ERB template and renders it, including the controller's binding
    - `redirect_to` does it what it says on the tin
    - delegates to @params and @session, respectively, to:
- `Params`
    - takes in params given in query string and request body (i.e. POST data)
    - parses keys to automatically nest hashes, e.g. given a text field named `cat[name]`, `@params[cat]` will be a hash containing `name`
- `Session`
    - finds the appropriate cookie in the request and populates the `session` hash when instantiated
    - serializes the `session` to JSON and stores it in the cookie when called to save
