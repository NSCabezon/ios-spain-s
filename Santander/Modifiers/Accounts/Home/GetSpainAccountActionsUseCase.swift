import SANLegacyLibrary
import CoreFoundationLib
import Account

class GetSpainAccountActionsUseCase: UseCase<GetAccountActionsUseCaseInput, GetAccountActionsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    private lazy var bizum: AccountActionType = .custome(
        identifier: "bizum",
        accesibilityIdentifier: "accountsHomeBtnBizum",
        trackName: "bizum",
        localizedKey: "accountOption_button_bizum",
        icon: "icnBizum"
    )
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountActionsUseCaseInput) throws -> UseCaseResponse<GetAccountActionsUseCaseOkOutput, StringErrorOutput> {
    
        return .ok(GetAccountActionsUseCaseOkOutput(actions: [.transfer, bizum, .payBill, .billsAndTaxes]))
  
    }
}

extension GetSpainAccountActionsUseCase: GetAccountActionsUseCaseProtocol {}
