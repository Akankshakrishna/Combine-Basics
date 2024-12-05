//
//  ReaderView.swift
//  Chapter15
//
//  Created by Akanksha.A on 27/02/24.
//

import SwiftUI

struct ReaderView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var model: ReaderViewModel
    @State var presentingSettingsSheet = false
    @EnvironmentObject var settings: Settings
    @State var currentDate = Date()
    
    private let timer = Timer.publish(every: 10, on: .main, in: .common)
        .autoconnect()
        .eraseToAnyPublisher()
    
    init(model: ReaderViewModel) {
        self.model = model
    }
    
    var body: some View {
        var filter: String = settings.keywords.isEmpty ? "Showing all stories" :
        "Filter: " + settings.keywords.map({ $0.value }).joined(separator: ", ")
        
        return NavigationView {
            List {
                Section(header: Text(filter).padding(.leading, -10)) {
                    ForEach(self.model.stories) { story in
                        VStack(alignment: .leading, spacing: 10) {
                            TimeBadge(time: story.time)
                            
                            Text(story.title)
                                .frame(minHeight: 0, maxHeight: 100)
                                .font(.title)
                            
                            PostedBy(time: story.time, user: story.by, currentDate: self.currentDate)
                            
                            Button(story.url) {
                                print(story)
                            }
                            .font(.subheadline)
                            .foregroundColor(self.colorScheme == .light ? Color.blue : Color.orange)
                            .padding(.top, 6)
                        }
                        .padding()
                    }
                    .onReceive(timer, perform: { now in
                        self.currentDate = now
                    })
                }.padding()
            }
            .listStyle(PlainListStyle())
            .sheet(isPresented: $presentingSettingsSheet, content: {
                SettingsView().environmentObject(self.settings)
            })
            .alert(item: self.$model.error, content: { error in
                Alert(
                    title: Text("Network Error"),
                    message: Text(error.localizedDescription),
                    dismissButton: .cancel()
                )
            })
            .navigationBarTitle(Text("\(self.model.stories.count) Stories"))
            .navigationBarItems(trailing:
                                    Button("Settings") {
                self.presentingSettingsSheet = true
            }
            )
        }.onAppear() {
            model.fetchStories()
        }
    }
}

#Preview {
    ReaderView(model: ReaderViewModel())
}
