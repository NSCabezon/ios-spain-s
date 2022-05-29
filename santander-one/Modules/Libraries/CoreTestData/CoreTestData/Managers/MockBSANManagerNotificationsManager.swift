import SANLegacyLibrary

struct MockBSANManagerNotificationsManager: BSANManagerNotificationsManager {
    func getManagerNotificationsInfo() throws -> BSANResponse<ManagerNotificationsDTO> {
        fatalError()
    }
}
