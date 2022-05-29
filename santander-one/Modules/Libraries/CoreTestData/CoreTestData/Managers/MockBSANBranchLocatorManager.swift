import SANLegacyLibrary

struct MockBSANBranchLocatorManager: BSANBranchLocatorManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getNearATMs(_ input: BranchLocatorATMParameters) throws -> BSANResponse<[BranchLocatorATMDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.branchLocator.getNearATMs
        return BSANOkResponse(dto)
    }
    
    func getEnrichedATM(_ input: BranchLocatorEnrichedATMParameters) throws -> BSANResponse<[BranchLocatorATMEnrichedDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.branchLocator.getEnrichedATM
        return BSANOkResponse(dto)
    }
}
