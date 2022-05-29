import SANLegacyLibrary

public class BSANSessionManagerImplementation: BSANSessionManager {

    private let bsanDataProvider: BSANDataProvider

    public init(bsanDataProvider: BSANDataProvider) {
        self.bsanDataProvider = bsanDataProvider;
    }

    public func isDemo() throws -> BSANResponse<Bool> {
        return BSANOkResponse(bsanDataProvider.isDemo())
    }

    public func isPB() throws -> BSANResponse<Bool> {
        return BSANOkResponse(try bsanDataProvider.isPB())
    }

    public func logout() -> BSANResponse<Void> {
        bsanDataProvider.closeSession()
        return BSANOkEmptyResponse()
    }

    public func getUser() throws -> BSANResponse<UserDTO> {
        return BSANOkResponse(try bsanDataProvider.getUserDTO())
    }
    
    public func cleanSessionData() throws {
        let userDTO = try bsanDataProvider.getUserDTO()
        bsanDataProvider.remove(SessionData.self)
        bsanDataProvider.createSessionData(userDTO)
    }
}
