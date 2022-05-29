//
//  SessionDependencies.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 29/9/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import RetailLegacy
import Localization
import Login
import FinantialTimeline

final class SessionHandler {
    
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(dependencieEngine: DependenciesResolver & DependenciesInjector) {
        self.dependenciesEngine = dependencieEngine
        self.registerDependencies()
    }
}

private extension SessionHandler {
    
    struct SessionDataResult {
        let isSuperSpeedCardEnabled: Bool
        var cards: [CardEntity] = []
    }
    
    func registerDependencies() {
        self.dependenciesEngine.register(for: LoadGlobalPositionUseCase.self) { resolver in
            return SpainLoadGlobalPositionUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetScaLoginStateUseCase.self) { resolver in
            return GetScaLoginStateUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetSuperSpeedCardsStateUseCase.self) { resolver in
            return GetSuperSpeedCardsStateUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetSuperSpeedCardsUseCase.self) { resolver in
            return GetSuperSpeedCardsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadCardsDataUseCase.self) { resolver in
            return LoadCardsDataUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCreditCardsUseCase.self) { resolver in
            return GetCreditCardsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadInactiveCardsUseCase.self) { resolver in
            return LoadInactiveCardsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadInactiveCardsTempUseCase.self) { resolver in
            return LoadInactiveCardsTempUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetECashCardsWithoutDataDomainCase.self) { resolver in
            return GetECashCardsWithoutDataDomainCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCreditCardsUseCase.self) { resolver in
            return GetCreditCardsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadCardDetailUseCase.self) { resolver in
            return LoadCardDetailUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadVariableIncomePortfoliosUseCase.self) { resolver in
            return LoadVariableIncomePortfoliosUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadPortfoliosUseCase.self) { resolver in
            return LoadPortfoliosUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadUserSegmentUseCase.self) { resolver in
            return LoadUserSegmentUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CheckRobinsonListUseCase.self) { resolver in
            return CheckRobinsonListUseCase(resolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadTimeLineConfigurationUseCase.self) { resolver in
            return LoadTimeLineConfigurationUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadCardsListApplePayStatusUseCase.self) { resolver in
            return LoadCardsListApplePayStatusUseCase(dependenciesResolver: resolver)
        }
    }
    
    func updateResult(_ result: inout SessionDataResult, output: GetECashCardsWithoutDataDomainCaseOkOutput, input: Void) {
        result.cards += output.cards.map(CardEntity.init)
    }
    
    func updateResult(_ result: inout SessionDataResult, output: GetCreditCardsUseCaseOkOutput, input: Void) {
        result.cards += output.cards
    }
    
    func loadSuperSpeedCards(result: SessionDataResult) -> ScenarioHandler<Void, StringErrorOutput> {
        return scenario(for: GetSuperSpeedCardsUseCase.self)
            .executeIgnoringError(on: dependenciesEngine.resolve())
            .map({ $0 })
    }
    
    func loadNoSuperSpeedCards(result: SessionDataResult) -> ScenarioHandler<Void, StringErrorOutput> {
        return MultiScenario(handledOn: dependenciesEngine.resolve(), initialValue: result)
            .addScenario(scenario(for: LoadCardsDataUseCase.self), isMandatory: false)
            .addScenario(scenario(for: GetCreditCardsUseCase.self), isMandatory: false)
            .addScenario(scenario(for: LoadInactiveCardsUseCase.self), isMandatory: false)
            .addScenario(scenario(for: LoadInactiveCardsTempUseCase.self), isMandatory: false)
            .asScenarioHandler()
            .then(handler: loadCards)
    }
    
    func loadCards(result: SessionDataResult) -> ScenarioHandler<Void, StringErrorOutput> {
        return MultiScenario(handledOn: dependenciesEngine.resolve(), initialValue: result)
            .addScenario(scenario(for: GetECashCardsWithoutDataDomainCase.self), isMandatory: false, onSuccess: updateResult)
            .addScenario(scenario(for: GetCreditCardsUseCase.self), isMandatory: false, onSuccess: updateResult)
            .asScenarioHandler()
            .then(multiScenario: loadCardDetails)
    }
    
    func loadCardDetails(result: SessionDataResult) -> MultiScenario<Void, StringErrorOutput> {
        let scenarios = result.cards.map { card in
            scenario(for: LoadCardDetailUseCase.self, input: LoadCardDetailUseCaseInput(card: card.dto))
        }
        return MultiScenario(handledOn: dependenciesEngine.resolve())
            .addScenarios(scenarios, areMandatory: true)
    }
    
    func loadPortfolio(_ result: LoadUserSegmentUseCaseOkOutput?) -> ScenarioHandler<Void, StringErrorOutput> {
        guard let isSelect = result?.isSelect, isSelect == true else { return self.loadPbPortfolio() }
        return self.loadSelectPortfolio()
    }
    
    func loadSelectPortfolio() -> ScenarioHandler<Void, StringErrorOutput> {
        let portfolio = scenario(for: LoadPortfoliosUseCase.self, input: LoadPortfoliosUseCaseInput(userTypePortfolio: .portfolioSelect))
        let income = scenario(for: LoadVariableIncomePortfoliosUseCase.self, input: LoadVariableIncomePortfoliosUseCaseInput(userTypePortfolio: .portfolioSelect))
        _ = scenario(for: LoadUserSegmentUseCase.self)
        return MultiScenario(handledOn: dependenciesEngine.resolve())
            .addScenario(portfolio)
            .addScenario(income)
            .asScenarioHandler()
    }
    
    func loadPbPortfolio() -> ScenarioHandler<Void, StringErrorOutput> {
        let portfolio = scenario(for: LoadPortfoliosUseCase.self, input: LoadPortfoliosUseCaseInput(userTypePortfolio: .portfolioPb))
        let income = scenario(for: LoadVariableIncomePortfoliosUseCase.self, input: LoadVariableIncomePortfoliosUseCaseInput(userTypePortfolio: .portfolioPb))
        return MultiScenario(handledOn: dependenciesEngine.resolve())
            .addScenario(portfolio)
            .addScenario(income)
            .asScenarioHandler()
    }
    
    func scenario<Output, Error: StringErrorOutput, UC: UseCase<Void, Output, Error>>(for useCase: UC.Type) -> Scenario<Void, Output, Error> {
        return Scenario(useCase: dependenciesEngine.resolve(for: UC.self))
    }
    
    func scenario<Output, Error: StringErrorOutput, Input, UC: UseCase<Input, Output, Error>>(for useCase: UC.Type, input: Input) -> Scenario<Input, Output, Error> {
        return Scenario(useCase: dependenciesEngine.resolve(for: UC.self), input: input)
    }
    
    func handleSCALoginState(_ state: GetScaLoginStateUseCaseOkOutput?) {
        let loginStateHelper = dependenciesEngine.resolve(for: LoginSessionStateHelper.self)
        switch state {
        case .notApply?:
            break
        case .temporaryLock?:
            DispatchQueue.main.async {
                loginStateHelper.onBloqued()
            }
        case .requestOtp?:
            self.updateLanguageAndContinue {
                loginStateHelper.onOtp(firsTime: false)
            }
        case .requestOtpFirstTime?:
            self.updateLanguageAndContinue {
                loginStateHelper.onOtp(firsTime: true)
            }
        case .none:
            break
        }
    }
    
    func updateLanguageAndContinue(completion: @escaping () -> Void) {
        getLanguages()
            .execute(on: dependenciesEngine.resolve())
            .onSuccess { [weak self] result in
                self?.didFinishLoadLanguages(result)
                completion()
            }
    }
    
    func getLanguages() -> Scenario<Void, GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        return Scenario(useCase: dependenciesEngine.resolve(for: GetLanguagesSelectionUseCaseProtocol.self))
    }
    
