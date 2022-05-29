import SANLegacyLibrary

struct MockBSANSessionManager: BSANSessionManager {
    
    let mockDataInjector: MockDataInjector
    
    func isDemo() throws -> BSANResponse<Bool> {
        return BSANErrorResponse(nil)
    }
    
    func isPB() throws -> BSANResponse<Bool> {
        return BSANErrorResponse(nil)
    }
    
    func logout() -> BSANResponse<Void> {
        return BSANOkResponse(())
    }
    
    func getUser() throws -> BSANResponse<UserDTO> {
        return BSANOkResponse(UserDTO(loginType: .C, login: ""))
    }
    
    func cleanSessionData() throws {
        
    }
}
