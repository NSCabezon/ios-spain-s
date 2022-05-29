//

protocol ManagerNotificationsDataSourceProtocol: RestDataSource {
    func getManagerNotifications() throws -> BSANResponse<ManagerNotificationsDTO>
}
