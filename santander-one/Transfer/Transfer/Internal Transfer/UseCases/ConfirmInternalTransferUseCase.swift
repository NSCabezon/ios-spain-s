import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol ConfirmInternalTransferUseCaseProtocol: UseCase<ConfirmInternalTransferUseCaseInputProtocol, ConfirmInternalTransferUseCaseOkOutputProtocol, StringErrorOutput> {}

public protocol ConfirmInternalTransferUseCaseInputProtocol {
    var originAccount: AccountEntity { get }
    var destinationAccount: AccountEntity { get }
    var amount: AmountEntity { get }
    var concept: String? { get }
    var transferTime: TransferTime { get }
    var scheduledTransfer: ValidateScheduledTransferEntity? { get }
}

public protocol ConfirmInternalTransferUseCaseOkOutputProtocol {
    var internalTransfer: InternalTransferEntity { get }
    var scheduledTransfer: ValidateScheduledTransferEntity? { get }
    var scaEntity: SCAEntity { get }
}

final class ConfirmInternalTransferUseCase: UseCase<ConfirmInternalTransferUseCaseInputProtocol, ConfirmInternalTransferUseCaseOkOutputProtocol, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmInternalTransferUseCaseInputProtocol) throws -> UseCaseResponse<ConfirmInternalTransferUseCaseOkOutputProtocol, StringErrorOutput> {
        return try self.internalTransfer(with: requestValues)
    }
    
    private func internalTransfer(with requestValues: ConfirmInternalTransferUseCaseInputProtocol) throws -> UseCaseResponse<ConfirmInternalTransferUseCaseOkOutputProtocol, StringErrorOutput> {
        let response = try self.provider.getBsanTransfersManager().validateAccountTransfer(
            originAccountDTO: requestValues.originAccount.dto,
            destinationAccountDTO: requestValues.destinationAccount.dto,
            accountTransferInput: AccountTransferInput(
                amountDTO: requestValues.amount.dto,
                concept: requestValues.concept ?? ""
            )
        )
        guard response.isSuccess(),
              let validateAccountTransferDTO = try response.getResponseData(),
              let internalTransfer = InternalTransferEntity(transferAccountDTO: validateAccountTransferDTO),
              let scaRepresentable = validateAccountTransferDTO.scaRepresentable else {
              let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        let scaEntity = SCAEntity(scaRepresentable)
        return .ok(ConfirmInternalTransferUseCaseOkOutput(internalTransfer: internalTransfer, scheduledTransfer: nil, scaEntity: scaEntity))
    }
}

struct ConfirmInternalTransferUseCaseInput {
    let originAccount: AccountEntity
    let destinationAccount: AccountEntity
    let amount: AmountEntity
    let concept: String?
    let transferTime: TransferTime
    let scheduledTransfer: ValidateScheduledTransferEntity?
}

struct ConfirmInternalTransferUseCaseOkOutput {
    let internalTransfer: InternalTransferEntity
    let scheduledTransfer: ValidateScheduledTransferEntity?
    let scaEntity: SCAEntity
}

extension ConfirmInternalTransferUseCase: ConfirmInternalTransferUseCaseProtocol {}
extension ConfirmInternalTransferUseCaseOkOutput: ConfirmInternalTransferUseCaseOkOutputProtocol {}
extension ConfirmInternalTransferUseCaseInput: ConfirmInternalTransferUseCaseInputProtocol {}
