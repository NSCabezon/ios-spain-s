class WSUnexpectedCodeException: Error, CustomStringConvertible {
    
    private let message: String?
    let code: Int
    
    init(_ code: Int, _ message: String? = nil) {
        self.code = code
        self.message = message
    }
    
    var description: String {
        return message ?? "\(code)"
    }
}
