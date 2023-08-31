import SwiftUI

/// The protocol that typed app storage values must conform to.
///
/// The most important requirement is conformance to `Codable`. Use ``TypedAppStorage`` in SwiftUI views to store and fetch conforming data.
public protocol TypedAppStorageValue: Codable {
  /// The actual key under which this type of data is stored.
  static var appStorageKey: String { get }
  /// The default value to return, if there's no data under the specified ``appStorageKey``.
  static var defaultValue: Self { get }
}

/// Store and fetch typed data from `@AppStorage`.
///
/// Define the data model with ``TypedAppStorageValue`` conformance, then read and write with `@TypedAppStorage`.
/// See <doc:GettingStarted> for more information.
@propertyWrapper
public struct TypedAppStorage<Value: TypedAppStorageValue>: DynamicProperty {
  private var appStorage: AppStorage<String>
  private var initialValue: Value
  
  /// Store and fetch value from the defined store, with a predefined default value.
  ///
  /// This default value if defined is preferred over ``TypedAppStorageValue/defaultValue``.
  public init(wrappedValue: Value, store: UserDefaults? = nil) {
    initialValue = wrappedValue
    let initialData = try? JSONEncoder().encode(wrappedValue)
    let initialString = (initialData == nil ? nil : String(data: initialData!, encoding: .utf8)) ?? ""
    appStorage = .init(wrappedValue: initialString, Value.appStorageKey, store: store)
  }
  
  /// Store and fetch value from the defined store.
  ///
  /// ``TypedAppStorageValue/defaultValue`` is used if no value was previously saved.
  public init(store: UserDefaults? = nil) {
    self.init(wrappedValue: Value.defaultValue, store: store)
  }
  
  /// The wrapped ``TypedAppStorageValue``.
  public var wrappedValue: Value {
    get {
      guard let data = appStorage.wrappedValue.data(using: .utf8) else { return initialValue }
      return (try? JSONDecoder().decode(Value.self, from: data)) ?? initialValue
    }
    nonmutating set {
      guard
        let newData = try? JSONEncoder().encode(newValue),
        let newString = String(data: newData, encoding: .utf8)
      else { return }
      appStorage.wrappedValue = newString
    }
  }
  
  /// A two-way binding of ``wrappedValue``.
  public var projectedValue: Binding<Value> {
    .init {
      wrappedValue
    } set: { newValue in
      wrappedValue = newValue
    }
  }
}
