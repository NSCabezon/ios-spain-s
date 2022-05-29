import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
@testable import PersonalArea

class DigitalProfileExecutorWrapperTests: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private var mockDataInjector = MockDataInjector()

    override func setUp() {
        self.defaultRegistration()
        self.setupDependencies()
    }

    func test_configuredPoints_withAllActiveValues_shouldBe28() {
        let totalPoints = getTotalPoints()
        let activeValues = 28
        XCTAssert(totalPoints == activeValues)
    }
}

private extension DigitalProfileExecutorWrapperTests {
    func getTotalPoints() -> Int {
        let sut = self.generateSut()
        guard let response = try? sut.execute() else { return 0 }
        let totalPoints = response.configuredItems
            .map({$0.value()})
            .reduce(0, +)
        return totalPoints
    }

    func setupDependencies() {
        self.dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: resolver.resolve(), saveUserPreferences: false)
        }
        self.dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            return GlobalPositionMock(
                self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
                cardsData: [:],
                temporallyOffCards: [:],
                inactiveCards: [:],
                cardBalances: [:]
            )
        }
        self.dependencies.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        self.dependencies.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.dependencies.register(for: ApplePayEnrollmentManagerProtocol.self) { _ in
            return ApplePayEnrollmentManagerMock()
        }
        self.dependencies.register(for: PushNotificationPermissionsManagerProtocol.self) { _ in
            return PushNotificationPermissionsManagerMock()
        }
        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
    }
    
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }

    func generateInput() -> DigitalProfileExecutorWrapperInput {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependencies.resolve()
        let provider: BSANManagersProvider = self.dependencies.resolve()
        let appRepositoryProtocol: AppRepositoryProtocol = self.dependencies.resolve()
        let appConfigRepository: AppConfigRepositoryProtocol =  self.dependencies.resolve()
        let applePayEnrollmentManager: ApplePayEnrollmentManagerProtocol = self.dependencies.resolve()
        let pushNotificationPermissionsManager: PushNotificationPermissionsManagerProtocol = self.dependencies.resolve()
        return DigitalProfileExecutorWrapperInput(globalPosition: globalPosition,
                                                  provider: provider,
                                                  pushNotificationPermissionsManager: pushNotificationPermissionsManager,
                                                  locationPermissionsManager: nil,
                                                  localAuthPermissionsManager: nil,
                                                  appRepositoryProtocol: appRepositoryProtocol,
                                                  appConfigRepository: appConfigRepository,
                                                  applePayEnrollmentManager: applePayEnrollmentManager,
                                                  dependenciesResolver: self.dependencies)
    }

    func generateSut() -> DigitalProfileExecutorWrapper {
        return DigitalProfileExecutorWrapper(input: generateInput())
    }
}

public class ApplePayEnrollmentManagerMock: ApplePayEnrollmentManagerProtocol {
    public func enrollCard(_ card: CardEntity,
                           detail: CardDetailEntity,
                           otpValidation: OTPValidationEntity,
                           otpCode: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {}

    public func alreadyAddedPaymentPasses() -> [String] {
        return []
    }

    public func isEnrollingCardEnabled() -> Bool {
        return true
    }
}

class PushNotificationPermissionsManagerMock: PushNotificationPermissionsManagerProtocol {
    var completionRegisteredDevice: (() -> Void)?
    
    func getAuthStatus(completion: @escaping (AuthStatus) -> Void) {
        completion(.authorized)
    }
    
    func checkAccess(_ completion: (() -> Void)?) {
        completion?()
    }
    
    func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func requestAccess(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func isAlreadySet(_ completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
