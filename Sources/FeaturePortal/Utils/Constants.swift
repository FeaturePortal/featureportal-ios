import Foundation

enum Constants {
    enum API {
        static let baseURL = URL(string: "https://featureportal.com/api/sdk")!
        static let version = "v1"

//        static var baseAPIURL: URL {
//            baseURL.appending(path: version)
//        }

      static var baseAPIURL: URL {
          baseURL
      }
    }
}
