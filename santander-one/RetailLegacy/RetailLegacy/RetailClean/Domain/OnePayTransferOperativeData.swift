import Foundation
import SANLegacyLibrary
import CoreFoundationLib

enum OnePayTransferTime: Equatable {
    case now
    case day(date: Date)
    case periodic(startDate: Date, endDate: OnePayTransferTimeEndDate, periodicity: OnePayTransferPeriodicity, workingDayIssue: OnePayTransferWorkingDayIssue)
    
    var trackerDescription: String {
        switch self {
            case .now: return "normal"
            case .day: return "diferida"
            case .periodic: return "periodica"
        }
    }
    
    static var defaultDay: OnePayTransferTime {
        return .day(date: DomainConstant.scheduledTransferMinimumDate)
    }
    
    static var defaultPeriodic: OnePayTransferTime {
        return .periodic(startDate: DomainConstant.periodicTransferMinimumDate, endDate: .never, periodicity: .monthly, workingDayIssue: .previousDay)
    }
    
    static func periodic(from time: OnePayTransferTime, startDate: Date? = nil, endDate: OnePayTransferTimeEndDate? = nil, periodicity: OnePayTransferPeriodicity? = nil, workingDayIssue: OnePayTransferWorkingDayIssue? = nil) -> OnePayTransferTime {
        switch time {
            case .periodic(let currentDate, let currentEndDate, let currentPeriodicity, let currentWorkindDayIssue):
                return .periodic(startDate: startDate ?? currentDate, endDate: endDate ?? currentEndDate, periodicity: periodicity ?? currentPeriodicity, workingDayIssue: workingDayIssue ?? currentWorkindDayIssue)
            default:
                return defaultPeriodic
        }
    }
    
    func isPeriodic() -> Bool {
        switch self {
            case .periodic:
                return true
            default:
                return false
        }
    }
    
    static func == (lhs: OnePayTransferTime, rhs: OnePayTransferTime) -> Bool {
        switch (lhs, rhs) {
            case (.now, .now): return true
            case (.day, .day): return true
            case (.periodic, .periodic): return true
            default: return false
        }
    }
    
    static func parserOnePayTransferTime(_ entity: SendMoneyDateTypeFilledViewModel) -> OnePayTransferTime {
        switch entity {
            case .now:
                return OnePayTransferTime.now
            case .day(let date):
                return OnePayTransferTime.day(date: date)
            case .periodic(let start, let end, let periodicity, let emission):
                let endDate: OnePayTransferTimeEndDate
                switch end {
                    case .never:
                        endDate = OnePayTransferTimeEndDate.never
                    case .date(let date):
                        endDate = OnePayTransferTimeEndDate.date(date)
                }
                
                let periodicityDate: OnePayTransferPeriodicity
                switch periodicity {
                    case .month:
                        periodicityDate = OnePayTransferPeriodicity.monthly
                    case .quarterly:
                        periodicityDate = OnePayTransferPeriodicity.quarterly
                    case .semiannual:
                        periodicityDate = OnePayTransferPeriodicity.biannual
                    case .weekly:
                        periodicityDate = OnePayTransferPeriodicity.weekly
                    case .bimonthly:
                        periodicityDate = OnePayTransferPeriodicity.bimonthly
                    case .annual:
                        periodicityDate = OnePayTransferPeriodicity.annual
                }
                
                let emissionDate: OnePayTransferWorkingDayIssue
                switch emission {
                    case .previous:
                        emissionDate = OnePayTransferWorkingDayIssue.previousDay
                    case .next:
                        emissionDate = OnePayTransferWorkingDayIssue.laterDay
                }
                return OnePayTransferTime.periodic(startDate: start, endDate: endDate, periodicity: periodicityDate, workingDayIssue: emissionDate)
        }
    }
}

enum OnePayTransferTimeEndDate {
    case never
    case date(Date)
}

enum OnePayTransferPeriodicity: CustomStringConvertible, CaseIterable {
    
    case monthly
    case quarterly
    case biannual
    case weekly
    case bimonthly
    case annual
    
    var dto: PeriodicalTypeTransferDTO {
        switch self {
            case .monthly: return .monthly
            case .quarterly: return .trimestral
            case .biannual: return .semiannual
            case .weekly: return .weekly
            case .bimonthly: return .bimonthly
            case .annual: return .annual
        }
    }
    
    var description: String {
        switch self {
            case .monthly: return "periodicContribution_label_monthly"
            case .quarterly: return "periodicContribution_label_quarterly"
            case .biannual: return "periodicContribution_label_biannual"
            case .weekly: return "generic_label_weekly"
            case .bimonthly: return "generic_label_bimonthly"
            case .annual: return "periodicContribution_label_annual"
        }
    }
}

enum OnePayTransferWorkingDayIssue: CustomStringConvertible, CaseIterable {
    
    case previousDay
    case laterDay
    
    var dto: ScheduledDayDTO {
        switch self {
            case .previousDay: return .previous_day
            case .laterDay: return .next_day
        }
    }
    
    var description: String {
        switch self {
            case .previousDay: return "sendMoney_label_previousWorkingDay"
            case .laterDay: return "sendMoney_label_laterWorkingDay"
        }
    }
}

enum OnePayTransferOperativeFinishType {
    case pg
    case home
}

