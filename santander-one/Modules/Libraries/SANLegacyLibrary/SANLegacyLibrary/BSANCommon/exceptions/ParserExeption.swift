import Foundation

public class ParserException: Error {
    var message: String?
    
    public init(_ message: String? = nil) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message ?? ""
    }
}
