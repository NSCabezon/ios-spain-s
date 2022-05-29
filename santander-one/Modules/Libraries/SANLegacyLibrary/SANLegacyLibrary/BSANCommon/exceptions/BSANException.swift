import Foundation
open class BSANException: LocalizedError, Codable {

    var message: String?
    public var url: String?

    public init(_ message: String, url: String? = nil) {
        self.message = message
        self.url = url
    }

    public var localizedDescription: String {
        return message ?? ""
    }

}


