import SANLegacyLibrary
import CoreFoundationLib

class SetupCancelDirectBillingUseCase: SetupUseCase<SetupCancelDirectBillingUseCaseInput, SetupCancelDirectBillingUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(repository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
        super.init(appConfigRepository: repository)
    }
    
    override func executeUseCase(requestValues: SetupCancelDirectBillingUseCaseInput) throws -> UseCaseResponse<SetupCancelDirectBillingUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let bill = requestValues.bill
        let ibanDTO = IBANDTO(ibanString: bill.linkedAccount)
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: ibanDTO)
        guard accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData()  else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(SetupCancelDirectBillingUseCaseOkOutput(operativeConfig: operativeConfig, account: Account(dto: accountDTO)))
    }
}

struct SetupCancelDirectBillingUseCaseInput {
    let bill: Bill
}

struct SetupCancelDirectBillingUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let account: Account
}
extension SetupCancelDirectBillingUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}
extension SetupCancelDirectBillingUseCase: AssociatedAccountRetriever {}
