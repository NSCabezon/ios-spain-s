import SANLegacyLibrary

struct MockBSANPendingSolicitudesManager: BSANPendingSolicitudesManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getPendingSolicitudes() throws -> BSANResponse<PendingSolicitudeListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.pendingSolicitudes.getPendingSolicitudes
        return BSANOkResponse(dto)
    }
    
    func removePendingSolicitudes() {
        
    }
}
