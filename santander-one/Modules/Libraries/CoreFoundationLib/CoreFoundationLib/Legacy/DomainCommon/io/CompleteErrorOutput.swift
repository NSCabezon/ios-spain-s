open class CompleteErrorOutput: StringErrorOutput {

    private let errorCode: Int?
    private let errorRaw: String
    
    public init(_ errorDesc: String? = nil, errorCode: Int? = nil, errorRaw: String = "") {
        self.errorCode = errorCode
        self.errorRaw = errorRaw
        super.init(errorDesc)
    }
    
    public func getErrorCode() -> Int? {
        return errorCode
    }
    
    public func getErrorRaw() -> String? {
        return errorRaw
    }
}

