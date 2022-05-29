class InternalTransferOperativeData: ProductSelection<Account> {
    let origin: OperativeLaunchedFrom
    var internalTransfer: InternalTransfer?
    var transferAccount: TransferAccount?
    var time: OnePayTransferTime?
    var scheduledTransfer: ScheduledTransfer?
    
    init(accounts: [Account]?, account: Account?, origin: OperativeLaunchedFrom) {
        self.origin = origin
        super.init(list: accounts ?? [], productSelected: account, titleKey: "toolbar_title_transfer", subTitleKey: "chargeDischarge_text_originAccountSelection")
    }
}
