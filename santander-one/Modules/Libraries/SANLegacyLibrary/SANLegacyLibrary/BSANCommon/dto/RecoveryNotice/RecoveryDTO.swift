public struct RecoveryDTO: Codable {
    public var accountId: String?
    public var groupType: String?
    public var noticeLevel: Int?
    public var description: String?
    public var totalUnpaidAmount: Double?
}
