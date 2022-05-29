import CoreFoundationLib

public struct GetScheduledTransferDetailUseCaseInput {
    public var account: AccountEntity
    public var transfer: TransferScheduledEntity?
    public var scheduledTransferId: String?
}
