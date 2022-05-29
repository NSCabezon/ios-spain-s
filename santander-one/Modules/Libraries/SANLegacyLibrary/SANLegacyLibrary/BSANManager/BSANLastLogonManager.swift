public protocol BSANLastLogonManager {
    func getLastLogonInfo() throws -> BSANResponse<LastLogonDTO>
    func insertDateUpdate() throws -> BSANResponse<Void>
}
