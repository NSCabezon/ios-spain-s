import Foundation

open class BSANSoapResponse {
    public static let RESULT_OK: String = "0"
    public static let RESULT_ERROR: String = "1"
    public static let RESULT_EMPTY: String = "2"
    public static let RESULT_OTP_EXCEPTED_USER: String = "3"

    public var  exception: Error?
    public var  errorCode: String?
    public var  errorDesc: String?
    public var  response: String?
    public var  fault: Bool = false
    public var  pagination: PaginationDTO? = nil
    // Only for Bizum Services
    public var  codInfo:String?
    
    required public init(response: String){
        self.response = response
    }
    
    
    public func isEmpty() -> Bool {
        if let response = response, response.isEmpty {
            return true
        }
        return false        
    }
}
