// The Swift Programming Language
// https://docs.swift.org/swift-book

public struct DiscountCalculator {
    public init() {}
    
    public func finalPrice(price: Int, discountRate: Double) throws -> Int {
        guard price >= 0 else {
            throw DiscountError.invalidPrice
        }
        
        guard (0...1).contains(discountRate) else {
            throw DiscountError.invalidDiscountRate
        }
        
        return Int(Double(price) * (1 - discountRate))
    }
}
