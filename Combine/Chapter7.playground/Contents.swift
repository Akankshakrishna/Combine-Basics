import UIKit
import Combine
import Foundation

public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}
var subscriptions = Set<AnyCancellable>()

/// until completion received it wont return min value
example(of: "min") {
  let publisher = [1, -50, 246, 0].publisher
  publisher
//    .print("publisher")
    .min() /// conforms to comparable protocol so no need of arguments
    .sink(receiveValue: { print("Lowest value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "min(by:) for non-Comparable") {
  let publisher = ["12345", "ab", "hello world"]
    .compactMap { $0.data(using: .utf8) } /// [Data] and Data doesn't conform to Comparable Protocol
    .publisher // Publisher<Data, Never>
  publisher
//    .print("publisher")
    .min(by: { $0.count < $1.count }) /// Data is not Comparable we need to send closure
    .sink(receiveValue: { data in
        let string = String(data: data, encoding: .utf8)!
        print("Smallest data is \(string), \(data.count) bytes")
    })
    .store(in: &subscriptions)
}

/// until completion received it wont return max value like min operator
example(of: "max") {
  let publisher = ["A", "F", "Z", "E"].publisher
  publisher
//    .print("publisher")
    .max()
    .sink(receiveValue: { print("Highest value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "max(by:) for non-Comparable") {
  let publisher = ["12345", "ab", "hello world"]
    .compactMap { $0.data(using: .utf8) } /// [Data] and Data doesn't conform to Comparable Protocol
    .publisher // Publisher<Data, Never>
  publisher
//    .print("publisher")
    .max(by: { $0.count < $1.count }) /// Data is not Comparable we need to send closure
    .sink(receiveValue: { data in
        let string = String(data: data, encoding: .utf8)!
        print("Largest data is \(string), \(data.count) bytes")
    })
    .store(in: &subscriptions)
}

/// after emitting first value immediately completion receives and subscription cancels
example(of: "first") {
    let publisher = ["A", "B", "C"].publisher
    publisher
//        .print("publisher")
        .first()
        .sink(receiveValue: { print("First value is \($0)") })
        .store(in: &subscriptions)
}

example(of: "first(where:)") {
  let publisher = ["J", "O", "W", "H", "N"].publisher
  publisher
//    .print("publisher")
    .first(where: { "Hello World".contains($0) })
    .sink(receiveValue: { print("First match is \($0)") })
    .store(in: &subscriptions)
}

/// until completion receives it wont return last value
example(of: "last") {
    let publisher = ["A", "B", "C"].publisher
    publisher
//        .print("publisher")
        .last()
        .sink(receiveValue: { print("Last value is \($0)") })
        .store(in: &subscriptions)
}

example(of: "last(where:)") {
    let publisher = ["J", "O", "W", "H", "N"].publisher
    publisher
//        .print("publisher")
        .last(where: { "Hello World".contains($0) })
        .sink(receiveValue: { print("Last value is \($0)") })
        .store(in: &subscriptions)
}

///emits only the value emitted at the specified index and immediately cancels subscription
example(of: "output(at:)") {
  let publisher = ["A", "B", "C"].publisher
  publisher
    .print("publisher")
    .output(at: 1)
    .sink(receiveValue: { print("Value at index 1 is \($0)") })
    .store(in: &subscriptions)
}

/// emits values whose indices are within a provided range and then immediately cancels subscription
example(of: "output(in:)") {
  let publisher = ["A", "B", "C", "D", "E"].publisher
  publisher
    .output(in: 1...3)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print("Value in range: \($0)") })
    .store(in: &subscriptions)
}

/// return single value as no.of values were emitted by the upstream publisher when publisher sends completion as .finished
example(of: "count") {
  let publisher = ["A", "B", "C"].publisher
  publisher
//    .print("publisher")
    .count()
    .sink(receiveValue: { print("I have \($0) items") })
    .store(in: &subscriptions)
}

///return bool value, once match is found it cancels the subscription (lazy)
example(of: "contains") {
    let publisher = ["A", "B", "C", "D", "E"].publisher
    let letter = "K"
    publisher
//        .print("publisher")
        .contains(letter)
        .sink(receiveValue: { contains in
            print(contains ? "Publisher emitted \(letter)!"
                  : "Publisher never emitted \(letter)!")
        })
        .store(in: &subscriptions)
}

example(of: "contains(where:)") {
    struct Person {
        let id: Int
        let name: String
    }
    let people = [
        (456, "Scott Gardner"),
        (123, "Shai Mishali"),
        (777, "Marin Todorov"),
        (214, "Florent Pillet")
    ]
        .map(Person.init)
        .publisher
    people
        .contains(where: { $0.id == 456 })
        .sink(receiveValue: { contains in
            print(contains ? "Criteria matches!"
                  : "Couldn't find a match for the criteria")
            
        })
        .store(in: &subscriptions)
}

/// waits until completion finishes greedy) and as soon as condition false for any item subscription cancel and completes
example(of: "allSatisfy") {
    let publisher = stride(from: 0, to: 6, by: 3).publisher
    publisher
//        .print("publisher")
        .allSatisfy { $0 % 2 == 0 }
        .sink(receiveValue: { allEven in
            print(allEven ? "All numbers are even"
                  : "Something is odd...")
        })
        .store(in: &subscriptions)
}

/*
 scan and reduce have the same functionality, with the main difference being that scan emits the accumulated value for every emitted value, while reduce emits a single accumulated value once the upstream publisher sends a .finished completion event.
 */
example(of: "reduce") {
//    let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher
    let publisher = (1...10).publisher
    publisher
//        .print("publisher")
//        .reduce("") { accumulator, value in
//            accumulator + value
//        }
//        .reduce("", +)
        .reduce(0, +) /// since  + is sign we can write like this also
        .sink(receiveValue: { print("Reduced into: \($0)") })
        .store(in: &subscriptions)
}
