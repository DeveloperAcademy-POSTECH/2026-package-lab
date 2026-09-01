//
//  ContentView.swift
//  LoggerPractice
//
//  Created by 이은지 on 8/31/26.
//

import SwiftUI
import StringReverseKit

struct ContentView: View {
    @State private var text = "Package Lab !"

    var body: some View {
        VStack {
            Text(text)

            Button("reverse") {
                text = StringReverseKit().reversed(text)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
