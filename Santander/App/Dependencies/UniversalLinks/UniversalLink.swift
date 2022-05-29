import Foundation

enum UniversalLinkError: Error {
    case notFound
}

enum UniversalLink {
    case fintech(info: FintechUserAuthenticationKeys)
}

extension UniversalLink {
    init?(_ string: String, userInfo: [String: String?]) throws {
        switch string {
        case "/psd2LoginAppPart":
            self = .fintech(info: try userInfo.generate(userInfo: userInfo))
        default:
            throw UniversalLinkError.notFound
        }
    }
}

private extension Dictionary {
    func generate<T: Codable> (userInfo: [String: String?]) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let response = try JSONDecoder().decode(T.self, from: jsonData)
        return response
    }
}
