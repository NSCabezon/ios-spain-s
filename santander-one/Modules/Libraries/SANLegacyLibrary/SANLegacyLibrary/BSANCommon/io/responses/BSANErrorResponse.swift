import Foundation

public class BSANErrorResponse<ResponseType>: BSANOkResponse<ResponseType> {


    override public func isSuccess() -> Bool {
        return false
    }

    override public func getResponseData() throws -> ResponseType {
        throw BSANException("BSANErrorResponse does not have response data!")
    }
}

