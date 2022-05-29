import CoreFoundationLib
import Bills

enum BillsAndTaxesTypeOperative: Int {
    case bills
    case taxes
    
    init(type: BillsAndTaxesTypeOperativePayment?) {
        switch type {
        case .bills: self = .bills
        case .taxes: self = .taxes
        case .billPayment: self = .bills
        case .none: self = .bills
        }
    }
}

class BillAndTaxesOperativeData: ProductSelection<Account> {
    var typeOperative: BillsAndTaxesTypeOperative?
    var permissionsCamera: PhotoPermissionAuthorizationStatus?
    var paymentBillTaxes: PaymentBillTaxes?
    var directDebit: Bool?
    var modeTypeSelector: ModeTypeBillsAndTaxes?
    var listNotVisible: [Account]?
    var faqs: [FaqsEntity]?
    
    init(account: Account?, typeOperative: BillsAndTaxesTypeOperative?) {
        super.init(list: [], productSelected: account, titleKey: "toolbar_title_doingPayement", subTitleKey: "generic_label_originAccountSelection")
        self.typeOperative = typeOperative
    }
    
    func updatePre(accounts: [Account], accountNotVisibles: [Account]? = nil) {
        self.list = accounts
        self.listNotVisible = accountNotVisibles
    }
}
