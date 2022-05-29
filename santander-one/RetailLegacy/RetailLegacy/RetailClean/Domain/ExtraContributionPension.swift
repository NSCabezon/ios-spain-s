struct ExtraContributionPension: OperativeParameter {
    let originPension: Pension
    let pensionInfoOperation: PensionInfoOperation
    let account: Account?
    let amount: Amount
        
    init(originPension: Pension, pensionInfoOperation: PensionInfoOperation, account: Account?, amount: Amount) {
        self.originPension = originPension
        self.pensionInfoOperation = pensionInfoOperation
        self.account = account
        self.amount = amount
    }
}