    func didFinishLoadLanguages(_ result: GetLanguagesSelectionUseCaseOkOutput) {
        dependenciesEngine.resolve(for: StringLoader.self).updateCurrentLanguage(language: result.current)
    }
    
    private func shouldPullOffers(_ inInRobinsonList: Bool?) -> Bool {
        guard let isInRobinsonList = inInRobinsonList else {
            return false
        }
        return !isInRobinsonList
    }
    
    private func registerTimeLine(_ result: LoadTimeLineConfigurationUseCaseOkOutput?) {
        guard let unwrappedResult = result else { return }
        let defaultCurrency = MoneyDecorator.defaultCurrency
        let configuration = FinantialTimeline.Configuration.native(
            host: unwrappedResult.serviceURL,
            configurationURL: unwrappedResult.configurationURL,
            currencySymbols: ["EUR": defaultCurrency],
            authorization: .token(unwrappedResult.token),
            timeLineDelegate: nil,
            actions: [],
            dependenciesResolver: dependenciesEngine,
            language: dependenciesEngine.resolve(forOptionalType: StringLoader.self)?.getCurrentLanguage().languageType.rawValue ?? "en"
        )
        TimeLine.setup(configuration: configuration)
        dependenciesEngine.register(for: "TimeLineView", type: UIView.self) { _ in
            let view = TimeLine.loadWidget(days: 30)
            view.backgroundColor = .white
            return view
        }
    }
}

