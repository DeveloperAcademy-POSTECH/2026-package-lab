import Foundation

public struct Product: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let price: Int
    public let category: ProductCategory

    public init(id: String, name: String, price: Int, category: ProductCategory) {
        self.id = id
        self.name = name
        self.price = price
        self.category = category
    }
}

public enum ProductCategory: String, Sendable {
    case fashion = "Fashion"
    case electronics = "Electronics"
    case grocery = "Grocery"
}

public extension Product {
    static let sampleProducts = [
        Product(id: "hoodie", name: "Academy Hoodie", price: 59_000, category: .fashion),
        Product(id: "keyboard", name: "Magic Keyboard", price: 149_000, category: .electronics),
        Product(id: "coffee", name: "Cold Brew Pack", price: 12_000, category: .grocery)
    ]
}
