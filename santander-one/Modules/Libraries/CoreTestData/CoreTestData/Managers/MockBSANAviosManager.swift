import SANLegacyLibrary

struct MockBSANAviosManager: BSANAviosManager {
    
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getAviosDetail() throws -> BSANResponse<AviosDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.gpData.getAviosDetail
        return BSANOkResponse(dto)
    }
}
