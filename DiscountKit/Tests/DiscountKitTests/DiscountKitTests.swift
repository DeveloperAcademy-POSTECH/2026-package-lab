import Testing
@testable import DiscountKit

@Test("20% 할인")
func appliesTwentyPercentDiscount() async throws {
    let calculator = DiscountCalculator()
    
    let result = try calculator.finalPrice(price: 10000, discountRate: 0.2)
    
    #expect(result == 8000)
}

@Test("0% 할인")
func zeroDiscountKeepsOriginalPrice() async throws {
    let calculator = DiscountCalculator()
    
    let result = try calculator.finalPrice(price: 10000, discountRate: 0)
    
    #expect(result == 10000)
}

@Test("유효하지 않은 값 할인")
func invalidDiscountThrowsError() async throws {
    let calculator = DiscountCalculator()
    
    #expect(throws: DiscountError.invalidDiscountRate) {
        try calculator.finalPrice(price: 10000, discountRate: 1.5)
    }
}
