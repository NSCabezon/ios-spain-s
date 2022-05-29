import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final public class TransferSubTypeCommissionsUseCase: UseCase<TransferSubTypeCommissionsUseCaseInput, TransferSubTypeCommissionsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: TransferSubTypeCommissionsUseCaseInput) throws -> UseCaseResponse<TransferSubTypeCommissionsUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve()
        let comissionStandard = appConfigRepository.getString(TransferConstant.appConfigNationalTransferInformation)
        let commissionInmediate = appConfigRepository.getString(TransferConstant.appConfigInmediateTransferInformation)
        let commissionUrgent = appConfigRepository.getString(TransferConstant.appConfigUrgentTransferInformation)
        let urgentTypeStatus = isUrgentTypeDisabled(requestValues.originAccount, requestValues.destinationAccount)

        guard appConfigRepository.getBool(TransferConstant.appConfigEnableNationalTransferPreLiquidations) == true else {
            return .ok(TransferSubTypeCommissionsUseCaseOkOutput(commissions: [:], taxes: nil, total: nil, transferPackage: nil, comissionStandard: comissionStandard ?? "", commissionInmediate: commissionInmediate ?? "", commissionUrgent: commissionUrgent ?? "", isUrgentTypeDisabled: urgentTypeStatus))
        }
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let response = try? bsanManagersProvider.getBsanTransfersManager().loadTransferSubTypeCommissions(
            originAccount: requestValues.originAccount.dto,
            destinationAccount: requestValues.destinationAccount.dto,
            amount: requestValues.amount.dto,
            beneficiary: requestValues.beneficiary,
            concept: requestValues.concept
        )
        guard let data = try? response?.getResponseData() else {
            return .ok(TransferSubTypeCommissionsUseCaseOkOutput(commissions: [:], taxes: nil, total: nil, transferPackage: nil, comissionStandard: comissionStandard ?? "", commissionInmediate: commissionInmediate ?? "", commissionUrgent: commissionUrgent ?? "", isUrgentTypeDisabled: urgentTypeStatus))
        }
        return .ok(TransferSubTypeCommissionsUseCaseOkOutput(commissions: TransferSubTypeCommissionEntity(data).commissions, taxes: TransferSubTypeCommissionEntity(data).taxes, total: TransferSubTypeCommissionEntity(data).total, transferPackage: TransferSubTypeCommissionEntity(data).transferPackage, comissionStandard: comissionStandard ?? "", commissionInmediate: commissionInmediate ?? "", commissionUrgent: commissionUrgent ?? "", isUrgentTypeDisabled: urgentTypeStatus))
    }
    
    private func isUrgentTypeDisabled(_ originAccount: AccountEntity, _ destinationAccount: IBANEntity) -> Bool {
        let accountDescriptorRepository: AccountDescriptorRepositoryProtocol = self.dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
        guard let accountGroupEntities = accountDescriptorRepository.getAccountDescriptor()?.accountGroupEntities else { return false }
        
        return accountGroupEntities.contains(where: {$0.entityCode == originAccount.entityCode}) && accountGroupEntities.contains(where: {$0.entityCode == destinationAccount.getEntityCode()})
    }
}

public struct TransferSubTypeCommissionsUseCaseInput {
    
    let originAccount: AccountEntity
    let destinationAccount: IBANEntity
    let amount: AmountEntity
    let beneficiary: String
    let concept: String
    
    public init(originAccount: AccountEntity, destinationAccount: IBANEntity, amount: AmountEntity, beneficiary: String, concept: String) {
        self.originAccount = originAccount
        self.destinationAccount = destinationAccount
        self.amount = amount
        self.beneficiary = beneficiary
        self.concept = concept
    }
}

public struct TransferSubTypeCommissionsUseCaseOkOutput {
    public let commissions: [TransferSubType: AmountEntity?]
    public let taxes: [TransferSubType: AmountEntity?]?
    public let total: [TransferSubType: AmountEntity?]?
    public let transferPackage: [TransferSubType: TransferPackage?]?
    public let comissionStandard: String?
    public let commissionInmediate: String?
    public let commissionUrgent: String?
    public let isUrgentTypeDisabled: Bool
}
