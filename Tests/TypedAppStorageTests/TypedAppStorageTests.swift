import XCTest
import SwiftUI
@testable import TypedAppStorage

struct PreferredFruit: TypedAppStorageValue, Equatable {
  enum Fruit: Codable {
    case apple, pear, banana
  }
  enum Freshness: Codable {
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

struct TestArticle: View {
  @TypedAppStorage var preferredFruit: PreferredFruit
  
  func changePreferred(to newValue: PreferredFruit) {
    preferredFruit = newValue
  }
  
  var body: some View {
    Text("Test")
  }
}

struct TestArticleWithADifferentDefault: View {
  @TypedAppStorage var preferredFruit: PreferredFruit = .init(.moderate, .pear)
  
  func changePreferred(to newValue: PreferredFruit) {
    preferredFruit = newValue
  }
  
  var body: some View {
    Text("Test")
  }
}

final class TypedAppStorageTests: XCTestCase {
  override func setUp() {
    UserDefaults.standard.removeObject(forKey: "preferredFruit")
  }
  
  func testReadDefaultValue() throws {
    let testArticle = TestArticle()
    
    XCTAssertEqual(testArticle.preferredFruit, PreferredFruit(.veryFresh, .apple))
  }
  
  func testCallSiteDefault() throws {
    let testArticle = TestArticleWithADifferentDefault()
    
    XCTAssertEqual(testArticle.preferredFruit, .init(.moderate, .pear))
  }
  
  func testSaveAndReadBack() throws {
    let testArticle = TestArticle()
    
    testArticle.changePreferred(to: .init(.somewhatStale, .banana))
    
    XCTAssertEqual(testArticle.preferredFruit, .init(.somewhatStale, .banana))
  }
  
  func testSaveAndReadElsewhere() throws {
    let articleA = TestArticle()
    let articleB = TestArticle()
    
    articleA.changePreferred(to: .init(.moderate, .banana))
    
    XCTAssertEqual(articleB.preferredFruit, .init(.moderate, .banana))
  }
}
