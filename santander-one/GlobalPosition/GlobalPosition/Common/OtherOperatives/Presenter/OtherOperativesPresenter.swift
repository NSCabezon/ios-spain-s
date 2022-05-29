//
//  OtherOperativesPresenter.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 30/01/2020.
//

import CoreDomain
import CoreFoundationLib
import Foundation
import Cards

protocol OtherOperativesPresenterProtocol: AnyObject {
    var view: OtherOperativesViewProtocol? {get set}
    func finishAndDismissView()
    func viewDidLoad()
    func updateActions(withText text: String?)
    func didSelectAction(indentifier: String?)
    func didSelectAction(identifier: String?, type: GlobalSearchActionViewType)
}

final class OtherOperativesPresenter {
    private let dependenciesResolver: DependenciesResolver
    private var wrapper: OtherOperativesWrapper?
    private var dataManager: PGDataManager?
    private var selectedGP: GlobalPositionOptionEntity?
    weak var view: OtherOperativesViewProtocol?
    
    private var timer: Timer?
    private var searchedTerm: String = ""
    
    private var useCaseOutput: GlobalSearchUseCaseOkOutput?
    private var searchKeywordsUseCaseOutput: GetSearchKeywordsUseCaseOkOutput?
    private var currentActions: [([AllOperativesViewModel], String?)] = []
    private var currentSearch: OtherOperativesSearchViewModel?
    
    var getGlobalSearchUseCase: GlobalSearchUseCase {
        self.dependenciesResolver.resolve(for: GlobalSearchUseCase.self)
    }
    
    var getGlobalSearchKeywordsUseCase: GetSearchKeywordsUseCase {
        self.dependenciesResolver.resolve(for: GetSearchKeywordsUseCase.self)
    }
    
    private var otherOperativesCoordinator: OtherOperativesCoordinator {
        self.dependenciesResolver.resolve(for: OtherOperativesCoordinator.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var locations: [PullOfferLocation] {
        return self.getAllLocations()
    }
    
    // MARK: - Public
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.dataManager = PGDataManager(resolver: self.dependenciesResolver)
    }
    
    func didSelectAction(_ action: Any, _ entity: AllOperatives) {
        trackEvent(action)
        view?.endEditing()
        if let action = action as? AccountOperativeActionTypeProtocol, case .custom(let customAction) = action.getAction() {
            customAction()
        } else {
            otherOperativesCoordinator.goToAction(action, entity, self.wrapper?.offers)
        }
    }
    
    private func trackEvent(_ action: Any) {
        guard let trackable = action as? Trackable, let trackName = trackable.trackName else { return }
        trackEvent(.action, parameters: [.operate: trackName])
    }
}

extension OtherOperativesPresenter: OtherOperativesPresenterProtocol {
    func finishAndDismissView() {
        otherOperativesCoordinator.dismiss()
    }
    
    func viewDidLoad() {
        wrapper = self.dependenciesResolver.resolve(for: OtherOperativesWrapper.self)
        getPGUserValues()
        dataManager?.getOtherOperativesChecks(self.locations, { [weak self] response in
            self?.wrapper?.setOtherOperativesChecks(response)
            self?.addActions()
            }, failure: { _ in}
        )
        trackScreen()
    }
    
    func updateActions(withText text: String?) {
        searchedTerm = text?.trim() ?? ""
        if !searchedTerm.isEmpty && !searchedTerm.isBlank {
            startTimer()
        } else {
            currentSearch = nil
            view?.hideSearchViews(true)
        }
        addActions(filterWithText: text)
    }
    
    func didSelectAction(indentifier: String?) {
        guard let identifier = indentifier else { return }
        processOffer(withIdentifier: identifier)
    }
    
    func didSelectAction(identifier: String?, type: GlobalSearchActionViewType) {
        guard let identifier = identifier else { return }
        switch type {
        case .offer:
            processOffer(withIdentifier: identifier)
        case .deepLink:
            let extraParameters = [
                TrackerDimension.tipName.key: identifier,
                TrackerDimension.searchedTerm.key: searchedTerm
            ]
            trackerManager.trackEvent(
                screenId: OtherOperativesPage().page,
                eventId: OtherOperativesPage.Action.tapInTip.rawValue,
                extraParameters: extraParameters
            )
            otherOperativesCoordinator.executeDeepLink(identifier)
        }
    }
}

private extension OtherOperativesPresenter {
    func getPGUserValues() {
        let userPreferences = self.dependenciesResolver.resolve(for: GetUserPrefWithoutUserIdUseCase.self)
        MainThreadUseCaseWrapper(
            with: userPreferences,
            onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                let userPref = response.userPref
                strongSelf.setPGStyleValues(userPref: userPref)
            }
        )
    }
    
    func setPGStyleValues(userPref: UserPrefEntity) {
        let pgColorMode = userPref.getPGColorMode()
        
        if userPref.globalPositionOnboardingSelected() == .smart {
            selectedGP = .smart
            view?.configureSmartView(mode: pgColorMode)
        } else {
            view?.configureClassicView()
        }
    }
    
    func addActions(filterWithText text: String? = nil) {
        view?.removeAllActions()
        currentActions = getActions(text: text)
        guard !currentActions.isEmpty else { return }
        currentActions.forEach { action in
            view?.addActions(action.0,
                             sectionTitle: action.1,
                             usingStyle: selectedGP == .smart ? .smartSelectorStyle : nil)
        }
    }
    
