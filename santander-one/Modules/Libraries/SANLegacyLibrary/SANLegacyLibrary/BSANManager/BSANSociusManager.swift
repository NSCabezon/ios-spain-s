public protocol BSANSociusManager {
    func getSociusAccounts() throws -> BSANResponse<[SociusAccountDTO]>
    func getSociusLiquidation() throws-> BSANResponse<SociusLiquidationDTO>
    func loadSociusDetailAccountsAll() throws -> BSANResponse<SociusAccountDetailDTO>
}
