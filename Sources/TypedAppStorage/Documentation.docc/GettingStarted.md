# Getting Started

(Almost) as easy as `@AppStorage`.

## Overview

Add this package, define the data model with ``TypedAppStorageValue`` conformance, and then read and write with `@TypedAppStorage`.

### Add to Dependencies

Add this Swift Package using URL `https://github.com/laosb/TypedAppStorage`.

### Define Your Data Model

To use with ``TypedAppStorage/TypedAppStorage``, your data model must conforms to ``TypedAppStorageValue``.

``TypedAppStorageValue`` is essentially just `Codable` with ``TypedAppStorageValue/appStorageKey`` to define which `UserDefault` key the data should be saved under (the first parameter of `@AppStorage`), and ``TypedAppStorageValue/defaultValue`` to define an uniform default value for this specific type:

```swift
struct PreferredFruit: TypedAppStorageValue {
  enum Fruit: Codable, CaseIterable {
    case apple, pear, banana
  }
  enum Freshness: Codable, CaseIterable {
    case veryFresh, moderate, somewhatStale
  }

  static var appStorageKey = "preferredFruit"
  static var defaultValue = PreferredFruit(.veryFresh, .apple)

  var fruit: Fruit
  var freshness: Freshness

  init(_ freshness: Freshness, _ fruit: Fruit) {
    self.fruit = fruit
    self.freshness = freshness
  }
}
```

In most cases, you want a specific type to be stored under a specific key, with the same default value no matter where you use it.
By defining both alongside the data model, you take out the unnecessary duplication. So when used, you can omit both:

```swift
@TypedAppStorage var preferredFruit: PreferredFruit
```

Here, less duplication means smaller chance you may mess it up.

### Use in SwiftUI Views

As mentioned above, you can use it in SwiftUI views with even less ceremony:

```swift
struct PreferredFruitPicker: View {
  @TypedAppStorage var preferredFruit: PreferredFruit

  var body: some View {
    Picker(selection: $preferredFruit.freshness) { /* ... */ }
    Picker(selection: $preferredFruit.fruit) { /* ... */ }
  }
}
```

In some cases it might make sense to specify a different default value than the one defined in ``TypedAppStorageValue``:

```swift
@TypedAppStorage var preferredFruit: PreferredFruit = .init(.somewhatStale, .banana)
```

And you can specify a different store just like `@AppStorage`, if you're using things like App Groups.
