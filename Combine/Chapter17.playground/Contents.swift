import UIKit
import SwiftUI
import Foundation
import Combine
import PlaygroundSupport

///# receiveOn and subscribeOn
//let computationPublisher = Publishers.ExpensiveComputation(duration: 3)
//let queue = DispatchQueue(label: "serial queue")
//let currentThread = Thread.current.number
//print("Start computation publisher on thread \(currentThread)")
//
//let subscription = computationPublisher
//    .subscribe(on: queue) /// the task will happen in some background thread
//    .receive(on: DispatchQueue.main) /// after completion of task, receive values in main thread for UI updates
//    .sink { value in
//        let thread = Thread.current.number
//        print("Received computation result on thread \(thread): '\(value)'")
//    }

///# ImmediateScheduler: schedules the task immediately on the current thread.
//let source = Timer
//    .publish(every: 1.0, on: .main, in: .common)
//    .autoconnect()
//    .scan(0) { counter, _ in
//        counter + 1
//    }
//let setupPublisher = { recorder in
//    source
//        .receive(on: DispatchQueue.global())
//        .recordThread(using: recorder)
//        .receive(on: ImmediateScheduler.shared)
//        .recordThread(using: recorder)
//        .eraseToAnyPublisher()
//}
//let view = ThreadRecorderView(title: "Using ImmediateScheduler", setup: setupPublisher)
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)

///# RunLoop:
//var threadRecorder: ThreadRecorder? = nil
//let setupPublisher = { recorder in
//    source
//        .receive(on: DispatchQueue.global())
//        .handleEvents(receiveSubscription: { _ in 
//            threadRecorder = recorder
//        })
//        .recordThread(using: recorder)
//        .receive(on: RunLoop.current)
//        .recordThread(using: recorder)
//        .eraseToAnyPublisher()
//}
//let view = ThreadRecorderView(title: "Using RunLoop", setup: setupPublisher)
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//                                                        view)
//RunLoop.current.schedule(after: .init(Date(timeIntervalSinceNow: 4.5)), tolerance: .milliseconds(500)) {
//    threadRecorder?.subscription?.cancel()
//}


///# DispatchQueue: Dispatch framework is a powerful component of Foundation that allows you to execute code serially or concurrently on multicore hardware by submitting work to dispatch queues managed by the system.
/// options: it decides qos and priority of task, .userInteractive for user intefaces updates with high priority and .background is less priority task in queue
//let serialQueue = DispatchQueue(label: "Serial queue")
////let sourceQueue = DispatchQueue.main
//let sourceQueue = serialQueue
//let serialQueue2 = DispatchQueue(label: "Second serial queue", target: serialQueue)
//let source = PassthroughSubject<Void, Never>()
//let subscription = sourceQueue.schedule(after: sourceQueue.now, interval: .seconds(1)) {
//    source.send()
//}
//let setupPublisher = { recorder in
//    source
//        .receive(on: serialQueue)
//        .recordThread(using: recorder)
////        .receive(on: serialQueue2)
////        .receive(
////            on: serialQueue,
////            options: DispatchQueue.SchedulerOptions(qos: .userInteractive)
////        )
////        .recordThread(using: recorder)
//        .eraseToAnyPublisher()
//}
//let view = ThreadRecorderView(title: "Using DispatchQueue",
//                              setup: setupPublisher)
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)
/// Challenge 1 - stop the timer using 2 ways
///  First way
//serialQueue.schedule(after: serialQueue.now.advanced(by: .seconds(4))) {
//    subscription.cancel()
//}
/// second way
//serialQueue.asyncAfter(deadline: .now() + 4) {
//    subscription.cancel()
//}


///# Operation Queue: defined as a queue that regulates the execution of operations, it behaves like a concurrent DispatchQueue by default.
//let queue = OperationQueue()
//queue.maxConcurrentOperationCount = 1 /// No concurrent threads so sequentially it receive values without this all values will concurrently received on different threads
//let subscription = (1...10).publisher
//    .receive(on: queue)
//    .sink { value in
//        print("Received \(value) on thread \(Thread.current.number)")
//    }
