//
//  CatKit.swift
//  CatKit
//
//  Created by Seungjun Lee on 8/6/26.
//

import Foundation

public final class CatKitResources {
    public static let bundle = Bundle(url: Bundle.main.bundleURL.appendingPathComponent("PlugIns/CatKitResources.bundle"))
}

public struct Cat {
    public let name: String
    public let imageName: String
    public let description: String

    public init(name: String, imageName: String, description: String) {
        self.name = name
        self.imageName = imageName
        self.description = description
    }
}

public enum Cats {
    public static let all: [Cat] = [
        Cat(name: "치즈 고양이", imageName: "cat01", description: "주황색 털을 가진 귀여운 고양이"),
        Cat(name: "턱시도 고양이", imageName: "cat02", description: "검정과 하양이 조화로운 고양이"),
    ]
}
