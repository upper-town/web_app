# Etherblade City

Repository for a web app with features for the game community.

## Development setup

### Ruby

You can manage Ruby versions using a version manager like [`asdf`].
Read more about how to install and use it.

[`asdf`]: https://asdf-vm.com/guide/getting-started.html

### Postgres and Redis

The app relies on Postgres as database and Redis as cache and job queue.
For development and test, you can install and run them manually on your computer.

### Environment variables

The [`dotenv-rails`] gem is available in development and test environments only,
and it reads and sets env vars from the `.env.development` and `.env.test` files.

[`dotenv-rails`]: https://rubygems.org/gems/dotenv-rails

To override env vars values, create files named `.env.development.local` and
`.env.test.local` on your local repository and set any variables you'd like to
override.

In production, env vars should be properly set in the app settings in the cloud
hosting service, and not from env files using `dotenv-rails`.

### FactoryBot

FactoryBot factories are defined in `spec/factories/`

Factories should represent minimum-valid records, so you can skip setting
attributes that are optional. Check FactoryBot docs and examples at
https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md

In tests, use FactoryBot's factories to create/build records for test cases.
Set the attributes that are important for your test case, and let FactoryBot
take care of the other attributes for you.

As FactoryBot helper methods are included in RSpec through
`spec/rails_helper.rb` and `spec/support/factory_bot_config`, you can call them
directly in tests cases. For example:

```rb
it "tests something" do
  user = create(:user)

  # ...
end
```

## Code Guidelines

This section describes some code guidelines.

### Rails Controllers

A controller should contain application layer code regarding the
request/response cycle and delegate business logic to services, queries, jobs,
or concepts.

It should set instance variables to be used by views.

### Rails Views

A view template should only contain presentation layer code, rendering view
partials or `ViewComponent` with data received from controllers and it can
use presenters.

### Rails Models

A Rails model represents a _data_ model and should contain data-related code.
Move business logic to services, jobs, or concepts.

### State machines

State machines can be implemented using plain Ruby/Rails methods and, in some
cases, defining a state machine is not necessary.

### Services

Service objects encapsulate business logic code:

- Create a service class in `app/services/`
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

- Create a query class in `app/queries/`
- Use a descriptive name for the query class and add a `Query` suffix to it
- Use descriptive names for the query methods. If it only exposes one method,
  name it `call`
- Add args or keyword args to the methods if you need to customize the
  result of the query
- Return `ActiveRecord::Relation` or primitive values like `Array`, `Hash`,
  `Integer`, `String`, and boolean
- Initialize with a base scope and values if necessary but avoid storing state
  in query objects

### Jobs

Jobs can perform an action asynchronously. [Sidekiq] is the background job
framework in use:

- Create a job class in `app/jobs/`
- Use a descriptive name for the job class and add a `Job` suffix to it
- Add `include Sidekiq::Job` to it
- Define a `perform` method with the args you need. Remember to use primitive
  types for args because when a job is scheduled, its args are serialized as
  JSON and persisted to a Redis queue. Later, a worker process picks up the job
  from the queue, deserializes the args and performs it.
- Follow the [Sidekiq best practices]

[sidekiq]: https://rubygems.org/gems/sidekiq
[sidekiq best practices]: https://github.com/mperham/sidekiq/wiki/Best-Practices

### Policies

Policies are service/query objects specialized in checking if a user meets
certain conditions:

- Create a policy in `app/policies/`
- Use a descriptive name for the policy class and add a `Policy` suffix to it
- Use names like `#allowed?` for the policy methods
- Return `true`/`false`
- Initialize with the user record and any necessary arguments but avoid
  storing state in policies

### Validators

Validators run a set of validations on an `ActiveRecord`-like object. They can
be Ruby classes or inherit from a Rails validator class:

- Create a validator in `app/validators/`
- Use a descriptive name for the validator class and add a `Validator`
  suffix to it
