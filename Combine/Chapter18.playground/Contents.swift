import UIKit
import Foundation
import Combine

//extension Publisher {
//    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
//        compactMap({ $0 })
//    }
//}
//let values: [Int?] = [1, 2, nil, 3, nil, 4]
//values.publisher
//    .unwrap()
//    .sink(receiveValue: { print("Received value \($0)")
//    })

//struct DispatchTimerConfiguration {
//    let queue: DispatchQueue?
//    let interval: DispatchTimeInterval
//    let leeway: DispatchTimeInterval
//    let times: Subscribers.Demand
//}
//private final class DispatchTimerSubscription <S: Subscriber>: Subscription where S.Input == DispatchTime {
//    let configuration: DispatchTimerConfiguration
//    var times: Subscribers.Demand
//    var requested: Subscribers.Demand = .none
//    var source: DispatchSourceTimer? = nil
//    var subscriber: S?
//    init(subscriber: S, configuration: DispatchTimerConfiguration) {
//        self.configuration = configuration
//        self.times = configuration.times
//        self.subscriber = subscriber
//    }
//    func request(_ demand: Subscribers.Demand) {
//        guard times > .none else {
//            subscriber?.receive(completion: .finished)
//            return
//        }
//        requested += demand
//        if source == nil, requested > .none {
//            let source = DispatchSource.makeTimerSource(queue: configuration.queue)
//            source.schedule(deadline: .now() + configuration.interval,
//                            repeating: configuration.interval,
//                            leeway: configuration.leeway)
//            source.setEventHandler{ [weak self] in
//                guard let self = self, self.requested > .none else {
//                    return
//                }
//                self.requested -= .max(1)
//                self.times -= .max(1)
//                _ = self.subscriber?.receive(.now())
//                if self.times == .none {
//                    self.subscriber?.receive(completion: .finished)
//                }
//            }
//            self.source = source
//            source.activate()
//        }
//    }
//    
//    func cancel() {
//        source = nil
//        subscriber = nil
//    }
//}
//
//extension Publishers {
//    static func timer(queue: DispatchQueue? = nil,
//                      interval: DispatchTimeInterval,
//                      leeway: DispatchTimeInterval = .nanoseconds(0),
//                      times: Subscribers.Demand = .unlimited) -> Publishers.DispatchTimer {
//        return Publishers.DispatchTimer(configuration: .init(queue: queue, interval: interval, leeway: leeway, times: times))
//    }
//}
//
//extension Publishers {
//    struct DispatchTimer: Publisher {
//        typealias Output = DispatchTime
//        typealias Failure = Never
//        let configuration: DispatchTimerConfiguration
//        init(configuration: DispatchTimerConfiguration) {
//            self.configuration = configuration
//        }
//        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, DispatchTime == S.Input {
//            
//        }
//    }
//}
//
//var logger = TimeLogger(sinceOrigin: true)
//let publisher = Publishers.timer(interval: .seconds(1), times: .max(6))
//let subscription = publisher.sink { time in
//    print("Timer emits: \(time)", to: &logger)
//}


///# implementing a shareReplay operator
//fileprivate final class ShareReplaySubscription<Output, Failure: Error>: Subscription {
//    let capacity: Int
//    var subscriber: AnySubscriber<Output, Failure>? = nil
//    var demand: Subscribers.Demand = .none
//    var buffer: [Output]
//    var completion: Subscribers.Completion<Failure>? = nil
//    init<S>(subscriber: S, replay: [Output], capacity: Int,
//            completion: Subscribers.Completion<Failure>?)
//    where S: Subscriber, Failure == S.Failure, Output == S.Input {
//        self.subscriber = AnySubscriber(subscriber)
//        self.buffer = replay
//        self.capacity = capacity
//        self.completion = completion
//    }
//    private func complete(with completion: Subscribers.Completion<Failure>) {
//        guard let subscriber = subscriber else { return }
//        self.subscriber = nil
//        self.completion = nil
//        self.buffer.removeAll()
//        subscriber.receive(completion: completion)
//    }
//    private func emitAsNeeded() {
//        guard let subscriber = subscriber else { return }
//        while self.demand > .none && !buffer.isEmpty {
//            self.demand -= .max(1)
//            let nextDemand = subscriber.receive(buffer.removeFirst())
//            if nextDemand != .none {
//                self.demand += nextDemand
//            }
//        }
//        if let completion = completion {
//            complete(with: completion)
//        }
//    }
//    func request(_ demand: Subscribers.Demand) {
//        if demand != .none {
//            self.demand += demand
//        }
//        emitAsNeeded()
//    }
//    func receive(completion: Subscribers.Completion<Failure>) {
//        guard let subscriber = subscriber else { return }
//        self.subscriber = nil
//        self.buffer.removeAll()
//        subscriber.receive(completion: completion)
//    }
//    func cancel() {
//        
//    }
//}
//extension Publishers {
//    final class ShareReplay<Upstream: Publisher>: Publisher {
//        private let lock = NSRecursiveLock()
//        private let upstream: Upstream
//        private let capacity: Int = 0
//        private let replay = [Output]()
//        private var subscriptions = [ShareReplaySubscription<Output, Failure>]()
//        private var completion: Subscribers.Completion<Failure>? = nil
//        func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
//            
//        }
//        
//        typealias Output = Upstream.Output
//        typealias Failure = Upstream.Failure
//    }
//}

protocol Pausable {
    var paused: Bool { get }
    func resume()
}

///#BackPressure: The resistance opposing the desired flow of values coming from a publisher
///# To handle backpressure we use this PausableSubscriber
final class PausableSubsriber<Input, Failure: Error>: Subscriber, Pausable, Cancellable {
    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.max(1))
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        paused = receiveValue(input) == false
        return paused ? .none : .max(1)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
        subscription = nil
    }
    
    func resume() {
        guard paused else { return }
        paused = false
        subscription?.request(.max(1))
    }
    
    let combineIdentifier = CombineIdentifier()
    let receiveValue: (Input) -> Bool
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    private var subscription: Subscription? = nil
    var paused: Bool = false
    init(receiveValue: @escaping (Input) -> Bool,
         receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }
    func cancel() {
        subscription?.cancel()
        subscription = nil
    }
}

extension Publisher {
    func pausableSink(
        receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void),
        receiveValue: @escaping ((Output) -> Bool)
    ) -> Pausable & Cancellable {
        let pausable = PausableSubsriber(
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion)
        self.subscribe(pausable)
        return pausable
    }
}

let susbscription = [1, 2, 3, 4, 5, 6]
    .publisher
    .pausableSink { completion in
        print("Pausable subscription completed: \(completion)")
    } receiveValue: { value -> Bool in
        print("Receive value: \(value)")
        if value % 2 == 1 {
            print("Pausing")
            return false
        }
        return true
    }

let timer = Timer.publish(every: 3, on: .main, in: .common)
    .autoconnect()
    .sink { _ in
        guard susbscription.paused else { return }
        print("Subscription is paused, resuming")
        susbscription.resume()
    }

