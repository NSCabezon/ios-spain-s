struct CancelTransferOperativeData: OperativeParameter {
    let transferScheduled: TransferScheduled
    var scheduledTransferDetail: ScheduledTransferDetail?
    let account: Account
}
