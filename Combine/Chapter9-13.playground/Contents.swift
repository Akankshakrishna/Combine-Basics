import Combine
import Foundation


///#  Networking
//struct Response<T> {
//    let value: T
//    let response: URLResponse
//}
//
//func run<T: Decodable>(endpoint: NetworkRouter) -> AnyPublisher<Response<T>, NetworkError> {
//    let request = endpoint.urlRequest
//
//    return URLSession.shared
//        .dataTaskPublisher(for: request)
//        .mapError { error -> NetworkError in
//            return NetworkError.networkError(error)
//        }
//        .tryMap { result -> Response<T> in
//            guard let httpResponse = result.response as? HTTPURLResponse else {
//                throw NetworkError.responseError
//            }
//            guard 200...299 ~= httpResponse.statusCode else {
//                throw NetworkError.serverError(httpResponse.statusCode)
//            }
//            let value = try JSONDecoder().decode(T.self, from: result.data)
//            return Response(value: value, response: result.response)
//        }
//        .mapError { error -> NetworkError in
//            NetworkError.errorFromServer(error)
//        }
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
//}

///# Uses of URLSession
/*
 • Data transfer tasks to retrieve the content of a URL.
 • Download tasks to retrieve the content of a URL and save it to a file.
 • Upload tasks to upload files and data to a URL.
 • Stream tasks to stream data between two parties.
 • Websocket tasks to connect to websockets.
 */

//struct MyType: Codable {
//    let id: Int
//}
//
//let url = URL(string: "https://mysite.com/mydata.json")!
//let subscriptionInitial = URLSession.shared
//    .dataTaskPublisher(for: url)
//    .map(\.data)
//    .decode(type: MyType.self, decoder: JSONDecoder())
//    .sink { completion in
//        if case .failure(let err) = completion {
//            print("Retreiving data is failed with error \(err)")
//        }
//    } receiveValue: { object in
//        print("Retrieved object \(object)")
//    }
//
//let publisher = URLSession.shared
//    .dataTaskPublisher(for: url)
//    .map(\.data)
//    .multicast({ PassthroughSubject<Data, URLError>() })
//
//let subscription1 = publisher
//    .sink { completion in
//        if case .failure(let err) = completion {
//            print("Sink1 Retrieving data failed with error \(err)")
//        }
//    } receiveValue: { object in
//        print("Sink1 Retrieved object \(object)")
//    }
//
//let subscription2 = publisher
//    .sink(receiveCompletion: { completion in
//        if case .failure(let err) = completion {
//            print("Sink2 Retrieving data failed with error \(err)")
//        }
//    }, receiveValue: { object in
//        print("Sink2 Retrieved object \(object)")
//    })
//
//let subscription = publisher.connect() /// here the actual request calls and shares the emitted data to both subscribers


///# Debugging - print, handleEvents,
//let subscription = (1...3).publisher
////  .print("publisher")
//  .sink { _ in }
//
//class TimeLogger: TextOutputStream {
//    private var previous = Date()
//    private let formatter = NumberFormatter()
//    init() {
//        formatter.minimumFractionDigits = 5
//        formatter.maximumFractionDigits = 5
//    }
//    func write(_ string: String) {
//        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//        let now = Date()
//        print("+\(String(describing: formatter.string(for: now.timeIntervalSince(previous))))s: \(string)")
//        previous = now
//    }
//}
//let subscription1 = (1...3).publisher
//  .print("publisher", to: TimeLogger())
//  .sink { _ in }
//
//let request = URLSession.shared
//    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)
//let subscription2 = request
//    .handleEvents(receiveSubscription: { _ in
//      print("Network request will start")
//    }, receiveOutput: { _ in
//      print("Network request data received")
//    }, receiveCancel: {
//      print("Network request cancelled")
//    })
//    .sink(receiveCompletion: { completion in
//        print("Sink received completion: \(completion)")
//    }) { (data, _) in
//        print("Sink received data: \(data)")
//    }


///# Timers

/// RunLoop class is not thread-safe. You should only call RunLoop methods for the run loop of the current thread
//let runLoop = RunLoop.main
//let subscription = runLoop.schedule(after: runLoop.now, interval: .seconds(1), tolerance: .milliseconds(100)) {
//    print("Timer fired")
//}

/// on: Which RunLoop your timer attaches to,    in: Which run loop mode(s) the timer runs in
/*
 Running this code on a Dispatch queue other than DispatchQueue.main may lead to unpredictable results. The Dispatch framework manages its threads without using run loops. Since a run loop requires one of its run methods to be called to process events, you would never see the timer fire on any queue other than the main one. Stay safe and target RunLoop.main for your Timers.
 */

