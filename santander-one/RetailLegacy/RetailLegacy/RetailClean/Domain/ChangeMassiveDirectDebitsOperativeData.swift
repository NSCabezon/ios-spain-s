class ChangeMassiveDirectDebitsOperativeData: ProductSelection<Account> {
    
    var destinationAccount: Account?
    
    init(account: Account?) {
        super.init(list: [], productSelected: account, titleKey: "toolbar_title_directDebitMassiveReceipts", subTitleKey: "directDebitMassive_text_selectAccountChange")
    }
}
