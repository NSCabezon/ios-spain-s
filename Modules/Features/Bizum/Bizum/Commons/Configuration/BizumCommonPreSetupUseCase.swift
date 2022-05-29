import CoreFoundationLib
import SANLibraryV3

protocol BizumCommonPreSetupUseCaseProtocol: UseCase<BizumCommonPreSetupUseCaseInput, BizumCommonPreSetupUseCaseOkOutput, StringErrorOutput> {

}

final class BizumCommonPreSetupUseCase: UseCase<BizumCommonPreSetupUseCaseInput, BizumCommonPreSetupUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependencies: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.dependencies = dependenciesResolver
    }

    override public func executeUseCase(requestValues: BizumCommonPreSetupUseCaseInput) throws -> UseCaseResponse<BizumCommonPreSetupUseCaseOkOutput, StringErrorOutput> {
        let bizumCheckPaymentEntity: BizumCheckPaymentEntity
        if let bizumCheckPaymentEntityUnwrapped = requestValues.bizumCheckPaymentEntity {
            bizumCheckPaymentEntity = bizumCheckPaymentEntityUnwrapped
        } else {
            let appConfigRepository = self.dependencies.resolve(for: AppConfigRepositoryProtocol.self)
            let defaultXPAN = appConfigRepository.getString(BizumHomeConstants.bizumDefaultXPAN) ?? ""
            let response = try self.provider.getBSANBizumManager().checkPayment(defaultXPAN: defaultXPAN)
            guard response.isSuccess(), let bizumCheckPaymentDTO = try response.getResponseData() else {
                return .error(StringErrorOutput(try response.getErrorMessage()))
            }
            bizumCheckPaymentEntity = BizumCheckPaymentEntity(bizumCheckPaymentDTO)
        }
        guard let document = try self.getDocumentWithCheckPayment(bizumCheckPaymentEntity) else {
            return .error(StringErrorOutput(nil))
        }
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            self.dependencies.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let iban = bizumCheckPaymentEntity.ibanPlainCode
        let accounts = globalPosition.allAccountsWithoutPiggy
        guard let account = accounts.first(where: { $0.getIban()?.ibanString == iban }) else {
            return .error(StringErrorOutput(""))
        }
        return UseCaseResponse.ok(BizumCommonPreSetupUseCaseOkOutput(account: account, document: document, accounts: accounts))
    }
}

extension BizumCommonPreSetupUseCase: BizumGetDocumentUseCaseProtocol {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

extension BizumCommonPreSetupUseCase: BizumCommonPreSetupUseCaseProtocol {}

struct BizumCommonPreSetupUseCaseInput {
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity?
    let operationEntity: BizumHistoricOperationEntity?
}

struct BizumCommonPreSetupUseCaseOkOutput {
    let account: AccountEntity
    let document: BizumDocumentEntity
    let accounts: [AccountEntity]
}
