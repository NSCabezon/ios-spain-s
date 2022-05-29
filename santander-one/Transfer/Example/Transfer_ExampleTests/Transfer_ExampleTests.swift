import XCTest
import CoreFoundationLib
import QuickSetup
import UI
import CoreTestData
import SANLegacyLibrary
@testable import Transfer

class PreSetupInternalTransferUseCaseTests: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: PreSetupInternalTransferUseCase!

    override func setUp() {
        self.defaultRegistration()
        self.setupDependencies()
        self.sut = PreSetupInternalTransferUseCase(dependenciesResolver: dependenciesResolver)
    }

    override func tearDown() {
        self.sut = nil
    }

    func test_outputUseCase_shoul_sameToNotVisibleAccounts() {
        guard let output = try? self.sut.executeUseCase(requestValues: Void()).getOkResult() else {
            return XCTFail()
        }
        XCTAssert(output.accountNotVisibles.count == 0)
    }
    
    func test_historical_button_enabled() {
        let isPortugal = self.dependenciesResolver.resolve(for: LocalAppConfig.self).isPortugal
        let isEnabledHistorical = self.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledHistorical
        if isPortugal {
            XCTAssertFalse(isEnabledHistorical)
        } else {
            XCTAssertTrue(isEnabledHistorical)
        }
    }
}

private extension PreSetupInternalTransferUseCaseTests {
    
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }

    func setupDependencies() {
        self.dependenciesResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return GlobalPositionMock(
                self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
                cardsData: [:],
                temporallyOffCards: [:],
                inactiveCards: [:],
                cardBalances: [:]
            )
        }
        self.dependenciesResolver.register(for: BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        self.dependenciesResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: resolver.resolve(), saveUserPreferences: false)
        }
        self.dependenciesResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.dependenciesResolver.register(for: FaqsRepositoryProtocol.self) { _ in
            return FaqsRepository()
        }
        self.dependenciesResolver.register(for: LocalAppConfig.self) { _ in
            let localAppConfigMock = LocalAppConfigMock()
            localAppConfigMock.isPortugal = true
            return localAppConfigMock
        }
    }
}

struct FaqsRepository: FaqsRepositoryProtocol {
    func getFaqsList(_ type: FaqsType) -> [FaqDTO] {
        return []
    }

    func getFaqsList() -> FaqsListDTO? {
        return nil
    }
}
