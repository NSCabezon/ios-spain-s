import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmDeferredInternalTransferUseCase: UseCase<ConfirmScheduledInternalTransferUseCaseInput, ConfirmScheduledInternalTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmScheduledInternalTransferUseCaseInput) throws -> UseCaseResponse<ConfirmScheduledInternalTransferUseCaseOkOutput, StringErrorOutput> {
        guard case .day(date: let date) = requestValues.transferTime else { return .error(StringErrorOutput(nil)) }
        return try internalDeferredTransfer(with: requestValues, date: date)
    }
    
    private func internalDeferredTransfer(with requestValues: ConfirmScheduledInternalTransferUseCaseInput, date: Date) throws -> UseCaseResponse<ConfirmScheduledInternalTransferUseCaseOkOutput, StringErrorOutput> {
        let pgResponse = try self.provider.getBsanPGManager().getGlobalPosition()
        guard pgResponse.isSuccess(), let pgData = try pgResponse.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try pgResponse.getErrorMessage()))
        }
        guard let iban = requestValues.destinationAccount.getIban() else { return .error(StringErrorOutput(nil)) }
        let input = ConfirmInternalScheduledTransferUseCaseInput(
            originAccount: requestValues.originAccount,
            destinationAccount: requestValues.destinationAccount,
            amount: requestValues.amount,
            concept: requestValues.concept,
            time: requestValues.transferTime,
            scheduledTransfer: requestValues.scheduledTransfer,
            isSpanishResident: true,
            saveFavorites: false,
            alias: "",
            name: pgData.clientName
        )
        let transferDTO = input.toScheduledTransferInputDTO(date: date, iban: iban, subType: .NATIONAL_TRANSFER)
        let response = try self.provider.getBsanTransfersManager().validateDeferredTransfer(originAcount: requestValues.originAccount.dto, scheduledTransferInput: transferDTO)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
        }
        guard let responseData = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let scheduledTransfer = ValidateScheduledTransferEntity(responseData)
        guard let internalTransfer = InternalTransferEntity(scheduledTransfer: scheduledTransfer, issueDate: date, transferAmount: input.amount), let scaRepresentable = responseData.scaRepresentable  else {
            return  UseCaseResponse.error(StringErrorOutput(nil))
        }
        let scaEntity = SCAEntity(scaRepresentable)
        return .ok(ConfirmScheduledInternalTransferUseCaseOkOutput(internalTransfer: internalTransfer, scheduledTransfer: scheduledTransfer, scaEntity: scaEntity))
    }
}
