import CoreFoundationLib

public class MockTricksRepository: TricksRepositoryProtocol {
    
    let mockDataInjector: MockDataInjector
    private var dto: FaqsListDTO?
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getTricks() -> TrickListDTO? {
        return self.mockDataInjector.mockDataProvider.tricks.getTricks
    }
    
    public func loadTricks(with baseUrl: String, publicLanguage: PublicLanguage) {
        
    }
    
}
