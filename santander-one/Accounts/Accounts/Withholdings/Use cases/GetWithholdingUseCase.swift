import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetWithholdingUseCase: UseCase<GetWithholdingInput, GetWithholdingOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    private let appConfig: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: GetWithholdingInput) throws -> UseCaseResponse<GetWithholdingOkOutput, StringErrorOutput> {
        guard appConfig.getBool(AccountsConstants.IsEnableWithholdingList) == true else {
            return .ok(GetWithholdingOkOutput(withholding: .disabled))
        }
        let accountsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanAccountsManager()
        let response = try accountsManager.getWithholdingList(iban: requestValues.account.dto.iban?.description ?? "", currency: requestValues.account.dto.balance?.currency?.currencyName ?? "")
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        
        let entity = WithholdingListEntity(data)
        return .ok(GetWithholdingOkOutput(withholding: .withholding(entity)))
    }
}

struct GetWithholdingInput {
    let account: AccountDetailEntity
}

struct GetWithholdingOkOutput {
    let withholding: Withholding
}

enum Withholding {
    case disabled
    case withholding(WithholdingListEntity)
}
