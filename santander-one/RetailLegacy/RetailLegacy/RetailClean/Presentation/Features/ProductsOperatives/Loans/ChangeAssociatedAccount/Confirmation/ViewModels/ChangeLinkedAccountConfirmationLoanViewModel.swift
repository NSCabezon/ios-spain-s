class ChangeLinkedAccountConfirmationLoanViewModel: TableModelViewItem<GenericConfirmationTableViewCell> {
    
    var loan: Loan
    
    init(_ loan: Loan, _ privateComponent: PresentationComponent) {
        self.loan = loan
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: GenericConfirmationTableViewCell) {
        viewCell.name = loan.getAlias()
        viewCell.amount = loan.getAmountUI()
        viewCell.amountInfo = dependencies.stringLoader.getString("changeAccount_label_pending")
    }
}
