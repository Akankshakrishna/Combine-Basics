import UIKit
import Combine
import Foundation

public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}
var subscriptions = Set<AnyCancellable>()

example(of: "filter") {
    let numbers = (1...10).publisher
    numbers
        .filter({ $0.isMultiple(of: 3)})
        .sink { n in
            print("\(n) is a multiple of 3!")
        }
        .store(in: &subscriptions)
}

/// skips if consecutive duplicate element found
example(of: "removeDuplicates") {
    let words = "hey hey there! want to listen to mister mister ?"
        .components(separatedBy: " ")
        .publisher
    words
        .removeDuplicates()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// it handles nil values also.
example(of: "compactMap") {
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    strings
        .compactMap({ Float($0) })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// ignores all values, no values found to print in receiveValu completion
example(of: "ignoreOutput") {
    let numbers = (1...10_000).publisher
    numbers
        .ignoreOutput()
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// it returns the first match and then subscription cancels itself
example(of: "first(where:)") {
    let numbers = (1...9).publisher
    numbers
        .print("numbers")
        .first(where: { $0 % 2 == 0})
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// publisher must complete for this operator to work, because to find last item match.
example(of: "last(where:)") {
    let numbers = (1...9).publisher
    numbers
        .last(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// in this, without completion last operator cant work.
example(of: "last(where:)") {
    let numbers = PassthroughSubject<Int,Never>()
    numbers
        .last(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished)
}

/// drops specified no.of values and emits next values
example(of: "dropFirst") {
    let numbers = (1...10).publisher
    numbers
        .dropFirst(8)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// drops all elements until the condition met
/*
 Differences between filter and drop
    -filter lets values through if you return true in the closure, while drop(while:) skips values as long you return true from the closure.
    -filter never stops evaluating its condition for all values published by the upstream publisher while drop(while:)’s predicate closure will never be executed again after the condition is met
 */
example(of: "drop(while:)") {
    let numbers = (1...10).publisher
    numbers
        .drop(while: { $0 % 5 != 0 })
//        .drop(while: {
//          print("x")
//          return $0 % 5 != 0
//        })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// drops elements until value is sent to isReady
example(of: "drop(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    (1...5).forEach { n in
        taps.send(n)
        if n == 3 {
            isReady.send()
        }
    }
}

/// it is exactly opposite to drop, it returns the values until specified no. of values returned then publisher completes
example(of: "prefix") {
    let numbers = (1...10).publisher
    numbers
        .prefix(2)
        .collect()
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// it returns all values until conditition true and once false publisher completes
example(of: "prefix(while:)") {
    let numbers = (1...10).publisher
    numbers
        .prefix(while: { $0 < 4 })
        .collect()
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prefix(unitiOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    (1...5)
        .forEach { n in
            taps.send(n)
            if n == 2 {
                isReady.send()
            }
        }
}


// Challenge

example(of: "Challenge") {
    let numbers = (1...100).publisher

    numbers
        .dropFirst(50)
        .prefix(20)
        .filter({ $0 % 2 == 0})
        .collect()
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

