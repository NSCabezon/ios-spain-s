import CoreFoundationLib

final public class MockComingFeaturesRepository: ComingFeaturesRepositoryProtocol {
    
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func load(baseUrl: String, publicLanguage: PublicLanguage) {
    }
    
    public func getFeatures() -> ComingFeatureListDTO? {
        return self.mockDataInjector.mockDataProvider.comingFeatures.getFeatures
    }
}
