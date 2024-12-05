//
//  ContentView.swift
//  Chapter15
//
//  Created by Akanksha.A on 27/02/24.
//

import SwiftUI

struct ContentView: View {
    @State var name: String = ""
    @State var profession: String = ""
    @State var type: String = ""
    var body: some View {
        VStack {
            TextField("Name", text: $name)
            TextField("Proffesion", text: $profession)
            Picker("Type", selection: $type) {
                Text("Freelance")
                Text("Hourly")
                Text("Employee")
            }
        }.padding()
    }
}

#Preview {
    ContentView()
}
