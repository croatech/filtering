# Filtering

Gem for comfort filtering of ActiveRecord queries.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'filtering'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install filtering

## Usage
All you need to do is inherit custom filter service from `Filtering::Base` and define params for filtering.

### Example filter service

```
class Filters::UsersFilter < Filtering::Base
  def initialize(params, page)
    super(params, page)
  end

  private

  # Required methods

  def relation
    User.all
  end

  def simple_acessible_params
    %i[city age]
  end

  def complex_acessible_params
    %i[name]
  end

  # Complex filters

  def filter_by_name(name)
    results.where('name ILIKE ? or name_auto ILIKE ?', "%#{name}%", "%#{name}%")
  end
end

```
There are private methods:

`relation` is an ActiveRecord initial relation which must be filtered

`plain_acessible_params` array of params for an auto-filtering by `where`, so if you have `%i[city age]` will be called `User.where(city: city).where(age: age)`

`complex_acessible_params` array of params for filters with custom logic. If you have some params in that method you have to create methods for those custom filters with format: `filter_by_{param}`

### Calling
Controller usage example:

```
def index
  render json: Filters::UsersFilter.new(params, params[:page]).call
end
```
If you don't use Kaminari just delete page from initializer

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Filtering project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/filtering/blob/master/CODE_OF_CONDUCT.md).
