import SANLegacyLibrary

struct MockBSANPGManager: BSANPGManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func loadGlobalPosition(onlyVisibleProducts: Bool, isPB: Bool) throws -> BSANResponse<GlobalPositionDTO> {
        let dto = self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock
        return BSANOkResponse(dto)
    }
    
    func loadGlobalPositionV2(onlyVisibleProducts: Bool, isPB: Bool) throws -> BSANResponse<GlobalPositionDTO> {
        let dto = self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock
        return BSANOkResponse(dto)
    }
    
    func getGlobalPosition() throws -> BSANResponse<GlobalPositionDTO> {
        let dto = self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock
        return BSANOkResponse(dto)
    }
}