//let subscription = Timer
//    .publish(every: 1.0, on: .main, in: .common)
//    .autoconnect()
//    .scan(0) { counter, _ in
//        counter + 1
//    }
//    .sink { counter in
//        print("Counter is \(counter)")
//    }

/// Without Timer class we can generate timer events using DispatchQueue
//let queue = DispatchQueue.main
//let source = PassthroughSubject<Int, Never>()
//var counter = 0
//let cancellable = queue.schedule(after: queue.now, interval: .seconds(1)) {
//    source.send(counter)
//    counter += 1
//}
//
//let subscription = source
//    .sink(receiveValue: { print("Timer emitted \($0)") })


///# Key-Value Observing(KVO)

//let queue = OperationQueue()
//let subscription = queue
//    .publisher(for: \.operationCount)
//    .sink(receiveValue: { print("Outstanding operations in queue: \($0)") })
//
//class TestObject: NSObject {
//    @objc dynamic var integerProperty: Int = 0
//    @objc dynamic var stringProperty: String = ""
//    @objc dynamic var arrayProperty: [Float] = []
////    @objc dynamic var structProperty: PureSwift = .init(a: (0, false))
//}
//
//let obj = TestObject()
//let subscription1 = obj.publisher(for: \.integerProperty, options: [.prior])
//    .sink(receiveValue: { print("integerProperty changes to \($0)") })
//let subscription2 = obj.publisher(for: \.stringProperty)
//  .sink {
//    print("stringProperty changes to \($0)")
//  }
//let subscription3 = obj.publisher(for: \.arrayProperty)
//  .sink {
//    print("arrayProperty changes to \($0)")
//  }
//
//obj.integerProperty = 100
//obj.integerProperty = 200
//obj.stringProperty = "Hello"
//obj.arrayProperty = [1.0]
//obj.stringProperty = "World"
//obj.arrayProperty = [1.0, 2.0]
//
//struct PureSwift {
//    let a: (Int, Bool)
//}

/// The ObservableObject protocol conformance makes the compiler automatically generate the objectWillChange property. It is an ObservableObjectPublisher which emits Void items and Never fails.
//class MonitorObject: ObservableObject {
//    @Published var someProperty = false
//    @Published var someOtherProperty = ""
//}
//let object = MonitorObject()
//let subscription = object.objectWillChange.sink(receiveValue: {
//    print("object will change")
//})
//object.someProperty = true
//object.someOtherProperty = "Hello Combine!"

///# Ressource Management - share(): execute only once at first subscription and shares result to all subscribers(if all subscriptions are executed before task completion)
//let shared = URLSession.shared
//    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
//    .map(\.data)
//    .print("shared")
//    .share()
//print("subscribing first")
//let subscription1 = shared.sink(
//    receiveCompletion: { _ in },
//    receiveValue: { print("subscription1 received: '\($0)'") }
//)
//var subscription2: AnyCancellable? = nil
//print("subscribing second")
//subscription2 = shared.sink(
//  receiveCompletion: { _ in },
//  receiveValue: { print("subscription2 received: '\($0)'") }
//)
/// Uncomment this if you want delay for subscription
//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//  print("subscribing second")
//  subscription2 = shared.sink(
//    receiveCompletion: { print("subscription2 completion \($0)")
//},
//    receiveValue: { print("subscription2 received: '\($0)'") }
//) }

///# Ressource Management - multicast(): won’t subscribe to the upstream publisher until you call its connect(). Such that we can prepare all subscribers and then connect.
//let subject = PassthroughSubject<Data, URLError>()
//let multicasted = URLSession.shared
//    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
//    .map(\.data)
//    .print("shared")
//    .multicast(subject: subject)
//let subscription1 = multicasted
//    .sink(
//        receiveCompletion: { _ in },
//        receiveValue: { print("subscription1 received: '\($0)'") }
//    )
//let subscription2 = multicasted
//  .sink(
//    receiveCompletion: { _ in },
//    receiveValue: { print("subscription2 received: '\($0)'") }
//  )
//multicasted.connect()
//subject.send(Data())

func performSomeWork() throws -> Int {
    return 9
}

///# Ressource Management - Future: It executes when created and emit results to any number of subscribers with stored result
let future = Future<Int, Error> { fulfil in
    do {
        let result = try performSomeWork()
        fulfil(.success(result))
    } catch {
        fulfil(.failure(error))
    }
}

future
    .sink(
      receiveCompletion: { _ in },
      receiveValue: { print("subscription received from future: '\($0)'") }
    )
