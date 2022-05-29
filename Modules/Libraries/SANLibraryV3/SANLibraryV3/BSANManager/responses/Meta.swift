import Foundation

public class Meta {

    var LOG_TAG: String {
        return String(describing: type(of: self))
    }

    public static let CODE_OK = "0";
    public static let CODE_KO = "-1";

    public static func createOk() -> Meta {
        return Meta(CODE_OK)
    }

    public static func createKO() -> Meta {
        return Meta(CODE_KO)
    }

    public static func createKO(_ description: String) -> Meta {
        return Meta(CODE_KO, description)
    }

    public static func createMeta<Params, Handler, Response, Parser>(_ request: BSANSoapRequest<Params, Handler, Response, Parser>, _ response: Response) throws -> Meta {
        return try Meta(request.urlBase, response)
    }

    public var code: String!
    public var description: String?

    private init(_ code: String) {
        self.code = code
    }

    public init(_ code: String, _ description: String) {
        self.code = code
        self.description = description
    }

    init<Response> (_ url: String, _ response: Response?) throws where Response: BSANSoapResponse {
        do {
            try checkException(response)
            if BSANSoapResponse.RESULT_OK == response!.errorCode {
                // OK CODE
                self.code = Meta.CODE_OK
            } else {
                // Soap Fault
                self.code = response!.errorCode!
                self.description = response!.errorDesc
            }
        } catch let error {
            // WS Error
            BSANLogger.e(LOG_TAG, "Meta \(error.localizedDescription)");
            throw BSANServiceException(error.localizedDescription, url: url)
        }
    }

    public func isOK() -> Bool {
        return Meta.CODE_OK == code
    }


    private func checkException(_ result: BSANSoapResponse?) throws {
        if let result = result {
            if let exception = result.exception {
                throw exception
            }
        } else {
            throw Exception("ServiceResult is null!")
        }
    }
}
