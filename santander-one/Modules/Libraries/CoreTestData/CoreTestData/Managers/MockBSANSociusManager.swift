import SANLegacyLibrary

struct MockBSANSociusManager: BSANSociusManager {
    func getSociusAccounts() throws -> BSANResponse<[SociusAccountDTO]> {
        fatalError()
    }
    
    func getSociusLiquidation() throws -> BSANResponse<SociusLiquidationDTO> {
        fatalError()
    }
    
    func loadSociusDetailAccountsAll() throws -> BSANResponse<SociusAccountDetailDTO> {
        fatalError()
    }
}
