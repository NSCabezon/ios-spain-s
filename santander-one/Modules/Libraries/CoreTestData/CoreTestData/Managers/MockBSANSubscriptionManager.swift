import SANLegacyLibrary

struct MockBSANSubscriptionManager: BSANSubscriptionManager {
    
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func activate(magicPhrase: String, instaID: String) throws -> BSANResponse<Void> {
        return magicPhrase.isEmpty ? BSANErrorResponse(nil) : BSANOkEmptyResponse()
    }
    
    func deactivate(magicPhrase: String, instaID: String) throws -> BSANResponse<Void> {
        return magicPhrase.isEmpty ? BSANErrorResponse(nil) : BSANOkEmptyResponse()
    }
}
