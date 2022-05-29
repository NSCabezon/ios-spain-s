import XCTest
import QuickSetup
import CoreFoundationLib
import SANLibraryV3
import Localization
import CoreTestData
@testable import Ecommerce

class FintechConfirmAccessKeyUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let appConfigRepository: AppConfigRepositoryProtocol = MockAppConfigRepository(mockDataInjector: MockDataInjector(mockDataProvider: MockDataProvider()))
    private let appRepository: AppRepositoryMock = AppRepositoryMock()
    private var quickSetup: QuickSetup = QuickSetup.shared
    private var sut: FintechConfirmAccessKeyUseCase!
    private let localAppConfig: LocalAppConfig = LocalAppConfigMock()
    private var useCaseHandlerMock: UseCaseHandler = UseCaseHandlerMock()
    private lazy var getLanguagesSelectionUseCaseMock: GetLanguagesSelectionUseCase = { GetLanguagesSelectionUseCaseMock(dependencies: dependencies)
    }()

    override func setUpWithError() throws {
        self.setDependencies()
        self.quickSetup.setEnviroment(BSANEnvironments.environmentPre)
        self.quickSetup.doLogin(withUser: .demo)
        self.sut = FintechConfirmAccessKeyUseCase(dependenciesResolver: dependencies)
    }

    override func tearDownWithError() throws {
        quickSetup.setDemoAnswers([:])
    }

    func test_useCase_withSuccessResponse_shouldReturnSuccess() {
        quickSetup.setDemoAnswers(["login-tpp-app": 0])
        do {
            let authenticationParams = FintechUserAuthenticationMock()
            let userInfo = FintechUserInfoAccessKeyMock()
            let input = FintechConfirmAccessKeyUseCaseInput(userAuthentication: authenticationParams, userInfo: userInfo)
            let response = try sut.executeUseCase(requestValues: input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("FintechConfirmAccessKeyUseCase: throw")
        }
    }

    func test_useCase_withExpiredToken_error400_shouldReturnFailure() {
        quickSetup.setDemoAnswers(["login-tpp-app": 1])
        do {
            let authenticationParams = FintechUserAuthenticationMock()
            let userInfo = FintechUserInfoAccessKeyMock()
            let input = FintechConfirmAccessKeyUseCaseInput(userAuthentication: authenticationParams, userInfo: userInfo)
            let response = try sut.executeUseCase(requestValues: input)
            let output = try response.getErrorResult()
            XCTAssertTrue(output.getErrorDesc() == "La contraseña ha expirado")
        } catch {
            XCTFail("FintechConfirmAccessKeyUseCase: throws")
        }
    }

    func test_useCase_withBadRequest_error401_shouldReturnFailure() {
        quickSetup.setDemoAnswers(["login-tpp-app": 2])
        do {
            let authenticationParams = FintechUserAuthenticationMock()
            let userInfo = FintechUserInfoAccessKeyMock()
            let input = FintechConfirmAccessKeyUseCaseInput(userAuthentication: authenticationParams, userInfo: userInfo)
            let response = try sut.executeUseCase(requestValues: input)
            let output = try response.getErrorResult()
            XCTAssertTrue(output.getErrorDesc() == "Autenticación incorrecta")
        } catch {
            XCTFail("FintechConfirmAccessKeyUseCase: throws")
        }
    }
}

private extension FintechConfirmAccessKeyUseCaseTest {
    func setDependencies() {
        dependencies.register(for: BSANManagersProvider.self, with: { _ in
            self.quickSetup.managersProvider
        })
        dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            self.appConfigRepository
        }
        dependencies.register(for: AppRepositoryProtocol.self) { _ in
            self.appRepository
        }
        dependencies.register(for: LocalAppConfig.self) { _ in
            self.localAppConfig
        }
        dependencies.register(for: GetLanguagesSelectionUseCaseProtocol.self) { _ in
            self.getLanguagesSelectionUseCaseMock
        }
        dependencies.register(for: UseCaseHandler.self) { _ in
            self.useCaseHandlerMock
        }
        dependencies.register(for: StringLoader.self) { [self] _ in
            let locale = LocaleManager(dependencies: dependencies)
            locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
            return locale
        }
    }
}
