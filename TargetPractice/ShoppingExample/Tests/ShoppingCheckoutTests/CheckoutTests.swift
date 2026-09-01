import ShoppingCart
import ShoppingCheckout
import ShoppingModels
import Testing

@Test func checkoutAppliesPercentageDiscount() {
    var cart = ShoppingCart()
    cart.add(Product.sampleProducts[1])

    let checkout = CheckoutService(discountPolicy: .percentage(10))
    let summary = checkout.makeSummary(for: cart)

    #expect(summary.discount == 14_900)
    #expect(summary.total == 134_100)
}

@Test func fixedDiscountCannotExceedSubtotal() {
    var cart = ShoppingCart()
    cart.add(Product.sampleProducts[2])

    let checkout = CheckoutService(
        discountPolicy: .fixed(50_000),
        shippingPolicy: .flatRate(0)
    )
    let summary = checkout.makeSummary(for: cart)

    #expect(summary.discount == 12_000)
    #expect(summary.total == 0)
}

@Test func shippingIsFreeWhenSubtotalPassesMinimum() {
    var cart = ShoppingCart()
    cart.add(Product.sampleProducts[0], quantity: 2)

    let checkout = CheckoutService(shippingPolicy: .freeOver(100_000))
    let summary = checkout.makeSummary(for: cart)

    #expect(summary.shippingFee == 0)
}
