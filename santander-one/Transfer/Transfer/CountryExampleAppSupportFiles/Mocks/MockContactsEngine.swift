import CoreFoundationLib
import CoreTestData
import CoreDomain
import TransferOperatives

public struct MockContactsEngine: ContactsEngineProtocol {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func fetchContacts(_ completion: @escaping (Result<[PayeeRepresentable], ContactsEngineError>) -> Void) {
        let data = self.mockDataInjector.mockDataProvider.transferData.fetchContacts
        completion(.success(data ?? []))
    }
}
