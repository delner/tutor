Tutor
==========

[![Build Status](https://travis-ci.org/delner/tutor.svg?branch=master)](https://travis-ci.org/delner/tutor) ![Gem Version](https://img.shields.io/gem/v/tutor.svg?maxAge=2592000)
###### *For Ruby 2+*

*Supplemental teachings for your Ruby classes.*

### Table of Contents

 1. [Introduction](#introduction)
 2. [Installation](#installation)
 3. [Features](#features)
    1. [Attributes](#attributes)
        1. [Type-checking](#type-checking)
        2. [Defaults](#defaults)
        3. [Aliasing](#aliasing)
        4. [Custom getter & setter](#custom-getter-and-setter)
        5. [Inheritance](#inheritance)
 4. [Testing](#testing)
 5. [Development](#development)
 6. [Contributing](#contributing)
 4. [License](#license)

### <a name="introduction"></a>Introduction

**Tutor** adds some useful patterns and idioms to mixin to your classes.

e.g. Attributes with type and defaults

```ruby
class Vertex; end
class Polygon
  include Tutor::Attributes

  attribute(:sides, type: Integer, default: 3)
  attribute(:vertices, default: lambda { |polygon| Array.new(polygon.sides) { Vertex.new } })
end

p = Polygon.new
p.intialize_attributes
p.sides # => 3
p.vertices # => [#<Vertex>, #<Vertex>, #<Vertex>]
```

###<a name="installation"></a> Installation

##### If you're not using Bundler...

Install the gem via:

```
gem install tutor
```

Then require it into your application with:

```
require 'tutor'
```

##### If you're using Bundler...

Add the gem to your Gemfile:

```
gem 'tutor'
```

And then `bundle install` to install the gem and its dependencies.

###<a name="features"></a> Features

####<a name="attributes"></a> Attributes

Enable attributes on a class by including `Tutor::Attributes` module into the class/module you want to add attributes to.

```ruby
class Polygon
  include Tutor::Attributes
end
```

Then add an `attribute` to add a `name` and `name=` method to the class.

```ruby
class Polygon
  include Tutor::Attributes

  attribute(:sides)
end

Polygon.method_defined?(:sides) # => true
Polygon.method_defined?(:sides=) # => true
```

Of course, if this is all you need, then you might be better served just using `attr_accessor`. However, `attribute` gives you access to a few additional options.

#####<a name="type-checking"></a> Type-checking

```ruby
attribute(:sides, type: Integer)
```

Add type-checking by adding the `type` option, and the class you want to type check against. Any value that is of that type, or inherits from it, will be permitted. Any other value will raise an `ArgumentError`.

By default, `nil` passes the type check. However, if you want to disallow `nil` values, you can set the `nullable: false` option.

```ruby
attribute(:sides, type: Integer, nullable: false)
```

#####<a name="defaults"></a> Defaults

```ruby
attribute(:vertices, default: 3)
```

Adding the `default` option sets a default value for attribute, when `initialize_attributes` is called. To automatically set these defaults, add the function call to your `initialize` function.

```ruby
def initialize
  initialize_attributes
end
```

You can also pass it a `Hash` of attributes, which will override any default values.

```ruby
def initialize(custom_attributes = {})
  initialize_attributes(custom_attributes)
end
```

You can also set the default to a `Proc` or `lambda`. This is useful for non-static values, like class objects, where you want unique default objects per instance of your class.

```ruby
# NOTE: The following two definitions are NOT equivalent.

# Sets default to the same object for all instances.
attribute(:vertices, default: Vertex.new)

# Sets default to the different object for each instance.
attribute(:vertices, default: -> { Vertex.new })
```

These blocks optionally can be defined to accept an argument. In which case, the object being initialized will be passed in. Any explicitly provided attribute values, or previously set defaults will be accessible.

```ruby
attribute :vertices,
  default: lambda { |object| object.sides.times { Vertex.new } }
```

#####<a name="aliasing"></a> Aliasing

```ruby
attribute(:nodes)
attribute(:vertices, alias: :nodes)
```

Alias any other attribute with the `alias` option, and the name of the method.

##### <a name="custom-getter-and-setter"></a>Custom getter & setter

```ruby
attribute :vertices,
  get: lambda { |object| object.nodes },
  set: lambda { |object, value| object.nodes = value }
```

You can add custom get or set behavior for the attribute, by passing a `Proc` into the `get` or `set` options.

```ruby
attribute :vertices,
  get: lambda { |object| object.nodes },
  set: false
```

Passing a `false` or `nil` value for either `get` or `set` will skip that method declaration.

#####<a name="inheritance"></a> Inheritance

```ruby
class Angle; end

class Polygon
  include Tutor::Attributes
  attribute(:sides, type: Integer)
end

class Triangle < Polygon
  include Tutor::Attributes
  attribute(:angles, default: lambda { |o| o.sides.times { Angle.new } })
end

Triangle.new.initialize_attributes(sides: 3)
# => #<Triangle @sides=3, @angles=[ #<Angle>, #<Angle>, #<Angle>]>
```

Attributes can be initialized and accessed from inheriting classes. If an attribute name in a subclass conflicts with an already existing attribute or method, it will raise a `NameError`. You can, however, override the parent by passing the `override` option.

```ruby
class Angle; end

class Polygon
  include Tutor::Attributes
  attribute(:sides, type: Integer, default: 3)
end

class Square < Polygon
  include Tutor::Attributes
  attribute(:sides, type: Integer, default: 4, override: true)
end

Square.new.initialize_attributes
# => #<Square @sides=4>
```

### <a name="testing"></a>Testing

*Description pending.*

### <a name="development"></a>Development

Install dependencies using `bundle install`. Run tests using `bundle exec rspec`.

### <a name="contributing"></a>Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/delner/tutor.

### <a name="license"></a>License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
