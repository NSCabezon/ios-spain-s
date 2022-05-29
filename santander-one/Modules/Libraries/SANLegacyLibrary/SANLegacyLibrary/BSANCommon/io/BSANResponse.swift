import Foundation

open class BSANResponse<ResponseType> {
    
    public init() {}
    
    open func isSuccess() -> Bool {
        fatalError()
    }

    open func getResponseData() throws -> ResponseType? {
        fatalError()
    }

    open func getErrorCode() throws -> String {
        fatalError()
    }

    open func getErrorMessage() throws -> String? {
        fatalError()
    }
}