extension SessionHandler: SessionDataManagerModifier {
    
    func performAfterGlobalPosition(_ globalPosition: GlobalPositionRepresentable) -> ScenarioHandler<Void, StringErrorOutput>? {
        let superSpeedScenario = scenario(for: GetSuperSpeedCardsStateUseCase.self)
        let userSegmentScenario = scenario(for: LoadUserSegmentUseCase.self)
        return MultiScenario(handledOn: dependenciesEngine.resolve(), initialValue: ())
            .addScenario(superSpeedScenario, isMandatory: false, onSuccess: { _, output, _ in
                let result = SessionDataResult(isSuperSpeedCardEnabled: output.isSuperSpeedCardEnabled)
                if result.isSuperSpeedCardEnabled {
                    _ = self.loadSuperSpeedCards(result: result)
                } else {
                    _ = self.loadNoSuperSpeedCards(result: result)
                }
                _ = userSegmentScenario
                    .execute(on: self.dependenciesEngine.resolve())
                    .then(handler: self.loadPortfolio)
                    .mapError({ _ in () })
            })
            .asScenarioHandler()
            .mapError({ _ in () })
    }
    
    func performBeforePullOffers() -> ScenarioHandler<Bool, StringErrorOutput>? {
        let loadTimeLine = scenario(for: LoadTimeLineConfigurationUseCase.self)
        let checkRobinsonList = scenario(for: CheckRobinsonListUseCase.self)
        let loadCardsListApplePay = scenario(for: LoadCardsListApplePayStatusUseCase.self)
        return MultiScenario(handledOn: dependenciesEngine.resolve(), initialValue: false)
            .addScenario(loadTimeLine, isMandatory: false, onSuccess: { _, output, _ in
                self.registerTimeLine(output)
            })
            .addScenario(checkRobinsonList, isMandatory: false, onSuccess: { isInRobinsonList, output, _ in
                isInRobinsonList = self.shouldPullOffers(output.isInRobinsonList)
            })
            .addScenario(loadCardsListApplePay, isMandatory: false)
            .asScenarioHandler()
    }
    
    func performBeforeFinishing() ->  ScenarioHandler<Void, StringErrorOutput>? {
        return scenario(for: GetScaLoginStateUseCase.self)
            .executeIgnoringError(on: dependenciesEngine.resolve())
            .onSuccess { [weak self] sca in
                self?.handleSCALoginState(sca)
            }
            .filter({ $0 == .notApply || $0 == .none })
            .map({ _ in return })
    }
}
