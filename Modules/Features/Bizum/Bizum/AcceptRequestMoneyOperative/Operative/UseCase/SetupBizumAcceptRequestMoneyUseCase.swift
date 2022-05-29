import Foundation
import CoreFoundationLib
import SANLibraryV3

class SetupBizumAcceptRequestMoneyUseCase: UseCase<SetupBizumAcceptRequestMoneyUseCaseOkInput, SetupBizumAcceptRequestMoneyUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependencies: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.dependencies = dependenciesResolver
    }

    override public func executeUseCase(requestValues: SetupBizumAcceptRequestMoneyUseCaseOkInput) throws -> UseCaseResponse<SetupBizumAcceptRequestMoneyUseCaseOkOutput, StringErrorOutput> {
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
        let iban = requestValues.bizumCheckPaymentEntity?.ibanPlainCode
        let accounts = globalPosition.accounts.all()
        guard let account = accounts.first(where: { $0.getIban()?.ibanString == iban }) else {
            return .error(StringErrorOutput(""))
        }
        return UseCaseResponse.ok(SetupBizumAcceptRequestMoneyUseCaseOkOutput(account: account, document: document))
    }
}

extension SetupBizumAcceptRequestMoneyUseCase: BizumGetDocumentUseCaseProtocol {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

public struct SetupBizumAcceptRequestMoneyUseCaseOkInput {
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity?
}

public struct SetupBizumAcceptRequestMoneyUseCaseOkOutput {
    let account: AccountEntity
    let document: BizumDocumentEntity
}
