import UIKit
import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

func example(of description: String, action: () -> Void) {
    print("\n——— Example of:", description, "———")
    action()
}

// Actual way of using NotificationCenter
example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let observer = center.addObserver(
        forName: myNotification,
        object: nil,
        queue: nil) { notification in
            print("Notification is received")
        }
    center.post(name: myNotification, object: nil)
    center.removeObserver(observer)
}

// NotificationCenter using publisher
// - Publisher without subscriber can't emit values
example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification")
    let publisher = NotificationCenter.default.publisher(for: myNotification, object: nil)
    let center = NotificationCenter.default
    let subscription = publisher
        .sink { _ in
            print("Notification received from a publisher!")
        }
    center.post(name: myNotification, object: nil)
    subscription.cancel()
}

/// sink operator actually provides two closures: one to handle receiving a completion event, and one to handle receiving values.
example(of: "Just") {
    let just = Just("Hello Combine!")
    _ = just
        .sink(receiveCompletion: { completion in
            print("Received completion \(completion)")
        }, receiveValue: { value in
            print("Received value \(value)")
        })
    _ = just
        .sink(receiveCompletion: { completion in
            print("Received completion (another) \(completion)")
        }, receiveValue: { value in
            print("Received value (another) \(value)")
        })
}

example(of: "assign(to:on:)") {
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    let object = SomeObject()
    let publisher = ["Hello", "Combine!"].publisher
    _ = publisher
        .assign(to: \.value, on: object)
}

example(of: "asiign(to:)") {
    class SomeObject {
        @Published var value = 0
    }
    let object = SomeObject()
    object.$value
        .sink { value in
            print(value)
        }
    (0..<6).publisher
        .assign(to: &object.$value)
}

example(of: "Custom Subscriber") {
    let publisher = (1...6).publisher
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value ", input)
            ///            return .unlimited   /// will get all including completion
            ///            return .none   /// receives only 3 values and we dont even receive completion becoz specified a demand of .max(3).
            return .max(1) /// get all 6 value and completion too, because for every time you receive event, you specify that you want to increase the max by 1.
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion ", completion)
        }
    }
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

//example(of: "Future") {
//    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
//        Future<Int, Never> { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//                print("Original")
//                promise(.success(integer + 1))
//            }
//        }
//    }
//    let future = futureIncrement(integer: 1, afterDelay: 3)
//    /// two future publishers get data at same time becoz future executes as soon its created above. It does not require a subscriber like regular publishers.
//    future
//        .sink(receiveCompletion: { print($0) },
//              receiveValue: { print($0) })
//        .store(in: &subscriptions)
//    future
//        .sink(receiveCompletion: { print("Second", $0) },
//              receiveValue: { print("Second", $0) })
//        .store(in: &subscriptions)
//}

example(of: "PassThroughSubject") {
    enum MyError: Error {
        case test
    }
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            return input == "Combine" ? .max(1) : .none
        }
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion", completion)
        }
    }
    let subscriber = StringSubscriber()
    let subject = PassthroughSubject<String, MyError>() /// as publisher now
    subject.subscribe(subscriber) /// it is one type of subscription
    let subscrption = subject    /// it is sink subscription
        .sink { completion in
            print("Received completion (sink)", completion)
        } receiveValue: { value in
            print("Received value (sink)", value)
        }
    subject.send("Hello")
    subject.send("Combine")
    subscrption.cancel()
    subject.send("Still there?")
//    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one?")
}

example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()
    let subject = CurrentValueSubject<Int, Never>(0)
    subject
        .print()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    subject.send(1)
    subject.send(2)
    print(subject.value)
    subject.value = 3
    print(subject.value)
    subject
        .print()
        .sink(receiveValue: { print("Second subscription:", $0) })
        .store(in: &subscriptions)
//    subject.send(completion: .finished)
}

example(of: "Dynamically adjusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            switch input {
            case 1:
                return .max(2) /// The new max is 4 (original max of 2 + new max of 2).
            case 3:
                return .max(1) /// The new max is 5 (previous 4 + new 1).
            default:
                return .none   /// max remains 5 (previous 4 + new 0).
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    let subscriber = IntSubscriber()
    let subject = PassthroughSubject<Int, Never>()
    subject.subscribe(subscriber)
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

example(of: "Type Erasure") {
    let subject = PassthroughSubject<Int, Never>()
    let publisher = subject.eraseToAnyPublisher()
    publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    subject.send(0)
//    publisher.send(1)
}

// Challenge

public typealias Card = (String, Int)
public typealias Hand = [Card]

public extension Hand {
    var cardString: String {
        map { $0.0 }.joined()
    }
    
    var points: Int {
        map { $0.1 }.reduce(0, +)
    }
}

public enum HandError: Error, CustomStringConvertible {
    case busted
    
    public var description: String {
        switch self {
        case .busted:
            return "Busted!"
        }
    }
}

public let cards = [
    ("🂡", 11), ("🂢", 2), ("🂣", 3), ("🂤", 4), ("🂥", 5), ("🂦", 6), ("🂧", 7), ("🂨", 8), ("🂩", 9), ("🂪", 10), ("🂫", 10), ("🂭", 10), ("🂮", 10),
    ("🂱", 11), ("🂲", 2), ("🂳", 3), ("🂴", 4), ("🂵", 5), ("🂶", 6), ("🂷", 7), ("🂸", 8), ("🂹", 9), ("🂺", 10), ("🂻", 10), ("🂽", 10), ("🂾", 10),
    ("🃁", 11), ("🃂", 2), ("🃃", 3), ("🃄", 4), ("🃅", 5), ("🃆", 6), ("🃇", 7), ("🃈", 8), ("🃉", 9), ("🃊", 10), ("🃋", 10), ("🃍", 10), ("🃎", 10),
    ("🃑", 11), ("🃒", 2), ("🃓", 3), ("🃔", 4), ("🃕", 5), ("🃖", 6), ("🃗", 7), ("🃘", 8), ("🃙", 9), ("🃚", 10), ("🃛", 10), ("🃝", 10), ("🃞", 10)
]

example(of: "Create a Blackjack card dealer") {
    let dealtHand = PassthroughSubject<Hand, HandError>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = 52
        var hand = Hand()
        
        for _ in 0 ..< cardCount {
            let randomIndex = Int.random(in: 0 ..< cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        if hand.points > 21 {
            dealtHand.send(completion: .failure(HandError.busted))
        } else {
            dealtHand.send(hand)
        }
        
    }
    
    // Add subscription to dealtHand here
    _ = dealtHand
        .sink { completion in
            switch completion {
            case .finished:
                print("Completion Finished")
            case .failure(let error):
                print("The error", error)
            }
        } receiveValue: { hand in
            print(hand.cardString, hand.points)
        }
    
    deal(3)
}








