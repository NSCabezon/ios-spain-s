import CoreFoundationLib

class GetCoreAccountHomeActionUseCase: UseCase<GetAccountHomeActionUseCaseInput, GetAccountHomeActionUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    private let defaultAccountHomeActions: [AccountActionType] = [
        .transfer, .payBill, .billsAndTaxes
    ]
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountHomeActionUseCaseInput) throws -> UseCaseResponse<GetAccountHomeActionUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetAccountHomeActionUseCaseOkOutput(actions: defaultAccountHomeActions))
    }
}

extension GetCoreAccountHomeActionUseCase: GetAccountHomeActionUseCaseProtocol {}
