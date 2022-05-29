import SANLegacyLibrary

struct MockBSANRecoveryNoticesManager: BSANRecoveryNoticesManager {
    
    private let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getRecoveryNotices() throws -> BSANResponse<[RecoveryDTO]> {
        let dto = mockDataInjector.mockDataProvider.recoveryNoticiesData.getRecoveryNoticesMock
        return BSANOkResponse(dto)
    }
}
