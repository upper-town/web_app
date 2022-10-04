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

[Sidekiq]: https://rubygems.org/gems/sidekiq
[Sidekiq best practices]: https://github.com/mperham/sidekiq/wiki/Best-Practices

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

[`ViewComponent`]: https://rubygems.org/gems/view_component

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

- __Application layer__: Rails Controllers, Routes
- __Infrastructure layer__: Rails Models, API clients, Sidekiq, and other gems
- __Presentation layter__: Rails Views, Helpers, Presenters, ViewComponents
- __Domain layer__: services, jobs, queries, concepts
