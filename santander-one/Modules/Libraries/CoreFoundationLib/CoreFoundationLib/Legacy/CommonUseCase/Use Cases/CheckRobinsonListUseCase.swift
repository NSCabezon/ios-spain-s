import SANLegacyLibrary

public class CheckRobinsonListUseCase: UseCase<Void, CheckRobinsonListUseCaseOkOutput, StringErrorOutput> {
    
    private let resolver: DependenciesResolver
    private let robinsonUserCode = "2"

    public init(resolver: DependenciesResolver) {
        self.resolver = resolver
    }

    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<CheckRobinsonListUseCaseOkOutput, StringErrorOutput> {
        let bsanManagersProvider: BSANManagersProvider = resolver.resolve(for: BSANManagersProvider.self)
        let bsanPullOffersManager = bsanManagersProvider.getBsanPullOffersManager()
        let isInList = try bsanPullOffersManager.getCampaigns().getResponseData()??
            .filter({ $0 == robinsonUserCode })
            .first != nil
        return UseCaseResponse.ok(CheckRobinsonListUseCaseOkOutput(isInRobinsonList: isInList))
    }
}

public struct CheckRobinsonListUseCaseOkOutput {
    public let isInRobinsonList: Bool
}
