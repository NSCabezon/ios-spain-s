import CoreFoundationLib

public struct MockSepaInfoRepository: SepaInfoRepositoryProtocol {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getSepaList() -> SepaInfoListDTO? {
        let dto = self.mockDataInjector.mockDataProvider.sepaInfo.getSepaList
        return dto
    }
}
