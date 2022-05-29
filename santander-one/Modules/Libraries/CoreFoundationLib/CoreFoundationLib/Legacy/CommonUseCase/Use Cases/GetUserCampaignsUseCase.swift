import SANLegacyLibrary

public class GetUserCampaignsUseCase: UseCase<Void, GetUserCampaignsUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfig: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserCampaignsUseCaseOutput, StringErrorOutput> {
        guard
            let userCampaigns = try? provider.getBsanPullOffersManager().getCampaigns().getResponseData() ?? [],
            !userCampaigns.isEmpty
        else { return .error(StringErrorOutput("")) }
        return .ok(GetUserCampaignsUseCaseOutput(campaigns: userCampaigns))
    }
}

public struct GetUserCampaignsUseCaseOutput {
    public let campaigns: [String]
}
