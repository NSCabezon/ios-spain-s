//
//  SessionDataManager.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 9/9/21.
//

import OpenCombine

public protocol SessionDataManagerDelegate: AnyObject {
    func willLoadSession()
}

public protocol SessionDataManagerProcessDelegate: AnyObject {
    func handleProcessEvent(_ event: SessionManagerProcessEvent)
}

public protocol SessionDataManagerModifier: AnyObject {
    func performAfterGlobalPosition(_ globalPosition: GlobalPositionRepresentable) -> ScenarioHandler<Void, StringErrorOutput>?
    func performBeforePullOffers() ->  ScenarioHandler<Bool, StringErrorOutput>?
    func performBeforeFinishing() ->  ScenarioHandler<Void, StringErrorOutput>?
}

public protocol SessionDataManager {
    func loadPublisher() -> AnyPublisher<Void, Error>
    func load()
    func cancel()
    func setDataManagerDelegate(_ delegate: SessionDataManagerDelegate?)
    func setDataManagerProcessDelegate(_ delegate: SessionDataManagerProcessDelegate?)
    var event: AnyPublisher<SessionManagerProcessEvent, Error> { get }
}

public final class DefaultSessionDataManager {
    
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: SessionDataManagerDelegate?
    private weak var processDelegate: SessionDataManagerProcessDelegate?
    private weak var modifier: SessionDataManagerModifier?
    private let eventSubject = PassthroughSubject<SessionManagerProcessEvent, Error>()
    private var subject = PassthroughSubject<Void, Error>()
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = Dependencies(dependenciesResolver: dependenciesResolver).dependenciesEngine
        self.modifier = dependenciesResolver.resolve(forOptionalType: SessionDataManagerModifier.self)
    }
}

private extension DefaultSessionDataManager {
    
    struct Dependencies {
        
        let dependenciesEngine: DependenciesResolver & DependenciesInjector
        
        init(dependenciesResolver: DependenciesResolver) {
            dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
            setup()
        }
        
        func setup() {
            dependenciesEngine.register(for: LoadCampaignsUseCase.self) { resolver in
                return LoadCampaignsUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: LoadCMCSignatureUseCase.self) { resolver in
                return LoadCMCSignatureUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: LoadCMPSUseCase.self) { resolver in
                return LoadCMPSUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: LoadPullOffersVarsUseCaseProtocol.self) { resolver in
                return DefaultLoadPullOffersVarsUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: SetTipsUseCase.self) { resolver in
                return SetTipsUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: CalculateLocationsUseCase.self) { resolver in
                return CalculateLocationsUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: MetricsLogInUserUseCase.self) { resolver in
                return MetricsLogInUserUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: SetPersistedUserUseCase.self) { resolver in
                return SetPersistedUserUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: CleanSessionUseCaseProtocol.self) { resolver in
                return CleanSessionUseCase(dependenciesResolver: resolver)
            }
            dependenciesEngine.register(for: LoadManagersUseCase.self) { resolver in
                return LoadManagersUseCase(dependenciesResolver: resolver)
            }
        }
    }
}

extension DefaultSessionDataManager: SessionDataManager {
    
    public func loadPublisher() -> AnyPublisher<Void, Error> {
        subject = PassthroughSubject()
        load()
        return subject.eraseToAnyPublisher()
    }
    
    public func load() {
        delegate?.willLoadSession()
        cleanSession()
            .execute(on: dependenciesResolver.resolve())
            .thenIgnoringPreviousResult(scenario: loadGlobalPosition).onSuccess(didLoadGlobalPosition)
            .then(handler: afterGlobalPosition, outputWhenNil: ())
            .then(handler: beforePullOffers, outputWhenNil: false)
            .then(handler: loadPullOffers, outputWhenNil: ())
            .thenIgnoringError(scenario: setPersistedUser).map({ $0 })
            .thenIgnoringError(scenario: setOnUserMetrics).map({ $0 })
            .thenIgnoringError(scenario: getLanguages).onSuccess(didFinishLoadLanguages).map({ _ in return })
            .then(handler: beforeFinishing, outputWhenNil: ())
            .onSuccess(didFinishLoad)
            .onError(didFailWithError)
    }
    
    public func cancel() {
        dependenciesResolver.resolve(for: UseCaseHandler.self).stopAll()
    }
    
    public func setDataManagerDelegate(_ delegate: SessionDataManagerDelegate?) {
        self.delegate = delegate
    }
    
    public func setDataManagerProcessDelegate(_ delegate: SessionDataManagerProcessDelegate?) {
        self.processDelegate = delegate
    }
    
    public var event: AnyPublisher<SessionManagerProcessEvent, Error> {
        self.eventSubject.eraseToAnyPublisher()
    }

}

private extension DefaultSessionDataManager {
    
