public protocol BSANManagerNotificationsManager {
    func getManagerNotificationsInfo() throws -> BSANResponse<ManagerNotificationsDTO>
}
