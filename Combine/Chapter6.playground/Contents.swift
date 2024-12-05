import UIKit
import Combine
import Foundation
import SwiftUI
import PlaygroundSupport

public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}
var subscriptions = Set<AnyCancellable>()

/// Shifting Time
//let valuePerSecond = 1.0
//let delayInSeconds = 1.5
//
//let sourcePublisher = PassthroughSubject<Date, Never>()
//let delayedPublisher = sourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)
//let subscription = Timer
//    .publish(every: 1.0 / valuePerSecond, on: .main, in: .common)
//    .autoconnect()
//    .subscribe(sourcePublisher)
//
//let sourceTimeline = TimelineView(title: "Emitted values (\(valuePerSecond) per sec.):")
//let delayedTimeline = TimelineView(title: "Delayed values (\(delayInSeconds)s delay):")
//let view = VStack(spacing: 50) {
//  sourceTimeline
//  delayedTimeline
//}
//// 7
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)
//
//sourcePublisher.displayEvents(in: sourceTimeline)
//delayedPublisher.displayEvents(in: delayedTimeline)


/// Collecting Values
//let valuesPerSecond = 1.0
//let collectTimeStride = 4
//let collectMaxCount = 2
//
//let sourcePublisher = PassthroughSubject<Date, Never>()
//
//let collectedPublisher = sourcePublisher
//  .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
//  .flatMap { dates in dates.publisher }
//let collectedPublisher2 = sourcePublisher
//    .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
//    .flatMap { dates in dates.publisher }
//let subscription = Timer
//  .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
//  .autoconnect()
//  .subscribe(sourcePublisher)
//
//let sourceTimeline = TimelineView(title: "Emitted values:")
//let collectedTimeline = TimelineView(title: "Collected values (every \(collectTimeStride)s):")
//let collectedTimeline2 = TimelineView(title: "Collected values (at most \(collectMaxCount) every \(collectTimeStride)s):")
//let view = VStack(spacing: 40) {
//    sourceTimeline
//    collectedTimeline
//    collectedTimeline2
//}
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)
//
//sourcePublisher.displayEvents(in: sourceTimeline)
//collectedPublisher.displayEvents(in: collectedTimeline)
//collectedPublisher2.displayEvents(in: collectedTimeline2)

///# Holding off an events
/// Debounce - waits for 1 sec (scenario: you need to send search request using text field text while typing. So for every letter we cant send search request. So when there is a pause in typing (emitting) we can send the search request.)
//let subject = PassthroughSubject<String, Never>()
//let debounced = subject
//    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
//    .share()
//
//let subjectTimeline = TimelineView(title: "Emitted values")
//let debouncedTimeline = TimelineView(title: "Debounced values")
//let view = VStack(spacing: 100) {
//    subjectTimeline
//    debouncedTimeline
//}
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)
//subject.displayEvents(in: subjectTimeline)
//debounced.displayEvents(in: debouncedTimeline)
//let subscription1 = subject
//    .sink { string in
//        print("+\(deltaTime)s: Subject emitted: \(string)")
//    }
//let subscription2 = debounced
//    .sink { string in
//        print("+\(deltaTime)s: Debounced emitted: \(string)")
//    }
//subject.feed(with: typingHelloWorld)


///Throttle - similar to debounse
/*
 Differences between debounce and throttle
 • debounce waits for a pause in values it receives, then emits the latest one after the specified interval.(based on latest)
 • throttle waits for the specified interval, then emits either the first or the latest of the values it received during that interval. It doesn’t care about pauses.
 */
//let throttleDelay = 1.0
//let subject = PassthroughSubject<String, Never>()
//let throttled = subject
//    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: true)
//    .share()
//let subjectTimeline = TimelineView(title: "Emitted values")
//let throttledTimeline = TimelineView(title: "Throttled values")
//let view = VStack(spacing: 100) {
//  subjectTimeline
//  throttledTimeline
//}
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)
//subject.displayEvents(in: subjectTimeline)
//throttled.displayEvents(in: throttledTimeline)
//let subscription1 = subject
//    .sink { string in
//        print("+\(deltaTime)s: Subject emitted: \(string)")
//    }
//let subscription2 = throttled
//    .sink { string in
//        print("+\(deltaTime)s: Throttled emitted: \(string)")
//    }
//subject.feed(with: typingHelloWorld)


/// Timeout
//enum TimeoutError: Error {
//  case timedOut
//}
//let subject = PassthroughSubject<Void, TimeoutError>()
//let timedOutSubject = subject.timeout(.seconds(5), scheduler: DispatchQueue.main, customError: {TimeoutError.timedOut})
//let timeline = TimelineView(title: "Button taps")
//let view = VStack(spacing: 100) {
//    Button {
//        subject.send()
//    } label: {
//        Text("Press me within 5 seconds")
//    }
//    timeline
//}
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)
//timedOutSubject.displayEvents(in: timeline)


/// Measuring Time
//let subject = PassthroughSubject<String, Never>()
//let measureSubject = subject.measureInterval(using: DispatchQueue.main)
//let measureSubject2 = subject.measureInterval(using: RunLoop.main)
//let subjectTimeline = TimelineView(title: "Emitted values")
//let measureTimeline = TimelineView(title: "Measured values")
//let view = VStack(spacing: 100) {
//  subjectTimeline
//  measureTimeline
//}
//PlaygroundPage.current.liveView = UIHostingController(rootView:
//view)
//subject.displayEvents(in: subjectTimeline)
//measureSubject.displayEvents(in: measureTimeline)
//let subscription1 = subject.sink {
//  print("+\(deltaTime)s: Subject emitted: \($0)")
//}
//let subscription2 = measureSubject.sink {
//  print("+\(deltaTime)s: Measure emitted: \(Double($0.magnitude) / 1_000_000_000.0)")
//}
//let subscription3 = measureSubject2.sink {
//  print("+\(deltaTime)s: Measure2 emitted: \($0)")
//}
//subject.feed(with: typingHelloWorld)


// Challenge

// sample data!
let samples: [(TimeInterval, Int)] = [
  (0.05, 67), (0.10, 111), (0.15, 109), (0.20, 98), (0.25, 105), (0.30, 110), (0.35, 101),
  (1.50, 105), (1.55, 115),
  (2.60, 99), (2.65, 111), (2.70, 111), (2.75, 108), (2.80, 33)
]

public func startFeeding<S>(subject: S) where S: Subject, S.Output == Int {
  var lastDelay: TimeInterval = 0
  for entry in samples {
    lastDelay = entry.0
    DispatchQueue.main.asyncAfter(deadline: .now() + entry.0) {
      subject.send(entry.1)
    }
  }
  DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay + 0.5) {
    subject.send(completion: .finished)
  }
}

// A subject you get values from
let subject = PassthroughSubject<Int, Never>()

let strings = subject
    .collect(.byTime(DispatchQueue.main, .seconds(0.5)))
    .map { array in
        String(array.map { Character(Unicode.Scalar($0)!) })
    }
let spaces = subject.measureInterval(using: DispatchQueue.main)
    .map { interval in
        interval>0.9 ? "👏": ""
    }
let subscription = strings
    .merge(with: spaces)
    .filter({ !$0.isEmpty })
    .sink { print($0) }

startFeeding(subject: subject)
