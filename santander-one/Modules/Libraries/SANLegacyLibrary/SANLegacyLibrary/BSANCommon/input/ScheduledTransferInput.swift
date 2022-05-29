import Foundation
import CoreDomain

public struct ScheduledTransferInput: Codable {
    public let dateStartValidity: DateModel?
    public let dateEndValidity: DateModel?
    public let scheduledDayType: ScheduledDayDTO?
    public let periodicalType: PeriodicalTypeTransferDTO?
    public let indicatorResidence: Bool
    public let concept: String?
    public let dateNextExecution: DateModel?
    public let currency: String?
    public let nameBankIbanBeneficiary: String?
    public let actuanteCompany: String?
    public let actuanteCode: String?
    public let actuanteNumber: String?
    public let ibanDestination: IBANDTO
    public let saveAsUsual: Bool?
    public let saveAsUsualAlias: String?
    public let beneficiary: String?
    public let transferAmount: AmountDTO
    public let company: String?
    public let subType: TransferTypeDTO?
    
    public init(dateStartValidity: DateModel?, dateEndValidity: DateModel?, scheduledDayType: ScheduledDayDTO?, periodicalType: PeriodicalTypeTransferDTO?, indicatorResidence: Bool, concept: String?, dateNextExecution: DateModel?, currency: String?, nameBankIbanBeneficiary: String?, actuanteCompany: String?, actuanteCode: String?, actuanteNumber: String?, ibanDestination: IBANDTO, saveAsUsual: Bool?, saveAsUsualAlias: String?, beneficiary: String?, transferAmount: AmountDTO, company: String?, subType: TransferTypeDTO?) {
        self.dateStartValidity = dateStartValidity
        self.dateEndValidity = dateEndValidity
        self.scheduledDayType = scheduledDayType
        self.periodicalType = periodicalType
        self.indicatorResidence = indicatorResidence
        self.concept = concept
        self.currency = currency
        self.dateNextExecution = dateNextExecution
        self.nameBankIbanBeneficiary = nameBankIbanBeneficiary
        self.actuanteCompany = actuanteCompany
        self.actuanteCode = actuanteCode
        self.actuanteNumber = actuanteNumber
        self.ibanDestination = ibanDestination
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiary = beneficiary
        self.transferAmount = transferAmount
        self.company = company
        self.subType = subType
    }
    
    public init(dateStartValidity: DateModel?, dateEndValidity: DateModel?, scheduledDayType: ScheduledDayDTO?, periodicalType: PeriodicalTypeTransferDTO?, indicatorResidence: Bool, concept: String?, dateNextExecution: DateModel?, currency: String?, nameBankIbanBeneficiary: String?, actuanteCompany: String?, actuanteCode: String?, actuanteNumber: String?, ibanDestination: IBANRepresentable, saveAsUsual: Bool?, saveAsUsualAlias: String?, beneficiary: String?, transferAmount: AmountRepresentable, company: String?, subType: TransferTypeDTO?) {
        self.dateStartValidity = dateStartValidity
        self.dateEndValidity = dateEndValidity
        self.scheduledDayType = scheduledDayType
        self.periodicalType = periodicalType
        self.indicatorResidence = indicatorResidence
        self.concept = concept
        self.currency = currency
        self.dateNextExecution = dateNextExecution
        self.nameBankIbanBeneficiary = nameBankIbanBeneficiary
        self.actuanteCompany = actuanteCompany
        self.actuanteCode = actuanteCode
        self.actuanteNumber = actuanteNumber
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiary = beneficiary
        self.company = company
        self.subType = subType
        self.ibanDestination = IBANDTO(countryCode: ibanDestination.countryCode, checkDigits: ibanDestination.checkDigits, codBban: ibanDestination.codBban)
        let currency = CurrencyDTO(currencyName: transferAmount.currencyRepresentable?.currencyName ?? "", currencyType: transferAmount.currencyRepresentable?.currencyType ?? .eur)
        self.transferAmount = AmountDTO(value: transferAmount.value ?? .zero, currency: currency)
    }
}
