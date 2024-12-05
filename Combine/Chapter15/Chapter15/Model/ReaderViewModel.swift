//
//  ReaderViewModel.swift
//  Chapter15
//
//  Created by Akanksha.A on 27/02/24.
//

import Foundation
import Combine
import SwiftUI

class ReaderViewModel: ObservableObject {
    private let api = API()
    @Published private var allStories = [Story]()
    @Published var error: API.Error? = nil
    
    @Published var filter = [String]()
    private var subscriptions = Set<AnyCancellable>()
    
    func fetchStories() {
        api
            .stories()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.error = error
                }
            } receiveValue: { stories in
                self.allStories = stories
                self.error = nil
            }
            .store(in: &subscriptions)

    }
    
    var stories: [Story] {
        guard !filter.isEmpty else {
            return allStories
        }
        return allStories
            .filter { story -> Bool in
                return filter.reduce(false) { isMatch, keyword -> Bool in
                    return isMatch || story.title.lowercased().contains(keyword)
                }
            }
    }
    
    
}
