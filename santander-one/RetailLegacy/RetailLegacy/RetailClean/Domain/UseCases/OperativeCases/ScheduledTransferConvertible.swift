import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain
import Foundation

protocol ScheduledTransferConvertible {
    var isSpanishResident: Bool { get }
    var concept: String? { get }
    var amount: Amount { get }
    var saveFavorites: Bool { get }
    var alias: String? { get }
    var name: String? { get }
    var time: OnePayTransferTime { get }
    var originAccount: Account { get }
    var scheduledTransfer: ScheduledTransfer? { get }
}

extension ScheduledTransferConvertible {
    
    func toScheduledTransferInputDTO(date: Date, iban: IBAN, subType: TransferTypeDTO? = nil) -> ScheduledTransferInput {
        return ScheduledTransferInput(
            dateStartValidity: nil,
            dateEndValidity: nil,
            scheduledDayType: nil,
            periodicalType: nil,
            indicatorResidence: isSpanishResident,
            concept: concept,
            dateNextExecution: DateModel(date: date),
            currency: amount.currencySymbol,
            nameBankIbanBeneficiary: scheduledTransfer?.nameBeneficiaryBank,
            actuanteCompany: scheduledTransfer?.company,
            actuanteCode: scheduledTransfer?.code,
            actuanteNumber: scheduledTransfer?.number,
            ibanDestination: iban.ibanDTO,
            saveAsUsual: saveFavorites,
            saveAsUsualAlias: alias,
            beneficiary: name,
            transferAmount: amount.amountDTO,
            company: nil,
            subType: subType
        )
    }
    
    func toScheduledTransferInputDTO(startDate: Date, endDate: DateModel?, periodicity: OnePayTransferPeriodicity, workingDayIssue: OnePayTransferWorkingDayIssue, iban: IBAN, subType: TransferTypeDTO? = nil) -> ScheduledTransferInput {
        return ScheduledTransferInput(
            dateStartValidity: DateModel(date: startDate),
            dateEndValidity: endDate,
            scheduledDayType: workingDayIssue.dto,
            periodicalType: periodicity.dto,
            indicatorResidence: isSpanishResident,
            concept: concept,
            dateNextExecution: nil,
            currency: amount.currencySymbol,
            nameBankIbanBeneficiary: scheduledTransfer?.nameBeneficiaryBank,
            actuanteCompany: scheduledTransfer?.company,
            actuanteCode: scheduledTransfer?.code,
            actuanteNumber: scheduledTransfer?.number,
            ibanDestination: iban.ibanDTO,
            saveAsUsual: saveFavorites,
            saveAsUsualAlias: alias,
            beneficiary: name,
            transferAmount: amount.amountDTO,
            company: nil,
            subType: subType
        )
    }
}
