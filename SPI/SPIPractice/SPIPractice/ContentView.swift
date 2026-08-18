//
//  ContentView.swift
//  SPIPractice
//
//  Created by 더스틴 on 7/31/26.
//

import SwiftUI

import GreetingKit    // GreetingKit 불러오기

struct ContentView: View {
    
    let service = GreetingService()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("\(service.greet(name: "Dustin"))")
            
            /// SPI 방식으로 GreetingKit을 import하지 않았기 때문에
            /// greetInEnglish 메서드는 사용할 수 없습니다.
            // Text("\(service.greetInEnglish(name: "Dustin"))")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
