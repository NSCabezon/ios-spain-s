import SANLegacyLibrary

struct MockBSANLastLogonManager: BSANLastLogonManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getLastLogonInfo() throws -> BSANResponse<LastLogonDTO> {
        let dto = mockDataInjector.mockDataProvider.lastLoginData.getLastLogonInfoMock
        return BSANOkResponse(dto)
    }
    
    func insertDateUpdate() throws -> BSANResponse<Void> {
        fatalError()
    }
}
