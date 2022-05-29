import Foundation
import SANLegacyLibrary
import CoreDomain

public class GetAccountEasyPayUseCase: UseCase<GetAccountEasyPayUseCaseInput, GetAccountEasyPayUseCaseOkOutput, GenericUseCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    public override func executeUseCase(requestValues: GetAccountEasyPayUseCaseInput) throws -> UseCaseResponse<GetAccountEasyPayUseCaseOkOutput, GenericUseCaseErrorOutput> {
        let isAccountEasyPayEnabled: Bool
        switch requestValues.type {
        case .transaction:
            isAccountEasyPayEnabled = appConfigRepository.getBool(AccountsConstants.appConfigEnableAccountEasyPayForBills) ?? false
        case .transfer:
            isAccountEasyPayEnabled = appConfigRepository.getBool(AccountsConstants.appCfgEnableAccountEasyPayForStandardNTransfers) ?? false
        }
        guard
            isAccountEasyPayEnabled,
            let accountEasyPayLowAmountLimit = appConfigRepository.getDecimal(AccountsConstants.appConfigAccountEasyPayLowAmountLimit),
            let accountEasyPayMinAmount = appConfigRepository.getDecimal(AccountsConstants.appConfigAccountEasyPayMinAmount)
        else {
            return .error(GenericUseCaseErrorOutput(nil, nil))
        }
        let response = try? bsanManagersProvider.getBsanAccountsManager().getAccountEasyPay()
        guard let easyPayResponse = response, easyPayResponse.isSuccess(), let campaignsEasyPay: [AccountEasyPayRepresentable] = try easyPayResponse.getResponseData() else {
            return .error(GenericUseCaseErrorOutput(try response?.getErrorCode(), try response?.getErrorMessage()))
        }
        return .ok(GetAccountEasyPayUseCaseOkOutput(accountEasyPay: AccountEasyPay(accountEasyPayMinAmount: accountEasyPayMinAmount, accountEasyPayLowAmountLimit: accountEasyPayLowAmountLimit, campaignsEasyPay: campaignsEasyPay)))
    }
}

public struct GetAccountEasyPayUseCaseInput {
    public enum EasyPayType {
        case transaction
        case transfer
    }
    public let type: EasyPayType
    
    public init(type: EasyPayType) {
        self.type = type
    }
}

public struct GetAccountEasyPayUseCaseOkOutput {
    public let accountEasyPay: AccountEasyPay
}
