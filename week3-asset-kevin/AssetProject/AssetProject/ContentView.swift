//
//  ContentView.swift
//  AssetProject
//
//  Created by DS on 9/1/26.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        Image("SampleBanner")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
    }
}

#Preview {
    ContentView()
}
