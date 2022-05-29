import CoreFoundationLib

public final class MockLoadingTipsRepository: LoadingTipsRepositoryProtocol {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getLoadingTips() -> LoadingTipsListDTO? {
        return self.mockDataInjector.mockDataProvider.loadingTips.getLoadingTips
    }
}
