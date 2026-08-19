import ShoppingCart
import ShoppingModels
import Testing

@Test func addingSameProductIncreasesQuantity() {
    var cart = ShoppingCart()
    let hoodie = Product.sampleProducts[0]

    cart.add(hoodie)
    cart.add(hoodie, quantity: 2)

    #expect(cart.items.count == 1)
    #expect(cart.items[0].quantity == 3)
}

@Test func cartCalculatesSubtotal() {
    var cart = ShoppingCart()

    cart.add(Product.sampleProducts[0], quantity: 2)
    cart.add(Product.sampleProducts[2], quantity: 3)

    #expect(cart.subtotal == 154_000)
}
