//
//  HelloWorldView.swift
//  CountriesSwiftUI
//
//  Created by Roo on 29/07/25.
//  Copyright © 2025 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct HelloWorldView: View {
    var body: some View {
        VStack {
            Image(systemName: "dog")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            
            Text("Hello World")
                .font(.largeTitle)
                .padding()
        }
        .navigationTitle("PetMatch")
    }
}

#Preview {
    HelloWorldView()
}