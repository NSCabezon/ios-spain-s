import Foundation

open class RepositoryResponse<ResponseType> {
    public init() {
        
    }
    
    open func isSuccess() -> Bool {
        fatalError()
    }
    
    open func getResponseData() throws -> ResponseType? {
        fatalError()
    }
    
    open func getErrorCode() throws -> CLong {
        fatalError()
    }
    
    open func getErrorMessage() throws -> String {
        fatalError()
    }
}
