public protocol BSANManagersManager {
    func getManagers() throws -> BSANResponse<YourManagersListDTO>
    func loadManagers() throws -> BSANResponse<YourManagersListDTO>
    func loadClick2Call() throws -> BSANResponse<Click2CallDTO>
    func loadClick2Call(_ reason: String?) throws -> BSANResponse<Click2CallDTO>
}
