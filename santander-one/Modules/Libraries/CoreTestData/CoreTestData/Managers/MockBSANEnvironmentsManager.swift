import SANLegacyLibrary

struct MockBSANEnvironmentsManager: BSANEnvironmentsManager {
    func getEnvironments() -> BSANResponse<[BSANEnvironmentDTO]> {
        fatalError()
    }
    
    func getCurrentEnvironment() -> BSANResponse<BSANEnvironmentDTO> {
        fatalError()
    }
    
    func setEnvironment(bsanEnvironment: BSANEnvironmentDTO) -> BSANResponse<Void> {
        fatalError()
    }
    
    func setEnvironment(bsanEnvironmentName: String) -> BSANResponse<Void> {
        fatalError()
    }
}
