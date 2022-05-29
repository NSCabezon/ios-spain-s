import SANLegacyLibrary

public struct MockBSANPredefineSCAManager: BSANPredefineSCAManager {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getCardOnOffPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(self.mockDataInjector.mockDataProvider.predefineSCA.predefinedSCARepresentable)
    }
    
    public func getInternalTransferPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(self.mockDataInjector.mockDataProvider.predefineSCA.predefinedSCARepresentable)
    }
    
    public func getOnePayTransferPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(self.mockDataInjector.mockDataProvider.predefineSCA.predefinedSCARepresentable)
    }
    
    public func getCVVQueryPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(self.mockDataInjector.mockDataProvider.predefineSCA.predefinedSCARepresentable)
    }
    
    public func getCardBlockPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(self.mockDataInjector.mockDataProvider.predefineSCA.predefinedSCARepresentable)
    }
}
