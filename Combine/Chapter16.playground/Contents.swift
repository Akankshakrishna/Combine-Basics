import Combine
import Foundation
import UIKit

var subscriptions = Set<AnyCancellable>()
public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}

///# Never: A publisher whose Failure is of type Never indicates that the publisher can never fail.
example(of: "Never sink") {
    Just("Hello")
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

enum MyError: Error {
    case ohNo
}

/// It is used to setFailure type as desired error and applied on publishers which has Never as Failure type
example(of: "setFailureType") {
    Just("Hello")
        .setFailureType(to: MyError.self)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(.ohNo):
                    print("Finished with Oh No!")
                case .finished:
                    print("Finished successfully!")
                }
            },
            receiveValue: { value in
                print("Got value: \(value)")
            }
        )
        .store(in: &subscriptions)
}

///# its also works for Never Failure type publishers only
example(of: "assign") {
    class Person {
        let id = UUID()
        var name = "Unknown"
    }
    let person = Person()
    print("1", person.name)
    Just("Shai")
//        .setFailureType(to: Error.self)
        .handleEvents(receiveCompletion: { _ in
            print("2", person.name)
        })
        .assign(to: \.name, on: person)
        .store(in: &subscriptions)
}

example(of: "assertNoFailure") {
    Just("Hello")
        .setFailureType(to: MyError.self)
//        .tryMap({ _ in
//            throw MyError.ohNo
//        })
        .assertNoFailure()
        .sink(receiveValue: { print("Got value: \($0) ")})
        .store(in: &subscriptions)
}

example(of: "tryMap") {
    enum NameError: Error {
        case tooShort(String)
        case unknown
    }
    let names = ["Scott", "Marin", "Shai", "Florent"].publisher
    names
        .tryMap { value -> Int in
            let length = value.count
            guard length >= 5 else {
                throw NameError.tooShort(value)
            }
            return value.count
        }
        .sink(receiveCompletion: { print("Completed with \($0)") },
              receiveValue: { print("Got value: \($0)")
        })
}

example(of: "map vs tryMap") {
    enum NameError: Error {
        case tooShort(String)
        case unknown
    }
    Just("Hello")
        .setFailureType(to: NameError.self)
        .tryMap { throw NameError.tooShort($0) }
        .mapError({ $0 as? NameError ?? .unknown})
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Done!")
                case .failure(.tooShort(let name)):
                    print("\(name) is too short!")
                case .failure(.unknown):
                    print("An unknown name error occurred")
                }
            },
            receiveValue: { print("Got value \($0)") }
        )
        .store(in: &subscriptions)
}

//example(of: "Joke API") {
//    class DadJokes {
//        struct Joke: Codable {
//            let id: String
//            let joke: String
//        }
//        enum Error: Swift.Error, CustomStringConvertible {
//            var description: String {
//                switch self {
//                case .network:
//                    return "Request to API Server failed"
//                case .parsing:
//                    return "Failed parsing response from server"
//                case .jokeDoesntExist(let id):
//                    return "Joke with ID \(id) doesn't exist"
//                case .unknown:
//                    return "An unknown error occurred"
//                }
//            }
//            
//            case network
//            case jokeDoesntExist(id: String)
//            case parsing
//            case unknown
//        }
//        func getJoke(id: String) -> AnyPublisher<Joke, Error> {
//            guard id.rangeOfCharacter(from: .letters) != nil else {
//                return Fail<Joke, Error>(error: .jokeDoesntExist(id: id))
//                    .eraseToAnyPublisher()
//            }
//            let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
//            var request = URLRequest(url: url)
//            request.allHTTPHeaderFields = ["Accept": "application/json"]
//            return URLSession.shared
//                .dataTaskPublisher(for: request)
//                .tryMap({ (data, _) -> Data in
//                    guard let obj = try? JSONSerialization.jsonObject(with: data),
//                          let dict = obj as? [String: Any],
//                          dict["status"] as? Int == 404 else {
//                        return data
//                    }
//                    throw DadJokes.Error.jokeDoesntExist(id: id)
//                })
//                .decode(type: Joke.self, decoder: JSONDecoder())
//                .mapError({ error -> DadJokes.Error in
//                    switch error {
//                    case is URLError:
//                        return .network
//                    case is DecodingError:
//                        return .parsing
//                    default:
//                        return error as? DadJokes.Error ?? .unknown
//                    }
//                })
//                .eraseToAnyPublisher()
//        }
//    }
//    let api = DadJokes()
//    let jokeID = "9prWnjyImyd"
//    let badJokeID = "j4r8jd8e33"
//    api
//        .getJoke(id: jokeID)
//        .sink(receiveCompletion: { print($0) },
//              receiveValue: { print("Got joke: \($0)") })
//        .store(in: &subscriptions)
//    
//}


let photoService = PhotoService()

example(of: "Catching and retrying") {
    photoService
        .fetchPhoto(quality: .high)
        .handleEvents(
            receiveSubscription: { _ in print("Trying ...") },
            receiveCompletion: {
                guard case .failure(let error) = $0 else { return }
                print("Got error: \(error)")
            }
        )
        .retry(3)
        .catch({ error in
            print("Failed fetching high quality, falling back to low quality")
            return photoService.fetchPhoto(quality: .low)
        })
        .replaceError(with: UIImage(named: "na.jpg")!)
        .sink(receiveCompletion: { print("\($0)") }) { image in
            image
            print("Got image \(image)")
        }
        .store(in: &subscriptions)
}

