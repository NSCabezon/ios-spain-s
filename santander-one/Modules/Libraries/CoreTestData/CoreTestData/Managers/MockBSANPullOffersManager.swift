import SANLegacyLibrary

struct MockBSANPullOffersManager: BSANPullOffersManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getCampaigns() throws -> BSANResponse<[String]?> {
        let dto = self.mockDataInjector.mockDataProvider.pullOffers.getCampaigns
        return BSANOkResponse(dto)
    }
    
    func loadCampaigns() throws -> BSANResponse<Void> {
        BSANOkEmptyResponse()
    }
}
