public struct InfoDTO: Codable {
    public var errorCode: String?
    public var errorDesc: String?
    public var fault = false
    // Only for Bizum services
    public var codInfo: String?
    public var exception: BSANUnauthorizedException?

    public mutating func setErrorCode(errorCode: String) -> InfoDTO {
        self.errorCode = errorCode
        return self
    }

    public mutating func setErrorDesc(errorDesc: String) -> InfoDTO {
        self.errorDesc = errorDesc
        return self
    }

    public mutating func setFault(fault: Bool) -> InfoDTO {
        self.fault = fault
        return self
    }

    public mutating func setCodInfo(codInfo: String) -> InfoDTO {
        self.codInfo = codInfo
        return self
    }
    
    public func checkException() throws{
        if let exception = exception {
            throw exception
        }
    }

}
