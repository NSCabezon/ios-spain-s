//
//  ScheduledTransferConvertible.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 16/01/2020.
//

import SANLegacyLibrary
import CoreDomain

public protocol ScheduledTransferConvertible {
    var isSpanishResident: Bool { get }
    var concept: String? { get }
    var amount: AmountEntity { get }
    var saveFavorites: Bool { get }
    var alias: String? { get }
    var name: String? { get }
    var time: TransferTime { get }
    var originAccount: AccountEntity { get }
    var scheduledTransfer: ValidateScheduledTransferEntity? { get }
}

extension ScheduledTransferConvertible {
    
    public func toScheduledTransferInputDTO(date: Date, iban: IBANEntity, subType: TransferTypeDTO? = nil) -> ScheduledTransferInput {
        return ScheduledTransferInput(
            dateStartValidity: nil,
            dateEndValidity: nil,
            scheduledDayType: nil,
            periodicalType: nil,
            indicatorResidence: isSpanishResident,
            concept: concept,
            dateNextExecution: DateModel(date: date),
            currency: amount.currency,
            nameBankIbanBeneficiary: scheduledTransfer?.nameBeneficiaryBank,
            actuanteCompany: scheduledTransfer?.company,
            actuanteCode: scheduledTransfer?.code,
            actuanteNumber: scheduledTransfer?.number,
            ibanDestination: iban.dto,
            saveAsUsual: saveFavorites,
            saveAsUsualAlias: alias,
            beneficiary: name,
            transferAmount: amount.dto,
            company: nil,
            subType: subType
        )
    }
    
    public func toScheduledTransferInputDTO(startDate: Date, endDate: DateModel?, periodicity: TransferPeriodicity, workingDayIssue: TransferWorkingDayIssue, iban: IBANEntity, subtype: TransferTypeDTO? = nil) -> ScheduledTransferInput {
        return ScheduledTransferInput(
            dateStartValidity: DateModel(date: startDate),
            dateEndValidity: endDate,
            scheduledDayType: workingDayIssue.dto,
            periodicalType: periodicity.dto,
            indicatorResidence: isSpanishResident,
            concept: concept,
            dateNextExecution: nil,
            currency: amount.currency,
            nameBankIbanBeneficiary: scheduledTransfer?.nameBeneficiaryBank,
            actuanteCompany: scheduledTransfer?.company,
            actuanteCode: scheduledTransfer?.code,
            actuanteNumber: scheduledTransfer?.number,
            ibanDestination: iban.dto,
            saveAsUsual: saveFavorites,
            saveAsUsualAlias: alias,
            beneficiary: name,
            transferAmount: amount.dto,
            company: nil,
            subType: subtype
        )
    }
}