class OnePayTransferOperativeData: ProductSelection<Account> {
    var sepaList: SepaInfoList? {
        didSet {
            country = countryCode != nil ? sepaList?.getSepaCountryInfo(countryCode) : sepaList?.allCountries.first
            currency = countryCode != nil ? sepaList?.getSepaCurrencyInfo(countryCode) : sepaList?.allCurrencies.first
        }
    }
    var listNotVisibles: [Account]?
    var favouriteList: [FavoriteType]?
    var favouriteListFiltered: [FavoriteType]? {
        return favouriteList?.filter { $0.favorite.iban?.countryCode == country?.code }
    }
    var maxImmediateNationalAmount: Amount?
    var country: SepaCountryInfo?
    var currency: SepaCurrencyInfo?
    var countryCode: String?
    var amount: Amount?
    var concept: String?
    var name: String?
    var iban: IBAN?
    var spainResident: Bool?
    var saveToFavorites: Bool?
    var alias: String?
    var subType: OnePayTransferSubType?
    var time: OnePayTransferTime?
    var transferNational: TransferNational?
    var scheduledTransfer: ScheduledTransfer?
    var type: OnePayTransferType?
    var beneficiaryMail: String?
    var summaryState: OnePayTransferSummaryState?
    var transferConfirmAccount: TransferConfirmAccount?
    var easyPayFundableType: AccountEasyPayFundableType = .notAllowed
    var payer: String?
    var baseUrl: String?
    var isBackToOriginEnabled: Bool = false
    var enabledFavouritesCarrusel: Bool?
    var finishType = OnePayTransferOperativeFinishType.pg
    var faqs: [FaqsEntity]?
    var favoriteContacts: [String]?
    var isModifySelectorAccountOnePay = true
    var isModifyAvailableOnePay = true
    var isModifyPeriodicityAvaiableOnePay = true
    var summaryUserName: String?
    var commission: Amount?
    var isFavouriteSelected: Bool = false
    var dateTypeModel: SendMoneyDateTypeFilledViewModel?
    var isEnableCurrencySelection: Bool = true
    var isEnableCountrySelection: Bool = true
    var isEnableEditingDestination: Bool = true
    var isBiometryAppConfigEnabled = false
    var isRightRegisteredDevice = false
    var isTouchIdEnabled = false
    var tokenPush: String?
    var footprint: String?
    var deviceToken: String?
    var userPreffersBiometry = false
    var tokenSteps: String?
    
    init(account: Account?) {
        super.init(list: [],
                   productSelected: account,
                   titleKey: "toolbar_title_sendMoney",
                   subTitleKey: "chargeDischarge_text_originAccountSelection")
    }
    
    func updatePre(accounts: [Account],
                   accountNotVisibles: [Account]? = nil,
                   sepaList: SepaInfoList,
                   faqs: [FaqsEntity]?) {
        self.list = accounts
        self.listNotVisibles = accountNotVisibles
        self.sepaList = sepaList
        self.faqs = faqs
    }
    
    func update(favouriteList: [FavoriteType],
                maxImmediateNationalAmount: Amount?,
                payer: String,
                baseUrl: String?,
                enabledFavouritesCarrusel: Bool,
                favoriteContacts: [String]?,
                summaryUserName: String) {
        self.favouriteList = favouriteList
        self.maxImmediateNationalAmount = maxImmediateNationalAmount
        self.payer = payer
        self.baseUrl = baseUrl
        self.enabledFavouritesCarrusel = self.enabledFavouritesCarrusel ?? enabledFavouritesCarrusel
        self.favoriteContacts = favoriteContacts
        self.summaryUserName = summaryUserName
    }
    
    func updateCountry(countryInfo: SepaCountryInfo, countryCode: ((SepaCountryInfoEntity) -> Bool)?) {
        self.country = countryInfo
        if let evaluateLocalCountryCode = countryCode {
            self.type = evaluateLocalCountryCode(countryInfo.entity) ? .national : .sepa
        } else {
            self.type = countryInfo.code == "ES" ? .national : .sepa
        }
    }
    
    func setAccount(_ accountEntity: AccountEntity) {
        self.productSelected = Account.create(accountEntity.dto)
    }
}

extension OnePayTransferOperativeData: TransferOperativeData {
    var beneficiary: String? {
        name
    }
    var issueDate: Date? {
        switch time {
            case .day(let date)?:
                return date
            default:
                return transferNational?.issueDate
        }
    }
    var bankChargeAmount: Amount? {
        transferNational?.bankChargeAmount ?? scheduledTransfer?.bankChargeAmount
    }
    var expensesAmount: Amount? {
        transferNational?.expensesAmount ?? commission
    }
    var netAmount: Amount? {
        transferNational?.netAmount
    }
    var transferAmount: Amount? {
        transferNational?.transferAmount ?? amount
    }
    var account: Account? {
        productSelected
    }
    var isModifyOriginAccountEnabled: Bool {
        self.isModifySelectorAccountOnePay
    }
    var isModifyDestinationAccountEnabled: Bool {
        self.isModifyAvailableOnePay
    }
    var isModifyCountryEnabled: Bool {
        self.isModifyAvailableOnePay
    }
    var isModifyPeriodicityEnabled: Bool {
        self.isModifyPeriodicityAvaiableOnePay
    }
    var isModifyConceptEnabled: Bool {
        self.isModifyAvailableOnePay
    }
    var isBiometryEnabled: Bool {
        self.isBiometryAppConfigEnabled
    }
    var isCorrectFingerFlag: Bool {
        transferNational?.isCorrectFingerPrintFlag == true 
    }
}
