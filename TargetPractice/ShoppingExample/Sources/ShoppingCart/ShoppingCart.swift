import ShoppingModels

public struct CartItem: Equatable, Sendable {
    public let product: Product
    public var quantity: Int

    init(product: Product, quantity: Int) {
        self.product = product
        self.quantity = quantity
    }

    public var totalPrice: Int {
        product.price * quantity
    }
}

public struct ShoppingCart: Sendable {
    public private(set) var items: [CartItem]

    public init(items: [CartItem] = []) {
        self.items = items
    }

    public var subtotal: Int {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    public mutating func add(_ product: Product, quantity: Int = 1) {
        guard quantity > 0 else { return }

        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }
}
