import Testing
@testable import DiscountKit

@Test("일반 회원 20% 할인")
func appliesTwentyPercentDiscount() throws {
    let calculator = DiscountCalculator()
    
    let result = try calculator.finalPrice(price: 10000, discountRate: 0.2)
    
    #expect(result == 8000)
}

@Test("일반 회원 0% 할인")
func zeroDiscountKeepsOriginalPrice() throws {
    let calculator = DiscountCalculator()
    
    let result = try calculator.finalPrice(price: 10000, discountRate: 0)
    
    #expect(result == 10000)
}

@Test("VIP 회원은 추가 10%할인")
func vipGetsAdditionalTenPercentDiscount() throws {
    let calculator = DiscountCalculator()
    
    let result = try calculator.finalPrice(price: 10000, discountRate: 0.2, membership: .vip)
    
    #expect(result == 7000)
}
