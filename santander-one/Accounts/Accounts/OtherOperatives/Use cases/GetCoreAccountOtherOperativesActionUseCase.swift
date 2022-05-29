import CoreFoundationLib

class GetCoreAccountOtherOperativesActionUseCase: UseCase<GetAccountOtherOperativesActionUseCaseInput, GetAccountOtherOperativesActionUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    private let defaultEveryDayOperatives: [AccountActionType] = [
            .internalTransfer, .favoriteTransfer,
            .payTax, .returnBill, .changeDomicileReceipt,
            .cancelBill]
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountOtherOperativesActionUseCaseInput) throws -> UseCaseResponse<GetAccountOtherOperativesActionUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetAccountOtherOperativesActionUseCaseOkOutput(everyDayOperatives: defaultEveryDayOperatives, otherOperativeActions: [], adjustAccounts: [], queriesActions: [], contractActions: [], officeArrangementActions: []))
    }
}

extension GetCoreAccountOtherOperativesActionUseCase: GetAccountOtherOperativesActionUseCaseProtocol {}
