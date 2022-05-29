import Foundation

public class BSANOkResponse<ResponseType>: BSANResponse<ResponseType> {

    private let data: ResponseType?
    private let meta: Meta

    public init(_ data: ResponseType?) {
        self.meta = Meta.createOk()
        self.data = data
    }

    public init(_ meta: Meta) {
        self.data = nil
        self.meta = meta
    }

    public init(_ meta: Meta, _ responseType: ResponseType?) {
        self.data = responseType
        self.meta = meta
    }

    override public func isSuccess() -> Bool {
        return Meta.CODE_OK == meta.code
    }

    override public func getResponseData() throws -> ResponseType? {
        return data
    }

    override public func getErrorCode() throws -> String {
        return meta.code
    }

    override public func getErrorMessage() throws -> String? {
        return meta.description
    }


}
