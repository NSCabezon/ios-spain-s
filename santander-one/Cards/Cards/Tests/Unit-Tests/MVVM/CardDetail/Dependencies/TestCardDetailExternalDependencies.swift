import UI
import Foundation
import CoreDomain
import CoreFoundationLib
import CoreTestData
import OpenCombine
import SANLegacyLibrary

@testable import Cards

struct TestCardDetailExternalDependencies: CardExternalDependenciesResolver {
    let globalPositionRepository: MockGlobalPositionDataRepository
    let injector: MockDataInjector
    let mockExpensesUseCase = MockGetCardsExpensesCalculationUseCase()
    let coreDependencies = DefaultCoreDependencies()
    
    init(injector: MockDataInjector) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> CardRepository {
        MockCardRepository(mockDataInjector: injector)
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    
    func privateMenuCoordinator() -> Coordinator {
        fatalError()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        fatalError()
    }
    
    func resolve() -> TimeManager {
        fatalError()
    }
    
    func resolve() -> GetCardsExpensesCalculationUseCase {
        return mockExpensesUseCase
    }
    
    func resolve() -> CardHomeActionModifier {
        fatalError()
    }
    
    func resolve() -> BaseURLProvider {
        BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
    }
    
    func resolve() -> [CardTextColorEntity] {
        []
    }
    
    func moreOperativesCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    
    func cardDetailExternalDependenciesResolver() -> CardDetailExternalDependenciesResolver {
        self
    }
    
    func cardExternalDependenciesResolver() -> CardExternalDependenciesResolver {
        self
    }
    
    func showPANCoordinator() -> BindableCoordinator {
        return ToastCoordinator("")
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository

    }
    
    func resolve() -> GlobalPositionReloader {
        fatalError()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
    
    func resolve() -> BooleanFeatureFlag {
        fatalError()
    }
    
    func resolve() -> StringLoader {
        fatalError()
    }
    
    func cardActivateCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func cardCVVCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardOnCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardInstantCashCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardDelayPaymentCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardPayOffCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardChargeDischargeCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardPinCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardBlockCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardWithdrawMoneyWithCodeCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardMobileTopUpCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardCesCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardPdfExtractCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardHistoricPdfExtractCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardPdfDetailCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardFractionablePurchasesCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardModifyLimitsCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardSolidarityRoundingCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardChangePaymentMethodCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardHireCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardDivideCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardShareCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardFraudCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardChargePrepaidCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardApplePayCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardDuplicatedCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardSuscriptionCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardConfigureCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardSubscriptionsCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardFinancingBillsCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardCustomeCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func cardOffCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func offersCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func easyPayCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func resolve() -> LocalAppConfig {
        LocalAppConfigMock()
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        fatalError()
    }
    
    func resolve() -> CoreDependencies {
        coreDependencies
    }
    
    func resolve() -> PullOffersInterpreter {
        PullOffersInterpreterMock()
    }
    
    func resolve() -> EngineInterface {
        fatalError()
    }
}
