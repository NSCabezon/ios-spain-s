import SANLegacyLibrary

struct MockBSANSendMoneyManager: BSANSendMoneyManager {
    
    let mockDataInjector: MockDataInjector
    
    func getCMPSStatus() throws -> BSANResponse<CMPSDTO> {
        fatalError()
    }
    
    func loadCMPSStatus() throws -> BSANResponse<CMPSDTO> {
        fatalError()
    }
}
