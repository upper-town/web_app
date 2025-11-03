# Upper Town

Repository for a web app with features for the gaming community.

## Info

Current domains in use by this app:

| Environment | Domain/site                | `APP_ENV`     | `RAILS_ENV `  |
| ----------- | ---------------------------| ------------- | ------------- |
| production  | https://upper.town         | `production`  | `production`  |
| development | http://uppertown.test:3000 | `development` | `development` |
| test        | http://uppertown.test:3100 | `test`        | `test`        |

Also,

- **Status Page**: https://upperstatus.town
- **Monitoring**: https://upperstatus.town/monitoring

## Development setup

### Hosts

Edit you `/etc/hosts` and add the following:

```
127.0.0.1    uppertown.test
```

That is the domain used locally for `development` and `test` environments.

### Ruby

You can manage Ruby versions using a version manager like [`asdf`].
Read more about how to install and use it.

[`asdf`]: https://asdf-vm.com/guide/getting-started.html

### Postgres

The app relies on Postgres for primary database and for cache, queues,
and rate limiting.

### Environment variables

The [`dotenv`] gem is available in development and test environments only,
and it reads and sets env vars from the `.env` and `.env.test` files.

[`dotenv`]: https://rubygems.org/gems/dotenv

To override env vars values, create files named `.env.local` and
`.env.test.local` on your local repository and set any variables you'd like
to override.

In production, env vars should be properly set in the app settings in the
cloud hosting service, and not from env files.

### Running the app in development

`Procfile.dev` has the list of processes needed for development. The [`bin/dev`]
script runs them with [`overmind`] which requires [`tmux`].

You can also run processes separately, each one in a terminal window.
In this case, make sure to run `source .env` and `source .env.local` before
running the processes.

[`bin/dev`]: bin/dev
[`overmind`]: https://rubygems.org/gems/overmind
[`tmux`]: https://github.com/tmux/tmux/wiki

### Testing Framework

This project uses the [Minitest] framework.

The spec DSL with `it`/`describe` blocks is available for use through the
[`minitest-rails`] gem. For assertions though, prefer normal test assertions
over spec expectations.

Inherit from the appropriate Rails test case class.

[Minitest]: https://github.com/minitest/minitest
[`minitest-rails`]: https://rubygems.org/gems/minitest-rails

### ApplicationRecord Factories for Tests

Factories are defined in `test/support/factories/`. Factories should represent
minimum-valid records, so you can skip setting attributes that are optional.

In tests, use factories to create/build records for the test cases. Set the
attributes that are important for your test case and let the factory take
care of the other attributes for you.

Factory helper methods are included in `ActiveSupport::TestCase` through
`include ApplicationRecordTestFactoryHelper` in `test/test_helper.rb`,
so you can call them directly in tests cases. For example:

```rb
it "does something" do
  user = create_user

  # ...
end
```

## Code Guidelines

This section describes some code guidelines.

### Rails Controllers

A controller should contain application layer code regarding the
request/response cycle and delegate business logic to services, queries, jobs.

It should set instance variables to be used by views.

### Rails Views

A view template should only contain presentation layer code, rendering view
partials or `ViewComponent` with data received from controllers and it can
use presenters.

### Rails Models

A Rails model represents a _data_ model and should contain data-related code.
Move business logic to services, queries, jobs.

### State machines

State machines can be implemented with plain Ruby/Rails code and, in some
cases, defining a state machine is not necessary.

### Services

Service objects encapsulate business logic code:

- Create a service class in `app/services/` or `app/domain/`
- Use a descriptive name for the service class with a verb, and do _not_ add a
  suffix to it
- Use descriptive names for the service methods. If it only exposes one method,
  name it `call`
- Return `true`/`false` or a `Result` object allowing the caller to decide what
  to do with the result; raise specific errors if appropriate
- Initialize with values if necessary but avoid storing state in service objects

### Queries

Query objects can compose or perform database queries using `ActiveRecord`
or `SQL`:

- Create a query class in `app/queries/` or `app/domain/`
- Use a descriptive name for the query class and add a `Query` suffix to it
- Use descriptive names for the query methods. If it only exposes one method,
  name it `call`
- Add args or keyword args to the methods if you need to customize the
  result of the query
- Return `ActiveRecord::Relation` or primitive values like `Array`, `Hash`,
  `Integer`, `String`, and boolean
- Initialize with a base scope or values if necessary but avoid storing state
  in query objects

### Jobs

Background jobs can perform an action asynchronously. [Solid Queue] is the
framework in use:

- Create a job class in `app/jobs/` or `app/domain/`
- Use a descriptive name for the job class and add a `Job` suffix to it
- Inherit from `ApplicationJob` and use the Active Job interface

[Solid Queue]: https://github.com/rails/solid_queue

### Policies

Policies are service/query objects specialized in checking if a user meets
certain conditions:

- Create a policy in `app/policies/` or `app/domain/`
- Use a descriptive name for the policy class and add a `Policy` suffix to it
- Use names like `#allowed?` for the policy methods
- Return `true`/`false`
- Initialize with the user record and any necessary arguments but avoid
  storing state in policies

### Validators

Validators run a set of validations on an `ActiveRecord`-like object. They can
be Ruby classes or inherit from a Rails validator class:

- Create a validator in `app/validators/` or `app/domain/`
- Use a descriptive name for the validator class and add a `Validator`
  suffix to it when it is a model validator
- Use names like `#valid?` and `#validate` for the validator methods
- Return `true`/`false`, and/or set `errors`
- Initialize with a record or value if necessary but avoid storing state
  in validators other than the `errors`

### Presenters

Presenters deal with presentation logic. If there is already a component
framework in place, like [`ViewComponent`], that could be a replacement for
your presenter logic:

- Create a presenter in `app/presenters/` or `app/domain/`
- Use a descriptive name for the presenter class and add a `Presenter`
  suffix to it
- Use descriptive names for the presenter methods
- Return primitive values that can be directly used in views

[`ViewComponent`]: https://rubygems.org/gems/view_component

### Domain

If you notice a set of services, queries, jobs etc composes a concept in your
domain, feel free to group them together under a more descriptive concept name.

For example, if a set of business logic relates to a concept called
"My New Concept", you can create a `app/domain/my_new_concept/` folder and
place files there namespaced with a `MyNewConcept` module.

Inside a concept folder, keep the same class naming convention for services,
queries, jobs etc but feel free to organize files in subfolders/modules
as you see fit, mapping to the domain language.

### Layered Architecture and Rails

Layered Architecture is a way to divide your code in layers each one focused on
a particular aspect of the software.

Embracing Rails, we can think of a layered architecture as:

- **Application layer**: Rails Controllers, Routes
- **Infrastructure layer**: Rails ApplicationRecord, API clients, SolidQueue,
  SolidCache, and other gems
- **Presentation layter**: Rails Views, Helpers, Presenters, ViewComponents
- **Domain layer**: models, services, queries, jobs

## Tests

To run the test suite, simply run `bin/rails test` and `bin/rails test:system`

For a given feature, there are different types of tests we can run: unit tests,
request tests, and system tests. In terms of time to write and compute time to
run, unit and requests tests are low-cost and system tests are more expensive.
So, it is practical to follow a [testing pyramid] by only testing critical
flows with system tests and being inclined to write more unit and request tests.

[testing pyramid]: https://martinfowler.com/articles/practical-test-pyramid.html

System tests spin up a browser while executing tests.

By default, these tests run in a headless browser but for debugging purposes it
can be useful to run them _headfully_. To run a system test _headfully_, set the
`HEADFUL` or `HEADLESS` environment variable while running the test command:
`HEADFUL=true bin/rails test:system` or `HEADLESS=false bin/rails test:system`

### WebMock stubs and VCR to record and replay HTTP requests

During tests, external HTTP requests are blocked. To allow requests to be sent,
we need to either stub them with [WebMock] or set [VCR] to record them.

[WebMock]: https://rubygems.org/gems/webmock
[VCR]: https://rubygems.org/gems/vcr

#### Using WebMock

WebMock is a gem that provides a set of utility methods to stub requests and
assert they have or have not been requested during a test case.
See [WebMock docs] for many examples on how to use it.

[WebMock docs]: https://github.com/bblimke/webmock

#### Using VCR

VCR is a gem that records to YAML files the HTTP requests performed in a test
case, and it replays them the next time the same test is run.

To use VCR, you can wrap your code in a block with

```rb
VCR.use_cassette("name_the/request_file_here") do
  # HTTP requests are allowed within this block. Requests will be recorded
  # and replayed during future test runs.
end
```

And to force VCR to re-record requests when running a test instead of replaying
existing records, just delete the specific YAML files, or set `VCR_RECORD_ALL`
to `true` while running the test command. For example,
`VCR_RECORD_ALL=true bin/rails test test/services/some_class_test.rb`.

This feature is provided by setting [`default_cassette_options`] `:record`
to `:all` in VCR configuration when `VCR_RECORD_ALL` is enabled.

[`default_cassette_options`]: https://relishapp.com/vcr/vcr/v/6-1-0/docs/configuration/default-cassette-options
