import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class DigitalProfileUseCase: UseCase<Void, DigitalProfileUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<DigitalProfileUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let configuration: PersonalAreaConfiguration = dependenciesResolver.resolve(for: PersonalAreaConfiguration.self)
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let appRepositoryProtocol: AppRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let applePayEnrollmentManager = dependenciesResolver.resolve(for: ApplePayEnrollmentManagerProtocol.self)
        let input = DigitalProfileExecutorWrapperInput(globalPosition: globalPosition,
                                                       provider: provider,
                                                       pushNotificationPermissionsManager: configuration.pushNotificationPermissionsManager,
                                                       locationPermissionsManager: configuration.locationPermissionsManager,
                                                       localAuthPermissionsManager: configuration.localAuthPermissionsManager,
                                                       appRepositoryProtocol: appRepositoryProtocol,
                                                       appConfigRepository: appConfigRepository,
                                                       applePayEnrollmentManager: applePayEnrollmentManager,
                                                       dependenciesResolver: dependenciesResolver)
        let executor = DigitalProfileExecutorWrapper(input: input)
        let response = try executor.execute()
        return UseCaseResponse.ok(DigitalProfileUseCaseOkOutput(percentage: response.percentage,
                                                                category: response.category,
                                                                configuredItems: response.configuredItems,
                                                                notConfiguredItems: response.notConfiguredItems,
                                                                username: response.username,
                                                                userLastname: response.userLastname,
                                                                userImage: response.userImage))
    }
}

struct DigitalProfileUseCaseOkOutput {
    let percentage: Double
    let category: DigitalProfileEnum
    let configuredItems: [DigitalProfileElemProtocol]
    let notConfiguredItems: [DigitalProfileElemProtocol]
    let username: String
    let userLastname: String
    let userImage: Data?
}
