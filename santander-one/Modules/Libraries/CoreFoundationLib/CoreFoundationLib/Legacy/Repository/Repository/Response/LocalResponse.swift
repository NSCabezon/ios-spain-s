

public class LocalResponse<ResponseType>: RepositoryResponse<ResponseType> {
    private let data: ResponseType?
    
    public init(_ data: ResponseType?) {
        self.data = data
        super.init()
    }
    
    public override func isSuccess() -> Bool {
        return true
    }
    
    public override func getResponseData() throws -> ResponseType? {
        return data
    }
    
    public override func getErrorCode() throws -> CLong {
        throw Exception("LocalResponse does not have errorCode!")
    }
    
    public override func getErrorMessage() throws -> String {
        throw Exception("LocalResponse does not have errorMessage!")
    }
}
