public class BSANUnauthorizedException: BSANException {
    public var responseValue: String?

    public init(_ message: String, url: String? = nil, responseValue: String? = nil) {
        super.init(message, url: url)
        self.responseValue = responseValue
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
