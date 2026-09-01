// The Swift Programming Language
// https://docs.swift.org/swift-book

public struct DiscountCalculator {
    public init() {}
    
    public func finalPrice(
        price: Int,
        discountRate: Double,
        membership: Membership = .regular
    ) throws -> Int {
        guard price >= 0 else {
            throw DiscountError.invalidPrice
        }
        
        guard (0...1).contains(discountRate) else {
            throw DiscountError.invalidDiscountRate
        }
        
        let additionalRate = membership == .vip ? 0.1 : 0
        let finalDiscountRate = discountRate + additionalRate
        
        return Int(Double(price) * (1 - finalDiscountRate))
    }
}