    func afterGlobalPosition(result: LoadGlobalPositionUseCaseOKOutput) -> ScenarioHandler<Void, StringErrorOutput>? {
        loadCampaignsAndUserData()
        return modifier?.performAfterGlobalPosition(result.globalPosition)
    }
    
    func beforePullOffers() -> ScenarioHandler<Bool, StringErrorOutput>? {
        return modifier?.performBeforePullOffers()
    }
    
    func beforeFinishing() -> ScenarioHandler<Void, StringErrorOutput>? {
        return modifier?.performBeforeFinishing()
    }
    
    func loadCampaignsAndUserData() -> MultiScenario<Void, StringErrorOutput> {
        return MultiScenario(handledOn: dependenciesResolver.resolve())
            .addScenario(loadCampaigns(), isMandatory: false)
            .addScenario(loadCMCSignature(), isMandatory: false)
            .addScenario(loadCMPS(), isMandatory: false)
            .addScenario(loadManagers(), isMandatory: false)
    }
    
    func loadPullOffers(shouldLoadPullOffers: Bool) -> ScenarioHandler<Void, StringErrorOutput>? {
        if shouldLoadPullOffers {
            return loadLocalVars()
                .execute(on: dependenciesResolver.resolve())
                .thenIgnoringPreviousResult(scenario: calculateTips)
                .thenIgnoringPreviousResult(scenario: calculateLocations)
                .mapError({ _ in return })
        } else {
            return nil
        }
    }
    
    func loadManagers() -> ScenarioHandler<Void, StringErrorOutput>? {
        return loadManagers()
            .execute(on: dependenciesResolver.resolve())
            .mapError({ _ in return })
    }
    
    func didFailWithError(_ error: UseCaseError<StringErrorOutput>) {
        switch error {
        case .error:
            sendEvent(.fail(error: .other(message: error.getErrorDesc() ?? "")))
        case .generic:
            sendEvent(.fail(error: .generic))
        case .intern:
            sendEvent(.fail(error: .intern))
        case .networkUnavailable:
            sendEvent(.fail(error: .networkUnavailable))
        case .unauthorized:
            sendEvent(.fail(error: .unauthorized))
        }
        subject.send(completion: .failure(error))
    }
    
    func didLoadGlobalPosition(_ result: LoadGlobalPositionUseCaseOKOutput) {
        let isPb = result.globalPosition.isPb ?? false
        let globalPositionName = result.globalPosition.clientNameWithoutSurname ?? result.globalPosition.fullName
        sendEvent(.updateLoadingMessage(isPb: isPb, globalPositionName: globalPositionName))
    }
    
    func didFinishLoad() {
        sendEvent(.loadDataSuccess)
        subject.send()
        subject.send(completion: .finished)
    }
    
    func didFinishLoadLanguages(_ result: GetLanguagesSelectionUseCaseOkOutput?) {
        guard let language = result?.current else { return }
        dependenciesResolver.resolve(for: StringLoader.self).updateCurrentLanguage(language: language)
    }
}

// MARK: - Scenarios

private extension DefaultSessionDataManager {
    
    func loadCampaigns() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: LoadCampaignsUseCase.self))
    }
    
    func loadCMCSignature() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: LoadCMCSignatureUseCase.self))
    }
    
    func loadCMPS() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: LoadCMPSUseCase.self))
    }
    
    func loadLocalVars() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(firstTypeOf: LoadPullOffersVarsUseCaseProtocol.self))
    }
    
    func calculateTips() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: SetTipsUseCase.self))
    }
    
    func calculateLocations() -> Scenario<CalculateLocationsUseCaseInput, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: CalculateLocationsUseCase.self), input: CalculateLocationsUseCaseInput())
    }
    
    func setOnUserMetrics() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: MetricsLogInUserUseCase.self))
    }
    
    func setPersistedUser() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: SetPersistedUserUseCase.self))
    }
    
    func loadGlobalPosition() -> Scenario<Void, LoadGlobalPositionUseCaseOKOutput, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(firstTypeOf: LoadGlobalPositionUseCase.self))
    }
    
    func getLanguages() -> Scenario<Void, GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: GetLanguagesSelectionUseCaseProtocol.self))
    }
    
    func cleanSession() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(for: CleanSessionUseCaseProtocol.self))
    }
    
    func loadManagers() -> Scenario<Void, Void, StringErrorOutput> {
        return Scenario(useCase: dependenciesResolver.resolve(firstTypeOf: LoadManagersUseCase.self))
    }
    
    func sendEvent(_ event: SessionManagerProcessEvent) {
        processDelegate?.handleProcessEvent(event)
        if case let .fail(error) = event {
            eventSubject.send(completion: .failure(error))
        } else {
            eventSubject.send(event)
        }
    }
}
