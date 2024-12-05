import UIKit
import Combine
import Foundation

public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}
var subscriptions = Set<AnyCancellable>()

// Prepending

/// it appends at beginning and prepend output type should match publisher output type
example(of: "prepend(Output...)") {
    let publisher = [3, 4].publisher
    publisher
        .prepend(1, 2)
        .prepend(-1, 0)
        .collect()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// it used to append array or set also as below at beginning itself
example(of: "prepend(Sequence)") {
    let publisher = [5, 6, 7].publisher
    publisher
        .prepend([3, 4])
        .prepend(Set(1...2))
        .prepend(stride(from: 6, to: 11, by: 2))
        .collect()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prpend(Publisher)") {
    let publisher1 = [3, 4].publisher
    let publisher2 = [1, 2].publisher
    publisher1
        .prepend(publisher2)
        .collect()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// until we send completion to publisher2 the two publishers doesnt combine and thinking that some more values still available from publisher2 , it only return prepended publisher values only untili completion.
example(of: "prepend(Publisher) #2") {
    let publisher1 = [3, 4].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}

// Appending

/// same as prepend but at the end it appends
example(of: "append(Output...)") {
    let publisher = [1].publisher
    publisher
        .append(2, 3)
        .append(4)
        .collect()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/// until we send completion to publisher the values wont append and thinking that some more values still available from publisher , it only return publisher values only untili completion.
example(of: "append(Output...) #2") {
    let publisher = PassthroughSubject<Int, Never>()
    publisher
        .append(3, 4)
        .append(5)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
}

example(of: "append(Sequence)") {
    let publisher = [1, 2, 3].publisher
    publisher
        .append([4, 5])  // ordered
        .append(Set([6, 7])) // unordered since set
        .append(stride(from: 8, to: 11, by: 2))
        .collect()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Publisher)") {
  let publisher1 = [1, 2].publisher
  let publisher2 = [3, 4].publisher
  publisher1
    .append(publisher2)
    .collect()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

// Advanced Combining

/// as we add new publisher to publishers the previous one will cancels its subscription
example(of: "switchToLatest") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    publishers
        .switchToLatest()
        .sink(receiveCompletion: { _ in print("Completed!") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)
    
    publishers.send(publisher2) /// here publisher1 subscription is cancelled
    publisher1.send(3)
    publisher2.send(4)
    publisher2.send(5)
    
    publishers.send(publisher3) /// here publisher2 subscription is cancelled
    publisher2.send(6)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
}

///# switchToLatest Use case
/*
 switchToLatest Use case
 consider the following scenario: Your user taps a button that triggers a network
 request. Immediately afterward, the user taps the button again, which triggers a
 second networkrequest. But how do you get rid of the pending request, and only
 use the latest request? switchToLatest to the rescue!
 */

//example(of: "switchToLatest - Network Request") {
//    let url = URL(string: "https://source.unsplash.com/random")!
//    func getImage() -> AnyPublisher<UIImage?, Never> {
//        return URLSession.shared
//            .dataTaskPublisher(for: url)
//            .map({ data, _ in UIImage(data: data) })
//            .print("image")
//            .replaceError(with: nil)
//            .eraseToAnyPublisher()
//    }
//    let taps = PassthroughSubject<Void, Never>()
//    taps
//        .map { _ in
//            getImage()
//        }
//        .switchToLatest()
//        .sink { _ in }
//        .store(in: &subscriptions)
//    taps.send()
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//        taps.send()
//    }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
//        taps.send()
//    }
//}

/// merge allows upto 8 different publishers to merge
example(of: "merge(with:)") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    publisher1
        .merge(with: publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send(3)
    publisher1.send(4)
    publisher2.send(5)
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

/// it can combine different data type publishers, we may combine upto 4 publishers
/// combineLatest only combines once every publisher emits at least one value
example(of: "combineLatest") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    publisher1
        .combineLatest(publisher2)
//        .sink(receiveCompletion: { _ in print("Completed") },
//              receiveValue: { print("P1: \($0), P2: \($1)") })
        .sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { p1, p2 in
            print("P1: \(p1), P2: \(p2)")
        })
        .store(in: &subscriptions)
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

/// get a single tuple emitted every time both publishers emit a value( if p1 emits first value then zip waits for p2 to emit first value and then make a pair as tuple and then emits and vice versa), and those paired values in the same indexes 
example(of: "zip") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    publisher1
        .zip(publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions)
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    publisher2.send("d")
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}
