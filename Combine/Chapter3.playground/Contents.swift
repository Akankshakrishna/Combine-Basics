import UIKit
import Combine
import Foundation

public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}
var subscriptions = Set<AnyCancellable>()

/// collect operator provides a way to transform a stream of individual values from a publisher into an array of those values.
example(of: "Collect") {
    ["A", "B", "C", "D", "E"].publisher
        .collect(2)   /// without no. of item it merge all in one array
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

///  transform a stream of individual values from a publisher to in some way
example(of: "map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    [123, 4, 56].publisher
        .map { value in
            formatter.string(for: NSNumber(integerLiteral: value)) ?? ""
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

public struct Coordinate {
  public let x: Int
  public let y: Int
  
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
}

public func quadrantOf(x: Int, y: Int) -> String {
  var quadrant = ""
  
  switch (x, y) {
  case (1..., 1...):
    quadrant = "1"
  case (..<0, 1...):
    quadrant = "2"
  case (..<0, ..<0):
    quadrant = "3"
  case (1..., ..<0):
    quadrant = "4"
  default:
    quadrant = "boundary"
  }
  
  return quadrant
}

/// maximum key path can have for map are 3 like .map(\.x, \.y, \.z)
example(of: "map key paths") {
    let publisher = PassthroughSubject<Coordinate, Never>()
    publisher
        .map(\.x, \.y)
        .sink { (x, y) in
            print("The coordinate at (\(x), \(y)) is in quadrant", quadrantOf(x: x, y: y))
        }
        .store(in: &subscriptions)
    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
}

/// several operators have a counterpart(may get error cases) try operator that will take a closure that can throw an error
example(of: "tryMap") {
    Just("Directory name that doesn't exist")
        .tryMap({ try FileManager.default.contentsOfDirectory(atPath: $0) })
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// The flatMap operator can be used to flatten multiple upstream publishers into a single downstream publisher — or more specifically, flatten the emissions from those publishers.
example(of: "flatMap") {
    func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
        Just(
            codes
                .compactMap { code in
                    guard (32...255).contains(code) else { return nil }
                    return String(UnicodeScalar(code) ?? " ")
                }
                .joined()
        )
        .eraseToAnyPublisher()
    }
    
    func modify(str: String) -> AnyPublisher<String, Never> {
        Just("The decoded unicode is \(str)")
            .eraseToAnyPublisher()
    }
    
    [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]
        .publisher
        .collect()
        .flatMap(decode)
        .flatMap(modify)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// ?? operator gives nil result even we give default value whereas this unwraps the optional with provided value for replaceNil operator
example(of: "replaceNil") {
    ["A", nil, "C"].publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "-")
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    let empty = Empty<Int, Never>()
    empty
        .replaceEmpty(with: 9)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "scan") {
    var dailyGainLoss: Int { .random(in: -10...10) }
    let feb2024 = (0..<22)
        .map { _ in
            dailyGainLoss
        }
        .publisher
    feb2024
        .scan(50) { latest, current in
//            print("latest: \(latest), current: \(current)")
            return max(0, latest + current)
        }
        .sink(receiveValue: { value in
//            print("Accumulated value \(value)")
        })
        .store(in: &subscriptions)
}

// Challenge


example(of: "Create a phone number lookup") {
    let contacts = [
        "603-555-1234": "Florent",
        "408-555-4321": "Marin",
        "217-555-1212": "Scott",
        "212-555-3434": "Shai"
    ]
    
    func convert(phoneNumber: String) -> Int? {
        if let number = Int(phoneNumber),
           number < 10 {
            return number
        }
        
        let keyMap: [String: Int] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
        ]
        
        let converted = keyMap
            .filter { $0.key.contains(phoneNumber.lowercased()) }
            .map { $0.value }
            .first
        
        return converted
    }
    
    func format(digits: [Int]) -> String {
        var phone = digits.map(String.init)
            .joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    func dial(phoneNumber: String) -> String {
        guard let contact = contacts[phoneNumber] else {
            return "Contact not found for \(phoneNumber)"
        }
        
        return "Dialing \(contact) (\(phoneNumber))..."
    }
    
    let input = PassthroughSubject<String, Never>()
    
    input
        .map(convert)
        .replaceNil(with: 0)
        .collect(10)
        .map(format)
        .map(dial)
        .sink(receiveValue: { print($0) })
    
    "0!1234567".forEach {
        input.send(String($0))
    }
    
    "4085554321".forEach {
        input.send(String($0))
    }
    
    "A1BJKLDGEH".forEach {
        input.send("\($0)")
    }
}



