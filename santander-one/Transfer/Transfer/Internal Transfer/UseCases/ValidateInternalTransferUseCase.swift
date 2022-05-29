import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class ValidateInternalTransferUseCase: UseCase<ValidateInternalTransferUseCaseInput, ValidateInternalTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    private var maxLenghtConcept: Int {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self).maxLengthInternalTransferConcept
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateInternalTransferUseCaseInput) throws -> UseCaseResponse<ValidateInternalTransferUseCaseOkOutput, StringErrorOutput> {
        guard let amountString = requestValues.amount, let amountDecimal = Decimal(string: amountString.replace(".", "").replace(",", ".")) else {
            return UseCaseResponse.error(InternalTransferError(.invalidAmount("generic_alert_text_errorAmount")))
        }
        guard amountDecimal > 0 else {
            return UseCaseResponse.error(InternalTransferError(.invalidAmount("generic_alert_text_errorData_amount")))
        }
        
        let amount = AmountEntity(value: amountDecimal)
        guard requestValues.concept?.count ?? 0 <= self.maxLenghtConcept else {
            return UseCaseResponse.error(StringErrorOutput("sendMoney_label_maxCharacters"))
        }
        guard let selectedAccount = requestValues.selectedAccount, let destinationAccount = requestValues.destinationAccount else {
            return UseCaseResponse.error(StringErrorOutput("generic_error_internetConnection"))
        }
        let concept = requestValues.concept ?? ""
        return try transferWithInternalTransferType(requestValues.time,
                                                    selectedAccount: selectedAccount,
                                                    destinationAccount: destinationAccount,
                                                    amount: amount,
                                                    concept: concept)
    }
    
    private func transferWithInternalTransferType(_ time: ValidateInternalTransferTypeInput,
                                                  selectedAccount: AccountEntity,
                                                  destinationAccount: AccountEntity,
                                                  amount: AmountEntity,
                                                  concept: String) throws -> UseCaseResponse<ValidateInternalTransferUseCaseOkOutput, StringErrorOutput> {
        switch time {
        case .now:
            let inpunt = ValidateInternalTransferNowUseCaseInput(originAccount: selectedAccount, destinationAccount: destinationAccount, amount: amount, concept: concept)
            return try self.internalTransfer(with: inpunt)
        case .day(let date):
            guard let date = date else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let inpunt = ValidateInternalTransferDeferredUseCaseInput(originAccount: selectedAccount, destinationAccount: destinationAccount, amount: amount, concept: concept, date: date)
            return try self.internalDeferredTransfer(with: inpunt)
        case .periodic(let start, let endDate, let isEnd, let periodicity, let emission):
            guard let start = start else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let end: TransferTimeEndDate
            if isEnd {
                end = .never
            } else {
                guard let endDate = endDate else {
                    return UseCaseResponse.error(StringErrorOutput(nil))
                }
                end = .date(endDate)
            }
            let periodicityData: TransferPeriodicity = periodicity.transferPeriodicity
            let workingDayIssue: TransferWorkingDayIssue = emission.transferWorkingDayIssue
            let inpunt = ValidateInternalTransferPeriodicUseCaseInput(originAccount: selectedAccount,
                                                                      destinationAccount: destinationAccount,
                                                                      amount: amount,
                                                                      concept: concept,
                                                                      startDate: start,
                                                                      endDate: end,
                                                                      periodicity: periodicityData,
                                                                      workingDayIssue: workingDayIssue)
            return try self.internalPeriodicTransfer(with: inpunt)
        }
    }
    
    private struct ValidateInternalTransferNowUseCaseInput {
        let originAccount: AccountEntity
        let destinationAccount: AccountEntity
        let amount: AmountEntity
        let concept: String
    }
    
    private func internalTransfer(with requestValues: ValidateInternalTransferNowUseCaseInput) throws -> UseCaseResponse<ValidateInternalTransferUseCaseOkOutput, StringErrorOutput> {
        let response = try self.provider.getBsanTransfersManager().validateAccountTransfer(
            originAccountDTO: requestValues.originAccount.dto,
            destinationAccountDTO: requestValues.destinationAccount.dto,
            accountTransferInput: AccountTransferInput(
                amountDTO: requestValues.amount.dto,
                concept: requestValues.concept
            )
        )
        guard response.isSuccess(), let validateAccountTransferDTO = try response.getResponseData(), let internalTransfer = InternalTransferEntity(transferAccountDTO: validateAccountTransferDTO),
              let scaEntity = self.getSCAEntity(validateAccountTransferDTO.scaRepresentable) else {
            let errorDescription = try response.getErrorMessage() ?? "generic_error_internetConnection"
            return .error(StringErrorOutput(errorDescription))
        }
        return .ok(ValidateInternalTransferUseCaseOkOutput(internalTransfer: internalTransfer, scheduledTransfer: nil, time: .now, amount: requestValues.amount, concept: requestValues.concept, scaEntity: scaEntity))
    }
    
    private struct ValidateInternalTransferDeferredUseCaseInput {
        let originAccount: AccountEntity
        let destinationAccount: AccountEntity
        let amount: AmountEntity
        let concept: String
        let date: Date
    }
    
    private func internalDeferredTransfer(with requestValues: ValidateInternalTransferDeferredUseCaseInput) throws -> UseCaseResponse<ValidateInternalTransferUseCaseOkOutput, StringErrorOutput> {
        let pgResponse = try self.provider.getBsanPGManager().getGlobalPosition()
        guard pgResponse.isSuccess(), let pgData = try pgResponse.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try pgResponse.getErrorMessage()))
        }
        let date = requestValues.date
        let time = TransferTime.day(date: date)
        guard let iban = requestValues.destinationAccount.getIban() else { return .error(StringErrorOutput(nil)) }
        let input = ValidateInternalScheduledTransferUseCaseInput(
            originAccount: requestValues.originAccount,
            destinationAccount: requestValues.destinationAccount,
            amount: requestValues.amount,
            concept: requestValues.concept,
            time: time,
            scheduledTransfer: nil,
            isSpanishResident: true,
            saveFavorites: false,
            alias: "",
            name: pgData.clientName
        )
        let transferDTO = input.toScheduledTransferInputDTO(date: date, iban: iban)
        let response = try self.provider.getBsanTransfersManager().validateDeferredTransfer(originAcount: requestValues.originAccount.dto, scheduledTransferInput: transferDTO)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
        }
        guard let responseData = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let scheduledTransfer = ValidateScheduledTransferEntity(responseData)
        guard let internalTransfer = InternalTransferEntity(scheduledTransfer: scheduledTransfer, issueDate: date, transferAmount: input.amount),
              let scaEntity = self.getSCAEntity(responseData.scaRepresentable) else {
            return  UseCaseResponse.error(StringErrorOutput(nil))
        }
        return .ok(ValidateInternalTransferUseCaseOkOutput(internalTransfer: internalTransfer, scheduledTransfer: scheduledTransfer, time: time, amount: requestValues.amount, concept: requestValues.concept, scaEntity: scaEntity))
    }
    
    private struct ValidateInternalTransferPeriodicUseCaseInput {
        let originAccount: AccountEntity
        let destinationAccount: AccountEntity
        let amount: AmountEntity
        let concept: String
        let startDate: Date
        let endDate: TransferTimeEndDate
        let periodicity: TransferPeriodicity
        let workingDayIssue: TransferWorkingDayIssue
    }
    
    private func internalPeriodicTransfer(with requestValues: ValidateInternalTransferPeriodicUseCaseInput) throws -> UseCaseResponse<ValidateInternalTransferUseCaseOkOutput, StringErrorOutput> {
        let pgResponse = try self.provider.getBsanPGManager().getGlobalPosition()
        guard pgResponse.isSuccess(), let pgData = try pgResponse.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try pgResponse.getErrorMessage()))
        }
        guard let iban = requestValues.destinationAccount.getIban() else { return .error(StringErrorOutput(nil)) }
        let endDateValue: DateModel?
        switch requestValues.endDate {
        case .never:
            endDateValue = nil
        case .date(let date):
            endDateValue = DateModel(date: date)
        }
        let time = TransferTime.periodic(startDate: requestValues.startDate, endDate: requestValues.endDate, periodicity: requestValues.periodicity, workingDayIssue: requestValues.workingDayIssue)
        let input = ValidateInternalScheduledTransferUseCaseInput(
            originAccount: requestValues.originAccount,
            destinationAccount: requestValues.destinationAccount,
            amount: requestValues.amount,
            concept: requestValues.concept,
            time: time,
            scheduledTransfer: nil,
            isSpanishResident: true,
            saveFavorites: false,
            alias: "",
            name: pgData.clientName
        )
        let transferDTO = input.toScheduledTransferInputDTO(startDate: requestValues.startDate, endDate: endDateValue, periodicity: requestValues.periodicity, workingDayIssue: requestValues.workingDayIssue, iban: iban)
        let response = try provider.getBsanTransfersManager().validateScheduledTransfer(originAcount: requestValues.originAccount.dto, scheduledTransferInput: transferDTO)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
        }
        guard let responseData = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let scheduledTransfer = ValidateScheduledTransferEntity(responseData)
        guard let internalTransfer = InternalTransferEntity(scheduledTransfer: scheduledTransfer, issueDate: requestValues.startDate, transferAmount: input.amount),
              let scaEntity = self.getSCAEntity(responseData.scaRepresentable)else {
            return  UseCaseResponse.error(StringErrorOutput(nil))
        }
        return .ok(ValidateInternalTransferUseCaseOkOutput(internalTransfer: internalTransfer, scheduledTransfer: scheduledTransfer, time: time, amount: requestValues.amount, concept: requestValues.concept, scaEntity: scaEntity))
    }
}

