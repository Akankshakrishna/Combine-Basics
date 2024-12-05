//
//  Story.swift
//  Chapter15
//
//  Created by Akanksha.A on 27/02/24.
//

import SwiftUI

struct Story: Codable, Identifiable {
  let id: Int
  let title: String
  let by: String
  let time: TimeInterval
  let url: String
}

extension Story: Comparable {
  static func < (lhs: Story, rhs: Story) -> Bool {
    return lhs.time > rhs.time
  }
}

extension Story: CustomDebugStringConvertible {
  var debugDescription: String {
    return "\(title)\nby \(by)\n\(url)\n-----"
  }
}
