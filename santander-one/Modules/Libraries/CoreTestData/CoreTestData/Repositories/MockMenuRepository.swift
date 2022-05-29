import CoreDomain
import OpenCombine

public class MockMenuRepository: MenuRepository {
    public static let current = MockMenuRepository()
    private var personalManagerSubject = CurrentValueSubject<[PersonalManagerRepresentable], Never>([TestingPersonalManagerData]())
    private var soapTokenCredentialSubject = CurrentValueSubject<String, Never>("tokenTest")

    public init() {}

    public func fetchPersonalManager() -> AnyPublisher<[PersonalManagerRepresentable], Never> {
        return personalManagerSubject.eraseToAnyPublisher()
    }
    
    public func send(_ personalManager: [PersonalManagerRepresentable]) {
        personalManagerSubject.send(personalManager)
    }

    public func fetchSoapTokenCredential() -> AnyPublisher<String, Never> {
        return soapTokenCredentialSubject.eraseToAnyPublisher()
    }

    public func send(_ soapTokenCredential: String) {
        soapTokenCredentialSubject.send(soapTokenCredential)
    }
}

private extension MockMenuRepository {
    struct TestingPersonalManagerData: PersonalManagerRepresentable {        
        let codGest: String? = "codGest"
        let nameGest: String? = "nameGest"
        let category: String? = "category"
        let portfolio: String? = "portfolio"
        let desTipCater: String? = "desTipCater"
        let phone: String? = "123"
        let email: String? = "email@email.com"
        let indPriority: Int? = 1
        let portfolioType: String? = "portfolioType"
        var thumbnailData: Data? = nil
    }
}
