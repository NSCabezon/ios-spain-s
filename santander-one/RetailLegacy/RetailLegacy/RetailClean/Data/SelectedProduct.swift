import SANLegacyLibrary

struct SelectedProduct {
    
    let account: AccountDTO?
    let fund: FundDTO?
    let loan: LoanDTO?
    let pension: PensionDTO?
    let card: CardDTO?
    
    init(with account: AccountDTO) {
        self.account = account
        self.fund = nil
        self.loan = nil
        self.pension = nil
        self.card = nil
    }
    
    init(with fund: FundDTO) {
        self.fund = fund
        self.account = nil
        self.loan = nil
        self.pension = nil
        self.card = nil
    }
    
    init(with loan: LoanDTO) {
        self.loan = loan
        self.fund = nil
        self.account = nil
        self.pension = nil
        self.card = nil
    }
    
    init(with pension: PensionDTO) {
        self.pension = pension
        self.fund = nil
        self.loan = nil
        self.account = nil
        self.card = nil
    }
    
    init(with card: CardDTO) {
        self.card = card
        self.pension = nil
        self.fund = nil
        self.loan = nil
        self.account = nil
    }
}
