import Foundation

public class IllegalStateException: Error {

    var message: String?

    init(_ message: String? = nil) {
        self.message = message
    }

    public var localizedDescription: String {
        return message ?? ""
    }
}
