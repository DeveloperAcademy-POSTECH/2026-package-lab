import ShoppingCart

public struct CheckoutSummary: Equatable, Sendable {
    public let subtotal: Int
    public let discount: Int
    public let shippingFee: Int

    init(subtotal: Int, discount: Int, shippingFee: Int) {
        self.subtotal = subtotal
        self.discount = discount
        self.shippingFee = shippingFee
    }

    public var total: Int {
        subtotal - discount + shippingFee
    }
}

public enum DiscountPolicy: Sendable {
    case none
    case fixed(Int)
    case percentage(Int)

    func discountAmount(for subtotal: Int) -> Int {
        switch self {
        case .none:
            return 0
        case .fixed(let amount):
            return min(max(amount, 0), subtotal)
        case .percentage(let percent):
            let safePercent = min(max(percent, 0), 100)
            return subtotal * safePercent / 100
        }
    }
}

public enum ShippingPolicy: Sendable {
    case freeOver(Int)
    case flatRate(Int)

    func shippingFee(for subtotal: Int) -> Int {
        switch self {
        case .freeOver(let minimum):
            return subtotal >= minimum ? 0 : 3_000
        case .flatRate(let fee):
            return max(fee, 0)
        }
    }
}

public struct CheckoutService: Sendable {
    private let discountPolicy: DiscountPolicy
    private let shippingPolicy: ShippingPolicy

    public init(
        discountPolicy: DiscountPolicy = .none,
        shippingPolicy: ShippingPolicy = .freeOver(100_000)
    ) {
        self.discountPolicy = discountPolicy
        self.shippingPolicy = shippingPolicy
    }

    public func makeSummary(for cart: ShoppingCart) -> CheckoutSummary {
        let subtotal = cart.subtotal
        return CheckoutSummary(
            subtotal: subtotal,
            discount: discountPolicy.discountAmount(for: subtotal),
            shippingFee: shippingPolicy.shippingFee(for: subtotal)
        )
    }
}
