import CoreFoundationLib
import Operative
import SANLegacyLibrary
import CoreDomain

public final class ConfirmationAmortizationViewModel {
    
    private var loan: LoanRepresentable
    private var loanDetail: LoanDetailRepresentable
    private var partialLoan: LoanPartialAmortizationRepresentable
    private var loanValidation: LoanValidationRepresentable
    private var amountTypeAmortization: PartialAmortizationType
    private var amountSelected: AmountRepresentable
    private var timeManager: TimeManager
    private var selectedAccount: AccountRepresentable?
    private var phoneNumber: String?
    private var pendingAmount: AmountRepresentable?
    private var operativeData: LoanPartialAmortizationOperativeData

    init(_ loan: LoanRepresentable,
         loanDetail: LoanDetailRepresentable,
         partialLoan: LoanPartialAmortizationRepresentable,
         loanValidation: LoanValidationRepresentable,
         amountTypeAmortization: PartialAmortizationType,
         amountSelected: AmountRepresentable,
         timeManager: TimeManager,
         selectedAccount: AccountRepresentable?,
         phoneNumber: String?,
         pendingAmount: AmountRepresentable?,
         operativeData: LoanPartialAmortizationOperativeData) {
        self.loan = loan
        self.loanDetail = loanDetail
        self.partialLoan = partialLoan
        self.loanValidation = loanValidation
        self.amountTypeAmortization = amountTypeAmortization
        self.amountSelected = amountSelected
        self.timeManager = timeManager
        self.selectedAccount = selectedAccount
        self.phoneNumber = phoneNumber
        self.pendingAmount = pendingAmount
        self.operativeData = operativeData
    }
    
    public var amountAmortized: AmountRepresentable? {
        amountSelected
    }
    
    public var loanTitle: String? {
        loan.alias
    }
    
    public let contractTitle: String = "confirmation_item_contract"
    public var contractNumber: String {
        if let bankCode = loan.contractRepresentable?.bankCode,
           let branchCode = loan.contractRepresentable?.branchCode,
           let contractNumber = loan.contractRepresentable?.contractNumber,
           let product = loan.contractRepresentable?.product {
            return "\(bankCode) \(branchCode) \(product) \(contractNumber)"
        } else {
            return ""
        }
    }
    
    public let contractHolderTitle: String = "confirmation_item_holder"
    public var contractHolder: String {
        loanDetail.holder?.capitalized ?? ""
    }
    
    public var iban: String? {
        if let accountDTO = selectedAccount as? AccountDTO {
            return AccountEntity(accountDTO).getIBANFormatted
        } else {
            return ""
        }
    }
    
    public let pendingCapitalTitle: String = "confirmation_item_pendingAmount_without"
    public var pendingCapital: AmountRepresentable? {
        self.pendingAmount
    }

    public let expirationDateTitle = "confirmation_item_expiryDate"
    public var expirationDate: String {
        timeManager.toString(input: partialLoan.getExpiration ?? "",
                             inputFormat: .yyyyMMdd,
                             outputFormat: .d_MMM_yyyy) ?? ""
    }
    
    public let initialAmountTitle: String = "confirmation_item_startLimit"
    public var initialLimit: AmountRepresentable? {
        partialLoan.getStartLimit
    }
    
    public let applyForTitle: String = "confirmation_item_applyFor"
    public var applyFor: String {
        switch amountTypeAmortization {
        case .decreaseFee:
            return localized("anticipatedAmortization_label_decreaseFee")
        case .decreaseTime:
            return localized("anticipatedAmortization_label_advanceExpiration")
        }
    }
    
    let valueDateTitle = "confirmation_item_valueDate"
    public var valueDate: String {
        timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy) ?? ""
    }
    
    public let liquidationAmountTitle: String = "confirmation_item_settlementAmount"
    public var liquidationAmount: AmountRepresentable? {
        loanValidation.settlementAmountRepresentable
    }
    
    var totalAmount: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 40)
        let amount = AmountRepresentableDecorator(amountSelected, font: font, decimalFontSize: 26)
        return amount.getFormatedAbsWith1M()
    }
    
    var phone: String? {
        phoneNumber
    }

    public var isNewMortgageLawLoan: Bool {
        operativeData.partialAmortization?.isNewMortgageLawLoan ?? false
    }

    public let finantialLossTitle: String = "confirmation_item_financialLoss"
    public var finantialLossAmount: AmountRepresentable? {
        loanValidation.finantialLossAmountRepresentable
    }

    public let compensationTitle: String = "confirmation_item_compensation"
    public var compensationAmount: AmountRepresentable? {
        loanValidation.compensationAmountRepresentable
    }

    public let insuranceFeeTitle: String = "confirmation_item_newInsurancePremium"
    public var insuranceFeeAmount: AmountRepresentable? {
        loanValidation.insuranceFeeAmountRepresentable
    }
}
