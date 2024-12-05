//
//  Settings.swift
//  Chapter15
//
//  Created by Akanksha.A on 27/02/24.
//

import Foundation
import Combine

fileprivate let keywordsFile = "filterKeywords"

final class Settings: ObservableObject {
  init() {
    if let storedKeywords: [FilterKeyword] = try? JSONFile.loadValue(named: keywordsFile) {
      self.keywords = storedKeywords
    }
  }
  
  @Published var keywords = [FilterKeyword]() {
    didSet {
      try? JSONFile.save(value: keywords, named: keywordsFile)
    }
  }
}