- Use names like `.valid?` and `#validate` for the validator methods
- Return `true`/`false`, and/or set `errors` to the `ActiveRecord`-like object
- Initialize with a record or value if necessary but avoid storing state
  in validators

### Presenters

Presenters deal with presentation logic. If there is already a component
framework in place, like [`ViewComponent`], that could be a replacement for
your presenter logic:

- Create a presenter in `app/presenters/`
- Use a descriptive name for the presenter class and add a `Presenter`
  suffix to it
- Use descriptive names for the presenter methods
- Return primitive values that can be directly used in views

[`viewcomponent`]: https://rubygems.org/gems/view_component

### Concepts

If you notice a set of services, queries, jobs etc composes a concept in your
domain, feel free to group them together under a more descriptive concept name.

For example, if a set of business logic relates to a concept called
"My New Concept", you can create a `app/concepts/my_new_concept/` folder and
place files there namespaced with a `MyNewConcept` module.

Inside a concept folder, keep the same class naming convention for services,
queries, jobs etc but feel free to organize files in subfolders/modules
as you see fit, mapping to the domain language.

### Layered Architecture and Rails

Layered Architecture is a way to divide your code in layers each one focused on
a particular aspect of the software. You can refer to the definition from Eric
Vans.

Embracing Rails, we can think of a layered architecture as:

- **Application layer**: Rails Controllers, Routes
- **Infrastructure layer**: Rails Models, API clients, Sidekiq, and other gems
- **Presentation layter**: Rails Views, Helpers, Presenters, ViewComponents
- **Domain layer**: services, jobs, queries, concepts

## Tests

To run the test suite, simply run `bundle exec rspec`.

For a given feature, there are different types of tests we can run varying from
unit tests to system tests. In terms of time to write and compute time to run,
unit tests are low-cost and system tests are more expensive. So, it is practical
to follow a [testing pyramid] by only testing critical flows with system tests
and being inclined to write more request and unit tests.

[testing pyramid]: https://martinfowler.com/articles/practical-test-pyramid.html

System specs (`type: :system`) spin up a browser while executing tests.
By default, these tests run in a headless browser but for debugging purposes
it can be useful to run them _headfully_. To run a system spec _headfully_,
set the `HEADFUL` environment variable while running the test command:
`HEADFUL=true bundle exec rspec`

### VCR to record and replay HTTP requests

During tests, external HTTP requests are blocked and, to allow requests to be
sent, we need to set [VCR] to record them. VCR is a gem that records to YAML
files the HTTP requests performed in a test case, and it replays them the next
time the same test is run.

[vcr]: https://rubygems.org/gems/vcr

To use VCR, you can wrap your code in a block with

```rb
VCR.use_cassette('name_the/request_file_here') do
  # HTTP requests are allowed within this block. Requests will be recorded
  # and replayed during future test runs.
end
```

Or use the RSpec [`:vcr` tag] in an RSpec `describe`/`context`/`it` block
and the request YAML file and path will be named based on the descriptions:

[`:vcr` tag]: https://relishapp.com/vcr/vcr/v/6-1-0/docs/test-frameworks/usage-with-rspec-metadata

```rb
RSpec.describe SomeClass do
  describe '#some_method' do
    context 'when user is present' do
      it 'does something', :vcr do
        # HTTP requests are allowed within this block. Requests will be recorded
        # and replayed during future test runs.
        #
        # File: spec/cassettes/SomeClass/_some_method/when_user_is_present/does_something.yml
      end
    end
  end
end
```

And to force VCR to re-record requests when running a test instead of replaying
existing records, just delete the specific YAML files, or set `VCR_RECORD_ALL`
to `true` while running the test command. For example,
`VCR_RECORD_ALL=true bundle exec rspec spec/services/some_class_spec.rb`.

This feature is provided by setting [`default_cassette_options`] `:record`
to `:all` in VCR configuration when `ENV["VCR_RECORD_ALL"]` is set to `"true"`

[`default_cassette_options`]: https://relishapp.com/vcr/vcr/v/6-1-0/docs/configuration/default-cassette-options
