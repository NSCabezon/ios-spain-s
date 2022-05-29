public class BSANOkEmptyResponse: BSANResponse<Void> {

    override public func isSuccess() -> Bool {
        return true
    }

    override public func getResponseData() throws -> Void {
        throw BSANException("BSANOkEmptyResponse does not have responseData!")
    }

    override public func getErrorCode() throws -> String {
        throw BSANException("BSANOkEmptyResponse does not have errorCode!")
    }

    override public func getErrorMessage() throws -> String {
        throw BSANException("BSANOkEmptyResponse does not have errorMessage!")
    }
}
