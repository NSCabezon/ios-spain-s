import Foundation

public class UserInterruptedException: Error {

    var message: String?

    init(_ message: String? = nil) {
        self.message = message
    }

    public var localizedDescription: String {
        return message ?? ""
    }
}
