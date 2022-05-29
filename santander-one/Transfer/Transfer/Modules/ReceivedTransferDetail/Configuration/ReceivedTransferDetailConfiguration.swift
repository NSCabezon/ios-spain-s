import CoreFoundationLib

public struct ReceivedTransferDetailConfiguration {
    public let transfer: TransferReceivedEntity
    public init(transfer: TransferReceivedEntity) {
        self.transfer = transfer
    }
}
