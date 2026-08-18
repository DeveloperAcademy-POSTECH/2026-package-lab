//
//  WhaleKit.swift
//  WhaleKit
//
//  Created by Seungjun Lee on 8/6/26.
//

import Foundation

public final class WhaleKitResources{
    public static let bundle = Bundle(url: Bundle.main.bundleURL.appendingPathComponent("Frameworks/WhaleKit.framework"))
}

public struct Whale {
    public let name: String
    public let imageName: String
    public let description: String

    public init(name: String, imageName: String, description: String) {
        self.name = name
        self.imageName = imageName
        self.description = description
    }
}

public enum Whales {
    public static let all: [Whale] = [
        Whale(name: "혹등고래", imageName: "whale01", description: "바다에서 노래하는 거대한 포유류"),
        Whale(name: "범고래", imageName: "whale02", description: "흑백 무늬의 바다 최상위 포식자"),
    ]
}
