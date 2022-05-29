

public class OkEmptyResponse: RepositoryResponse<Void> {
    override public func isSuccess() -> Bool {
        return true
    }
    
    override public func getResponseData() throws {
        throw Exception("OkEmptyResponse does not have responseData!")
    }
    
    override public func getErrorCode() throws -> CLong {
         throw Exception("OkEmptyResponse does not have errorCode!")
    }
    
    override public func getErrorMessage() throws -> String {
         throw Exception("OkEmptyResponse does not have errorMessage!")
    }
}
