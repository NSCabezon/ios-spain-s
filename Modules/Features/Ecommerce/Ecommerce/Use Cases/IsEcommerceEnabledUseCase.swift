import CoreFoundationLib

public final class IsEcommerceEnabledUseCase: UseCase<Void, IsEcommerceEnabledUseCaseOkOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<IsEcommerceEnabledUseCaseOkOutput, StringErrorOutput> {
        let node = appConfigRepository.getBool(EcommerceConstants.enableEcommerceAppConfig)
        return .ok(IsEcommerceEnabledUseCaseOkOutput(isEnabled: node ?? false))
    }
}

public struct IsEcommerceEnabledUseCaseOkOutput {
    public let isEnabled: Bool
}
