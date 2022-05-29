import Foundation

public final class GetFinancingUseCase: UseCase<Void, GetFinancingUseCaseOkOutput, StringErrorOutput> {

    private let appConfigRepository: AppConfigRepositoryProtocol

    public init(resolver: DependenciesResolver) {
        self.appConfigRepository = resolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFinancingUseCaseOkOutput, StringErrorOutput> {
        let financingEnabled = appConfigRepository.getBool("enableFinancingZone")
        return UseCaseResponse.ok(GetFinancingUseCaseOkOutput(financingEnabled: financingEnabled ?? false))
    }
}

public struct GetFinancingUseCaseOkOutput {
    public let financingEnabled: Bool
}
