import CoreFoundationLib
import CoreDomain

public struct OneInputSpecialIBANViewModel {
    public enum ValidableType {
        case validatedCustom(titleKey: String, imageKey: String)
        case validatedBank(bankName: String, bankUrl: String?)
        case alert(errorMessageKey: String)
        case empty
    }
    public var validableType: ValidableType?
    let bankingUtils: BankingUtilsProtocol?
    public var status: OneStatus?
    public var ibanString: String?
    let didTapTooltip: (() -> Void)?
    let didTapCountryButton: (() -> Void)?
    public var ibanRepresentable: IBANRepresentable?
    public var dependenciesResolver: DependenciesResolver?
    public var flagImageUrl: String?
    let accessibilitySuffix: String?
    
    public init(
        bankingUtils: BankingUtilsProtocol? = nil,
        status: OneStatus? = nil,
        validableType: ValidableType? = nil,
        ibanString: String? = nil,
        didTapTooltip: (() -> Void)? = nil,
        didTapCountryButton: (() -> Void)? = nil,
        flagImageUrl: String? = nil,
        accessibilitySuffix: String? = nil
    ) {
        self.bankingUtils = bankingUtils
        self.status = status
        self.validableType = validableType
        self.didTapTooltip = didTapTooltip
        self.didTapCountryButton = didTapCountryButton
        self.flagImageUrl = flagImageUrl
        self.accessibilitySuffix = accessibilitySuffix
    }
    
    public var bankLogoURL: String? {
        guard let entityCode = ibanRepresentable?.getEntityCode(),
              let countryCode = ibanRepresentable?.countryCode,
              let baseURLProvider = self.dependenciesResolver?.resolve(for: BaseURLProvider.self),
              let baseURL = baseURLProvider.baseURL else { return nil }
        return String(format: "%@%@/%@_%@%@",
                      baseURL,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
}
