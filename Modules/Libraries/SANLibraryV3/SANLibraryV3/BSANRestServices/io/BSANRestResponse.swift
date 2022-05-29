import Foundation

public class BSANRestResponse<T> {
    
//    static let RESULT_OK: String = "0"
//    static let RESULT_ERROR: String = "1"
//    static let RESULT_EMPTY: String = "2"
    
    var  exception: Error?
    var  errorCode: String?
    var  errorDesc: String?
    var  response: T
    var  fault: Bool = false
    var  pagination: PaginationDTO? = nil
    // Only for Bizum Services
    var  codInfo:String?
    
    required public init(response: T){
        self.response = response
    }
    
    
//    func isEmpty() -> Bool {
//        if (response == nil) {
//            return true
//        }
//        return false
//    }
}