private extension ValidateInternalTransferUseCase {
    func getSCAEntity(_ scaRepresentable: SCARepresentable?) -> SCAEntity? {
        guard let scaRepresentable = scaRepresentable else { return nil }
        return SCAEntity(scaRepresentable)
    }
}

enum ValidateInternalTransferTypeInput {
    case now
    case day(date: Date?)
    case periodic(start: Date?, end: Date?, isEnd: Bool, periodicity: ValidateInternalTransferPeriodicPeriodicityType, emission: ValidateInternalTransferPeriodicEmissionType)
}

enum ValidateInternalTransferPeriodicPeriodicityType {
    case month
    case quarterly
    case semiannual
    case weekly
    case bimonthly
    case annual
    
    var transferPeriodicity: TransferPeriodicity {
        switch self {
        case .month:
            return .monthly
        case .quarterly:
            return .quarterly
        case .semiannual:
            return .biannual
        case .weekly:
            return .weekly
        case .bimonthly:
            return .bimonthly
        case .annual:
            return .annual
        }
    }
}

enum ValidateInternalTransferPeriodicEmissionType {
    case previous
    case next
    
    var transferWorkingDayIssue: TransferWorkingDayIssue {
        switch self {
        case .previous:
            return .previousDay
        case .next:
            return .laterDay
        }
    }
}

struct ValidateInternalTransferUseCaseInput {
    let amount: String?
    let concept: String?
    let time: ValidateInternalTransferTypeInput
    let selectedAccount: AccountEntity?
    let destinationAccount: AccountEntity?
}

private struct ValidateInternalScheduledTransferUseCaseInput: ScheduledTransferConvertible {
    let originAccount: AccountEntity
    let destinationAccount: AccountEntity
    let amount: AmountEntity
    let concept: String?
    let time: TransferTime
    let scheduledTransfer: ValidateScheduledTransferEntity?
    let isSpanishResident: Bool
    let saveFavorites: Bool
    let alias: String?
    let name: String?
}

struct ValidateInternalTransferUseCaseOkOutput {
    let internalTransfer: InternalTransferEntity
    let scheduledTransfer: ValidateScheduledTransferEntity?
    let time: TransferTime
    let amount: AmountEntity
    let concept: String
    let scaEntity: SCAEntity
}

enum InternalTransferErrorType {
    case invalidAmount(String)
}

class InternalTransferError: StringErrorOutput {
    let error: InternalTransferErrorType
    
    init(_ error: InternalTransferErrorType) {
        self.error = error
        super.init("")
    }
}
