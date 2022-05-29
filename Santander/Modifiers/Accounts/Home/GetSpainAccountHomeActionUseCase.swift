import SANLegacyLibrary
import CoreFoundationLib
import Account

final class GetSpainAccountHomeActionUseCase: UseCase<GetAccountHomeActionUseCaseInput, GetAccountHomeActionUseCaseOkOutput, StringErrorOutput> {
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
    
    override func executeUseCase(requestValues: GetAccountHomeActionUseCaseInput) throws -> UseCaseResponse<GetAccountHomeActionUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetAccountHomeActionUseCaseOkOutput(actions: [.transfer, bizum, .payBill, .billsAndTaxes]))
    }
}

extension GetSpainAccountHomeActionUseCase: GetAccountHomeActionUseCaseProtocol {}
