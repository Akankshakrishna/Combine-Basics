//
//  AddKeywordView.swift
//  Chapter15
//
//  Created by Akanksha.A on 27/02/24.
//

import SwiftUI

struct AddKeywordView: View {
    @State var newKeyword = ""
    
    let completed: (String) -> Void
    
    var body: some View {
        VStack(spacing: 50) {
            Text("New keyword")
                .font(.largeTitle)
                .padding(.top, 40)
            
            TextField("", text: $newKeyword)
                .padding(8)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                .padding()
            
            LargeInlineButton(title: "Add keyword") {
                guard !self.newKeyword.isEmpty else { return }
                self.completed(self.newKeyword)
                self.newKeyword = ""
            }
            
            Spacer()
        }
    }
}

#Preview {
    AddKeywordView(completed: { _ in })
}
