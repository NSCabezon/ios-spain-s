import CoreFoundationLib
import Foundation
import SANLibraryV3

class SetupBizumRefundMoneyUseCase: UseCase<SetupBizumRefundMoneyUseCaseInput, SetupBizumRefundMoneyUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: SetupBizumRefundMoneyUseCaseInput) throws -> UseCaseResponse<SetupBizumRefundMoneyUseCaseOkOutput, StringErrorOutput> {
        guard let document = try self.getDocumentWithCheckPayment(requestValues.checkPayment) else {
            return .error(StringErrorOutput(nil))
        }
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let iban = requestValues.checkPayment.ibanPlainCode
        let accounts = globalPosition.accounts.all()
        guard let account = accounts.first(where: { $0.getIban()?.ibanString == iban }) else {
            return .error(StringErrorOutput(nil))
        }
        return .ok(SetupBizumRefundMoneyUseCaseOkOutput(account: account, document: document))
    }
}

extension SetupBizumRefundMoneyUseCase: BizumGetDocumentUseCaseProtocol {}

struct SetupBizumRefundMoneyUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
}

struct SetupBizumRefundMoneyUseCaseOkOutput {
    let account: AccountEntity
    let document: BizumDocumentEntity
}
