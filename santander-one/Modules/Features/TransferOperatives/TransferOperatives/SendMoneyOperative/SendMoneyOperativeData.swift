//
//  SendMoneyOperativeData.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//
import CoreFoundationLib
import CoreDomain

public final class SendMoneyOperativeData {
    public var isOwner: Bool
    public var selectedAccount: AccountRepresentable?
    public var country: CountryInfoRepresentable?
    public var destinationAccountCurrency: CurrencyInfoRepresentable?
    public var amount: AmountRepresentable?
    public var ibanValidationOutput: IbanValidationSendMoneyUseCaseOkOutput?
    public var specialPricesOutput: SendMoneyTransferTypeUseCaseOkOutputProtocol?
    public var description: String?
    public var destinationIBANRepresentable: IBANRepresentable?
    public var destinationName: String?
    public var destinationAlias: String?
    public var selectedTransferType: SendMoneyTransferTypeFee?
    public var maxImmediateNationalAmount: AmountRepresentable?
    public var transferDateType: SendMoneyDateTypeViewModel?
    public var transferFullDateType: SendMoneyDateTypeFilledViewModel = .now
    public var saveToFavorite: Bool = false
    public var fullFavorites: [PayeeRepresentable]?
    public var scheduledTransfer: ValidateScheduledTransferRepresentable?
    public var transferNationalRepresentable: TransferNationalRepresentable?
    public var scaRepresentable: SCARepresentable?
    public var destinationAccount: String?
    
    public var type: OnePayTransferType = .national
    public var currency: CurrencyInfoRepresentable?
    public var expenses: SendMoneyNoSepaExpensesProtocol?
    public var beneficiaryMail: String?
    public var issueDate = Date()
    public var selectedLastTransferIndex: Int?
    public var destinationSelectionType: SendMoneyDestinationSelectionType = .newRecipient
    public var lastTransfers: [TransferRepresentable]?
    public var selectedPayee: PayeeRepresentable?
    
    // NO SEPA
    public var bicSwift: String?
    public var bankName: String?
    public var bankAddress: String?
    public var noSepaTransferValidation: ValidationIntNoSepaRepresentable?
    public var swiftValidationRepresentable: ValidationSwiftRepresentable?
    
    public var countryCode: String? {
        didSet {
            self.country = sepaList?.allCountriesRepresentable.first(where: { $0.code == countryCode })
            self.currency = sepaList?.allCurrenciesRepresentable.first(where: { $0.code == self.country?.currency })
        }
    }
    public var currencyName: String? {
        didSet {
            self.currency = sepaList?.allCurrenciesRepresentable.first(where: { $0.code == currencyName })
        }
    }
    public var bankChargeAmount: AmountRepresentable? {
        return self.transferNationalRepresentable?.bankChargeAmountRepresentable ?? self.scheduledTransfer?.bankChargeAmountRepresentable
    }
    
    var mainAccount: AccountRepresentable?
    var accountVisibles: [AccountRepresentable] = []
    var accountNotVisibles: [AccountRepresentable] = []
    var sepaList: SepaInfoListRepresentable?
    var periodicalTypeTransfer: SendMoneyPeriodicityTypeViewModel?
    var transferWorkingDayIssue: SendMoneyEmissionTypeViewModel?
    var endDate: Date?
    var startDate: Date?
    var isSelectDeadlineCheckbox = true
    var faqs: [FaqRepresentable]?
    var carouselFavorites: [PayeeRepresentable]?
    var indexPeriodicity: Int?
    var shouldShowSelectOrigin: Bool = false

    var transferConfirmAccount: TransferConfirmAccountRepresentable?
    public var summaryState: SendMoneyTransferSummaryState?
    var easyPayFundableType: AccountEasyPayFundableType = .notAllowed
    var didSwapCurrentStep: Bool = false
    
    var destinationCountryName: String? {
        guard let countryCode = self.countryCode,
              let countryName = self.sepaList?.allCountriesRepresentable.first(where: { $0.code == countryCode })?.name else { return nil }
        return countryName
    }
    
    init(isOwner: Bool = false) {
        self.isOwner = isOwner
    }
    
    func update(accounts: [AccountRepresentable], accountNotVisibles: [AccountRepresentable]? = nil, sepaList: SepaInfoListRepresentable, faqs: [FaqRepresentable]?, countryCode: String?) {
        self.accountVisibles = accounts
        self.accountNotVisibles = accountNotVisibles ?? []
        self.sepaList = sepaList
        self.countryCode = countryCode
        self.faqs = faqs
        self.mainAccount = accounts.first(where: { $0.isMainAccount ?? false}) ?? accountNotVisibles?.first(where: { $0.isMainAccount ?? false })
    }
    
    func updateDefaultCurrency() {
        self.currency = sepaList?.allCurrenciesRepresentable.first(where: { $0.code == self.country?.currency })
    }
}

public enum SendMoneyTransferSummaryState: Equatable {
    case success(title: String? = "summary_label_success", subtitle: String? = "summary_label_amountOf")
    case pending(title: String? = "summary_label_shipmentPending", subtitle: String? = "summary_label_transferBeingProcessed")
    case error(title: String? = "summary_label_transferNotCompleted", subtitle: String? = "summary_label_moneyNotArrivedDestination")
    
    func associatedValue() -> (title: String?, subtitle: String?) {
      switch self {
      case .success(let title, let subtitle), .pending(let title, let subtitle), .error(let title, let subtitle):
          return (title: title, subtitle: subtitle)
      }
    }
}