    func getActions(text: String? = nil) -> [([AllOperativesViewModel], String?)] {
        guard let wrapper = wrapper else { return [] }
        var originalImages = [AllOperatives: Any]()
        if selectedGP != GlobalPositionOptionEntity.smart, wrapper.enabledCardsActions.contains(.applePay) {
            originalImages[.cardsActions] = [CardOperativeActionType.applePay]
        }
        
        let actions: [([AllOperativesViewModel], String?)]
        let operativeOnShorcutsAppKeywords = self.searchKeywordsUseCaseOutput?.operativesOnShorcutsAppKeywords ?? []
        if let text = text, !text.isEmpty {
            let filteredActions = AllOperativesActionFactory(dependenciesResolver: self.dependenciesResolver)
                .getFilteredOperativesButtons(
                    isSmartGP: selectedGP == .smart,
                    containingText: text.trim(),
                    action: didSelectAction(_:_:),
                    enabledActions: wrapper.getAllEnableActions(),
                    originalImages: originalImages,
                    operativeOnShorcutsAppKeywords: operativeOnShorcutsAppKeywords
                )
            guard !filteredActions.isEmpty else { return [] }
            actions = [(filteredActions, nil)]
        } else {
            actions = AllOperativesActionFactory(dependenciesResolver: self.dependenciesResolver)
                .getAllOperativesButtons(isSmartGP: selectedGP == .smart,
                                         action: didSelectAction(_:_:),
                                         enabledActions: wrapper.getAllEnableActions(),
                                         originalImages: originalImages)
        }
        return actions
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.performSearch()
        }
    }
    
    func performSearch() {
        let input: GlobalSearchUseCaseInput = GlobalSearchUseCaseInput(
            dependenciesResolver: dependenciesResolver,
            substring: searchedTerm
        )
        let values: (globalSearchOkOutput: GlobalSearchUseCaseOkOutput?, searchKeywordsOkOutput: GetSearchKeywordsUseCaseOkOutput?) = (nil, nil)
        let globalSearchScenario = self.globalSearchScenario(input)
        MultiScenario(handledOn: self.dependenciesResolver.resolve(), initialValue: values)
            .addScenario(globalSearchScenario) { (updatedValues, output, _) in
                updatedValues.globalSearchOkOutput = output
            }
            .addScenario(globalSearchKeywordsScenario()) { (updatedValues, output, _) in
                updatedValues.searchKeywordsOkOutput = output
            }
            .onSuccess { [weak self] values in
                self?.showResult(from: values)
            }
    }
    
    func globalSearchScenario(_ input: GlobalSearchUseCaseInput) -> Scenario<GlobalSearchUseCaseInput, GlobalSearchUseCaseOkOutput, StringErrorOutput> {
        return Scenario(useCase: self.getGlobalSearchUseCase, input: input)
    }
    
    func globalSearchKeywordsScenario() -> Scenario<Void, GetSearchKeywordsUseCaseOkOutput, StringErrorOutput> {
        return Scenario(useCase: self.getGlobalSearchKeywordsUseCase)
    }
    
    func showResult(from output: (globalSearchOkOutput: GlobalSearchUseCaseOkOutput?, searchKeywordsOkOutput: GetSearchKeywordsUseCaseOkOutput?)) {
        guard !searchedTerm.isEmpty,
              let globalSearchOkOutput = output.globalSearchOkOutput,
              let baseUrls = self.baseURLProvider.baseURL else {
            return
        }
        self.useCaseOutput = globalSearchOkOutput
        self.searchKeywordsUseCaseOutput = output.searchKeywordsOkOutput
        let baseURL = String(baseUrls.dropLast(1))
        let viewModel = OtherOperativesSearchViewModel(
            from: globalSearchOkOutput,
            baseURL: baseURL,
            searchedTerm: searchedTerm,
            actionOnShorcutsAppKeywords: output.searchKeywordsOkOutput?.actionOnShorcutsAppKeywords ?? []
        )
        currentSearch = viewModel
        view?.setSearchResultModel(viewModel)
        refreshTotalResults()
    }
    
    func refreshTotalResults() {
        let actionsCount = currentActions.reduce(0) { $0 + $1.0.filter({ $0.isDisabled == false }).count }
        let total = actionsCount + (currentSearch?.totalResult ?? 0)
        view?.setTotalResults(total)
        view?.setOperativesResults(actionsCount)
        view?.hideTotalResults(searchedTerm.isEmpty)
        view?.hideOperativeResults(searchedTerm.isEmpty || actionsCount == 0)
        view?.showEmptyView(show: total == 0,
                            withSearchTerm: searchedTerm,
                            showActionsView: actionsCount > 0)
    }
    
    func getAllLocations() -> [PullOfferLocation] {
        guard let shortCutsModifier = dependenciesResolver.resolve(forOptionalType: ShortCutsModifierProtocol.self) else {
            return PullOffersLocationsFactoryEntity().otherOperatives
        }
        return joinAllLocations(operatives: shortCutsModifier.operativesOtherCountry())
    }
    
    func joinAllLocations(operatives: [PullOfferLocation]) -> [PullOfferLocation] {
        var allLocations = PullOffersLocationsFactoryEntity().otherOperatives
        for operative in operatives {
            allLocations.append(operative)
        }
        return allLocations
    }
    
    func processOffer(withIdentifier identifier: String) {
        if let offer = (self.useCaseOutput?.actionTipsOffers?[identifier]) {
            self.otherOperativesCoordinator.executeOffer(offer)
        } else if let offer = self.useCaseOutput?.homeTipsOffers?[identifier] {
            self.otherOperativesCoordinator.executeOffer(offer)
        } else if let offer = self.useCaseOutput?.interestTipsOffers?[identifier] {
            self.otherOperativesCoordinator.executeOffer(offer)
        }
    }
}

extension OtherOperativesPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: OtherOperativesPage {
        return OtherOperativesPage()
    }
}
