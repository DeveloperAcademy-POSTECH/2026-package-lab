//
//  SPIContentView.swift
//  SPIPractice
//
//  Created by 더스틴 on 7/31/26.
//

import SwiftUI

@_spi(Experiment) import GreetingKit

struct SPIContentView: View {
    
    let service = GreetingService()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("\(service.greet(name: "Dustin"))")
            /// SPI 방식으로 GreetingKit을 import했기 때문에
            /// greetInEnglish 메서드를 사용할 수 있습니다.
            Text("\(service.greetInEnglish(name: "Dustin"))")
        }
        .padding()
    }
}

#Preview {
    SPIContentView()
}
