import ShoppingCart
import ShoppingCheckout
import ShoppingModels

@main
struct ShoppingApp {
    static func main() {
        var cart = ShoppingCart()
        let products = Product.sampleProducts

        cart.add(products[0], quantity: 2)
        cart.add(products[1])
        cart.add(products[2], quantity: 3)
        let checkout = CheckoutService(discountPolicy: .percentage(10))
        let summary = checkout.makeSummary(for: cart)

        print("ShoppingApp Target")
        print("------------------")
        print("ShoppingModels: 상품 정보")
        print("ShoppingCart: 장바구니 담기")
        print("ShoppingCheckout: 할인, 배송비, 결제 금액 계산")
        print("")

        for item in cart.items {
            print("- \(item.product.name) x\(item.quantity): \(item.totalPrice.formattedPrice)")
        }

        print("")
        print("Subtotal: \(summary.subtotal.formattedPrice)")
        print("Discount: \(summary.discount.formattedPrice)")
        print("Shipping: \(summary.shippingFee.formattedPrice)")
        print("Total: \(summary.total.formattedPrice)")
    }
}

private extension Int {
    var formattedPrice: String {
        "\(self)원"
    }
}
