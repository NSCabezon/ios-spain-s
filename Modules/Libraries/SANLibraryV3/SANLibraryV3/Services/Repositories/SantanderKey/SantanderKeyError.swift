import Foundation
import CoreFoundationLib

public struct SantanderKeyErrorResponse: Codable, Error {
    public let code: String
    public let descriptions: [String: String]
}

public struct SantanderKeyError: Codable, Error {
    public let httpCode: Int
    public let code: String
    public let descriptions: [String: String]

    public enum SKErrorAction: String, Codable {
        case goToPG // 403
        case goToOperative // 400 + nonBlockingCode
        case stay // 400
    }

    public init(httpCode: Int, code: String, descriptions: [String: String]) {
        self.httpCode = httpCode
        self.code = code
        self.descriptions = descriptions
    }

    public static func genericError() -> SantanderKeyError {
        return SantanderKeyError(
            httpCode: 403,
            code: "",
            descriptions: ["localizedDescription": localized("generic_error_txt")])
    }

    public func getAction() -> SKErrorAction {
        let nonBlockingCodes = [
            "KO6_REG3",
            "KO11_AUTH_1F",
            "KO13_AUTH_2F",
            "KO6_AUTH_2F_2",
            "KO14_AUTH",
            "KO15_AUTH",
            "KO16_AUTH"
        ]

        if httpCode == 400 {
            if !code.isEmpty, nonBlockingCodes.contains(code.uppercased()) {
                return .goToOperative
            }
            return .stay
        }
        return .goToPG
    }

    public func getLocalizedDescription() -> String {
        return (descriptions["localizedDescription"] ?? "")
    }
}
