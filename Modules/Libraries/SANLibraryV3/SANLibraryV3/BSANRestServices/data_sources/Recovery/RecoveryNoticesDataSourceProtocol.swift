protocol RecoveryNoticesDataSourceProtocol: RestDataSource {
    func getRecoveryNotices() throws -> BSANResponse<[RecoveryDTO]>
}
