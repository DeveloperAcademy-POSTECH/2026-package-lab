//
//  ContentView.swift
//  TargetPractice
//
//  Created by Youngmin Cho on 8/15/26.
//

import ShoppingCart
import ShoppingCheckout
import ShoppingModels
import SwiftUI

struct ContentView: View {
    @State private var cart = ShoppingCart()

    private let products = Product.sampleProducts
    private let checkout = CheckoutService(discountPolicy: .percentage(10))

    private var summary: CheckoutSummary {
        checkout.makeSummary(for: cart)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("상품") {
                    ForEach(products) { product in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.headline)
                                Text(product.category.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(product.price.formattedPrice)

                            Button {
                                cart.add(product)
                            } label: {
                                Image(systemName: "cart.badge.plus")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }

                Section("장바구니") {
                    if cart.items.isEmpty {
                        Text("상품을 담아보세요.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(cart.items, id: \.product.id) { item in
                            HStack {
                                Text(item.product.name)
                                Spacer()
                                Text("x\(item.quantity)")
                                Text(item.totalPrice.formattedPrice)
                                    .frame(width: 90, alignment: .trailing)
                            }
                        }
                    }
                }

                Section("결제") {
                    PriceRow(title: "상품 금액", price: summary.subtotal)
                    PriceRow(title: "10% 할인", price: -summary.discount)
                    PriceRow(title: "배송비", price: summary.shippingFee)
                    PriceRow(title: "최종 결제", price: summary.total, isTotal: true)
                }
            }
            .navigationTitle("Shopping Demo")
        }
    }
}

private struct PriceRow: View {
    let title: String
    let price: Int
    var isTotal = false

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(isTotal ? .bold : .regular)
            Spacer()
            Text(price.formattedPrice)
                .fontWeight(isTotal ? .bold : .regular)
        }
    }
}

private extension Int {
    var formattedPrice: String {
        "\(self)원"
    }
}

#Preview {
    ContentView()
}
