// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct FishFeatureView: View {
    public init() {}
    public var body: some View {
        Image("Fish")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
}

#Preview {
    FishFeatureView()
}
