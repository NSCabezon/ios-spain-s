import Foundation

struct FintechConfirmationError: Codable {
    let code: String
    let description: [FintechConfirmationSpecificError]
}

struct FintechConfirmationSpecificError: Codable {
    let language: String
    let value: String
}
