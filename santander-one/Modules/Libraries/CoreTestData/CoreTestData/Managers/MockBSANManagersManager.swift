import SANLegacyLibrary

struct MockBSANManagersManager: BSANManagersManager {
    func getManagers() throws -> BSANResponse<YourManagersListDTO> {
        fatalError()
    }
    
    func loadManagers() throws -> BSANResponse<YourManagersListDTO> {
        fatalError()
    }
    
    func loadClick2Call() throws -> BSANResponse<Click2CallDTO> {
        fatalError()
    }
    
    func loadClick2Call(_ reason: String?) throws -> BSANResponse<Click2CallDTO> {
        fatalError()
    }
}
