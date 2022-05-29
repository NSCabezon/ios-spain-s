public protocol BSANRecoveryNoticesManager {
    func getRecoveryNotices() throws -> BSANResponse<[RecoveryDTO]>
}
