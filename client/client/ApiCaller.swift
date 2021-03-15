import Alamofire
import BrightFutures

enum AnyError: String, Error, CaseIterable {
    case serverError
    case emptyDataError
    case parsingError
    case userNotFound
    case forbidden = "Forbidden"
}

struct ServerError: Decodable {
    let error: Bool
    let reason: String
}

extension AnyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError:
            return NSLocalizedString("Server error", comment: "Server error")
        case .emptyDataError:
            return NSLocalizedString("No data in server response", comment: "Empty data error")
        case .parsingError:
            return NSLocalizedString("Could not parse data", comment: "Parsing error")
        case .userNotFound:
            return NSLocalizedString("User not found", comment: "User not found")
        case .forbidden:
            return NSLocalizedString("You do not have rights to complete this operation", comment: "User has no rights")
        }
    }
}

class ApiCaller {
    static private let decoder = JSONDecoder()
    static func makeRequest<T, V>(
        endPoint: String,
        method: HTTPMethod,
        queryParams: [String: String]? = nil,
        bodyParams: V,
        type: T.Type
    ) -> Future<T, Error> where T: Decodable, V: Encodable {
        let promise = Promise<T, Error>()

        let urlString = "http://localhost:8080/\(endPoint)"
        var urlComponents = URLComponents(string: urlString)

        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map {
                element in URLQueryItem(name: element.key, value: element.value)
            }
        }

        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")


        do {
            let jsonData = try JSONEncoder().encode(bodyParams)
            request.httpBody = jsonData
        } catch {
            print(error.localizedDescription)
        }

        AF.request(request).response {
            (response) in

            if let error = response.error {
                promise.failure(error)
                return
            }

            guard let data = response.data else {
                print("No data in response")
                promise.failure(AnyError.emptyDataError)
                return
            }
            do {
                print(String(decoding: data, as: UTF8.self))
                let parsed = try decoder.decode(type, from: data)
                promise.success(parsed)
            }
            catch {
                do {
                    let serverError = try decoder.decode(ServerError.self, from: data)
                    if let error = AnyError.allCases
                        .first(where: { $0.rawValue == serverError.reason }) {
                        promise.failure(error)
                    }
                    else {
                        promise.failure(AnyError.parsingError)
                    }
                } catch {
                    promise.failure(AnyError.parsingError)
                }
            }
        }

        return promise.future
    }

    static func makeRequest<T>(
        endPoint: String,
        method: HTTPMethod,
        queryParams: [String: String]? = nil,
        type: T.Type
    ) -> Future<T, Error> where T: Decodable {
        let promise = Promise<T, Error>()

        let urlString = "http://localhost:8080/\(endPoint)"
        var urlComponents = URLComponents(string: urlString)

        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map {
                element in URLQueryItem(name: element.key, value: element.value)
            }
        }

        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        AF.request(request).response {
            (response) in

            if let error = response.error {
                promise.failure(error)
                return
            }

            guard let data = response.data else {
                print("No data in response")
                promise.failure(AnyError.emptyDataError)
                return
            }
            do {
                print(String(decoding: data, as: UTF8.self))
                let parsed = try JSONDecoder().decode(type, from: data)
                promise.success(parsed)
            }
            catch {
                do {
                    let serverError = try decoder.decode(ServerError.self, from: data)
                    if let error = AnyError.allCases
                        .first(where: { $0.rawValue == serverError.reason }) {
                        promise.failure(error)
                    }
                    else {
                        promise.failure(AnyError.parsingError)
                    }
                } catch {
                    promise.failure(AnyError.parsingError)
                }
            }
        }

        return promise.future
    }
}
