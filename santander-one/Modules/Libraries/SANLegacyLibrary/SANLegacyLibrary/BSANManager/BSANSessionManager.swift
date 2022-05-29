public protocol BSANSessionManager {
    func isDemo() throws -> BSANResponse<Bool>
    func isPB() throws -> BSANResponse<Bool>
    func logout() -> BSANResponse<Void>
    func getUser() throws -> BSANResponse<UserDTO>
    func cleanSessionData() throws
}
