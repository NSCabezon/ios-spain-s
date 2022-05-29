class IllegalResponseException: Error, CustomStringConvertible {
    
    private var message: String?
    
    init(_ message: String? = nil) {
        self.message = message
    }
    
    var description: String {
        return message ?? ""
    }
}
