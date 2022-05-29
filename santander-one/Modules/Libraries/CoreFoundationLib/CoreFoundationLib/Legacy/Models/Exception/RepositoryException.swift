public class RepositoryException: Error, CustomStringConvertible {
    
    private var message: String?
    
    public init(_ message: String? = nil) {
        self.message = message
    }
    
    public var description: String {
        return message ?? ""
    }
}
