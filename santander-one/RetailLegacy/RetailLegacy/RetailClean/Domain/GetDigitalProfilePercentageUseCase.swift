import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import PersonalArea
import CoreDomain

final class GetDigitalProfilePercentageUseCase: UseCase<GetDigitalProfilePercentageUseCaseInput, GetDigitalProfilePercentageUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: GetDigitalProfilePercentageUseCaseInput) throws -> UseCaseResponse<GetDigitalProfilePercentageUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let appRepository: AppRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let applePayEnrollmentManager = dependenciesResolver.resolve(for: ApplePayEnrollmentManagerProtocol.self)
        let input = DigitalProfileExecutorWrapperInput(globalPosition: globalPosition,
                                                       provider: provider,
                                                       pushNotificationPermissionsManager: requestValues.pushNotificationsManager,
                                                       locationPermissionsManager: requestValues.locationManager,
                                                       localAuthPermissionsManager: requestValues.localAuthentication,
                                                       appRepositoryProtocol: appRepository,
                                                       appConfigRepository: appConfigRepository,
                                                       applePayEnrollmentManager: applePayEnrollmentManager,
                                                       dependenciesResolver: dependenciesResolver)
        let digitalProfileExecutor = DigitalProfileExecutorWrapper(input: input)
        let response = try digitalProfileExecutor.execute()
        return UseCaseResponse.ok(GetDigitalProfilePercentageUseCaseOkOutput(percentage: response.percentage,
                                                                             notConfiguredItems: response.notConfiguredItems))
    }
}

struct GetDigitalProfilePercentageUseCaseInput {
    let pushNotificationsManager: PushNotificationPermissionsManagerProtocol?
    let locationManager: LocationManager
    let localAuthentication: LocalAuthenticationPermissionsManagerProtocol
}

struct GetDigitalProfilePercentageUseCaseOkOutput {
    let percentage: Double
    let notConfiguredItems: [DigitalProfileElemProtocol]
}
