import CoreFoundationLib
@testable import SanLibraryV3
@testable import SANLegacyLibrary

final class DataRepositoryMock: DataRepository {
    private var sessionData: SessionData
    
    init() {
        sessionData = SessionData(UserDTO(loginType: .N, login: "12345678Z"))
    }
    
    func get<T>(_ type: T.Type) -> T? where T : Decodable, T : Encodable {
        if type is BSANEnvironmentDTO.Type {
            return BSANEnvironmentDTOMock() as? T
        } else if type is SessionData.Type {
            return sessionData as? T
        }
        return nil
    }
    func get<T>(_ type: T.Type, _ dataRepositoryPolicy: DataRepositoryPolicy) -> T? where T : Decodable, T : Encodable { return nil }
    func get<T>(_ type: T.Type, _ key: String) -> T? where T : Decodable, T : Encodable { return nil }
    func get<T>(_ type: T.Type, _ key: String, _ dataRepositoryPolicy: DataRepositoryPolicy) -> T? where T : Decodable, T : Encodable { return nil }
    
    func store<T>(_ t: T) where T : Decodable, T : Encodable {}
    func store<T>(_ t: T, _ dataRepositoryPolicy: DataRepositoryPolicy) where T : Decodable, T : Encodable {}
    func store<T>(_ t: T, _ key: String) where T : Decodable, T : Encodable {}
    func store<T>(_ t: T, _ key: String, _ dataRepositoryPolicy: DataRepositoryPolicy) where T : Decodable, T : Encodable {}
    func remove<T>(_ type: T.Type) {}
    func remove<T>(_ type: T.Type, _ dataRepositoryPolicy: DataRepositoryPolicy) {}
    func remove<T>(_ type: T.Type, _ key: String) {}
    func remove<T>(_ type: T.Type, _ key: String, _ dataRepositoryPolicy: DataRepositoryPolicy) {}
}

final class SanRestServicesMock: SanRestServices {
    private let bundle: Bundle = Bundle(for: SanRestServicesMock.self)
    private var response: String?
    
    init() {}
    
    func configure(withFileName fileName: String?) {
        if let fileName = fileName,
            let url = bundle.path(forResource: fileName, ofType: nil) {
            self.response = try? String(contentsOfFile: url)
        } else {
            self.response = nil
        }
    }
    
    func executeRestCall(request: RestRequest) throws -> Any? {
        return response
    }
}

final class BSANMockErrorResponse<ResponseType>: BSANResponse<ResponseType> {
    override func isSuccess() -> Bool {
        return false
    }
    
    override func getResponseData() throws -> ResponseType? {
        return nil
    }
    
    override func getErrorCode() throws -> String {
        return ""
    }
    
    override func getErrorMessage() throws -> String? {
        return "This is the mocked version for a BSANResponse error."
    }
}

final class BSANEnvironmentDTOMock: BSANEnvironmentDTO {
    init() {
        super.init(
            urlBase: "urlBase",
            isHttps: false,
            name: "name",
            urlNetInsight: "urlNetInsight",
            urlSocius: "urlSocius",
            urlBizumEnrollment: "urlBizumEnrollment",
            urlBizumWeb: "urlBizumWeb",
            urlGetCMC: "urlGetCMC",
            urlGetNewPassword: "urlGetNewPassword",
            urlForgotPassword: "urlForgotPassword",
            urlRestBase: "urlRestBase",
            oauthClientId: "oauthClientId",
            oauthClientSecret: "oauthClientSecret",
            microURL: "microURL",
            click2CallURL: "click2CallURL",
            branchLocatorGlobile: "branchLocatorGlobile",
            insurancesPass2Url: "insurancesPass2Url",
            pass2oauthClientId: "pass2oauthClientId",
            pass2oauthClientSecret: "pass2oauthClientSecret",
            ecommerceUrl: "ecommerceUrl",
            fintechUrl: "fintechUrl"
        )
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
