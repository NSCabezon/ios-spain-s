//
//  PGPersonalizationPresenter.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 02/12/2019.
//

import CoreFoundationLib
import Foundation
import UI

protocol PGPersonalizationPresenterProtocol {
    var view: PGPersonalizationViewProtocol? { get set }
    var moduleCoordinator: DefaultPGPersonalizationModuleCoordinator? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func backDidPressed()
    func closeDidPressed()
    func offerViewDidPressed()
    func financingChartsViewDidPressed()
    func frequentOperationsViewDidPressed()
    func productsViewDidPressed()
    func saveChangesButtonDidPressed()
    func currentIndexDidChange(_ index: Int)
    func didSwipe()
}

final class PGPersonalizationPresenter {
    var view: PGPersonalizationViewProtocol?
    weak var moduleCoordinator: DefaultPGPersonalizationModuleCoordinator?
    
    let dependenciesResolver: DependenciesResolver
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private var section: PersonalAreaSection
    private var userPref: UserPrefWrapper
    var wrapper: OtherOperativesEvaluator?
    var dataManager: PersonalAreaDataManagerProtocol
    var availableActions: [GpOperativesViewModel] = [] {
        didSet {
            guard !availableActions.isEmpty else { return }
            checkElementsViews()
        }
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().personalAreaConfigPG
    }
    
    var otherOperativesLocations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().personalAreaShortcuts
    }

    private var pfmController: PfmControllerProtocol? {
        return dependenciesResolver.resolve(for: PfmControllerProtocol.self)
    }
    
    private var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    init(dependenciesResolver: DependenciesResolver, section: PersonalAreaSection) {
        self.dependenciesResolver = dependenciesResolver
        self.userPref = self.dependenciesResolver.resolve(for: UserPrefWrapper.self)
        self.dataManager = self.dependenciesResolver.resolve(for: PersonalAreaDataManagerProtocol.self)
        self.section = section
    }
    
    private func loadPGPersonalizationPreferences() {
        self.loadPullOffers()
        guard let trackName = GlobalPositionOptionEntity(rawValue: self.userPref.currentPG ?? 0)?.trackName() else { return }
        self.trackerManager.trackEvent(screenId: PersonalAreaConfigurationPage().page, eventId: PersonalAreaConfigurationPage.Action.pgType.rawValue, extraParameters: [TrackerDimension.pgType.key: trackName])
    }
    
    func loadPullOffers() {
        self.dataManager.getAvailablePullOffers(locations, onSuccess: self.onPullOffersLoaded(response:))
    }
    
    func onPullOffersLoaded(response: GetPullOffersUseCaseOutput?) {
        self.pullOfferCandidates = response?.pullOfferCandidates
        loadOtherOperativesWrapper()
        self.checkOfferView()
    }
    
    private func loadOtherOperativesWrapper() {
        dataManager.getOtherOperativesWrapper(locations: otherOperativesLocations, onLoadedOtherOperativesWrapper(response:))
    }
    
    private func onLoadedOtherOperativesWrapper(response: GetOtherOperativesWrapperUseCaseOkOutput) {
        wrapper = response
        getOtherOperatives(nil)
    }
    
    private func setPagerInfo() {
        guard let userData = self.userPref.userPrefEntity else { return }
        let smartTheme = userData.getPGColorMode()
        view?.setInfo(
            [
                PageInfo(
                    id: GlobalPositionOptionEntity.classic.value(),
                    title: localized("onboarding_title_classic"),
                    description: localized("onboarding_text_classic"),
                    imageName: "imgPgClassic"
                ),
                PageInfo(
                    id: GlobalPositionOptionEntity.simple.value(),
                    title: localized("onboarding_title_simple"),
                    description: localized("onboarding_text_simple"),
                    imageName: "imgPgSimple"
                ),
                PageInfo(
                    id: GlobalPositionOptionEntity.smart.value(),
                    title: localized("onboarding_title_young"),
                    description: localized("onboarding_text_young"),
                    imageName: smartTheme.imageName(),
                    smartColorMode: smartTheme,
                    isEditable: true
                )
            ],
            title: localized("pgCustomize_label_chooseSubject"),
            bannedIndexes: []
        )
        view?.setCurrentSelectedPG(currentIndex: userPref.currentPG ?? 0)
    }
    
    private func configurePGView() {
        checkElementsViews()
        setUserPrefData()
    }
    
    private func checkOfferView() {
        if pullOfferCandidates?.count ?? 0 > 0 {
            view?.offerViewIsHidden(false)
        }
    }
    
    private func checkElementsViews() {        
        guard let currentPG = userPref.currentPG else { return }
        guard currentPG != GlobalPositionOptionEntity.simple.value() else {
            view?.setCurrentPGElements([.discreteModeView, .productsView])
            return
        }
        var elements: [PGPersonalizationSubview] = [.discreteModeView, .financingChartsView]
        if wrapper != nil && !availableActions.isEmpty {
            elements.append(.frequentOperationsView)
        }
        elements.append(.productsView)
        if currentPG == GlobalPositionOptionEntity.smart.value() {
            elements.append(.themeSelectorView)
        }
        view?.setCurrentPGElements(elements)
    }
    
    private func setUserPrefData() {
        view?.setIsDiscretModeActivated(isActivated: userPref.isDiscretModeActivated ?? false)
        view?.setIsChartModeActivated(isActivated: userPref.isChartModeActivated ?? true)
        view?.setUserBudget(self.getUserBudget())
    }
    
    private func goToCustomProducts() {
        let coordinator = dependenciesResolver.resolve(for: GPCustomizationCoordinator.self)
        coordinator.start()
    }
}

extension PGPersonalizationPresenter: PGPersonalizationPresenterProtocol {
    
    func viewDidLoad() {
        self.trackScreen()
        self.dataManager.loadPersonalAreaPreferences({ [weak self] in
            self?.loadPGPersonalizationPreferences()
            self?.configurePGView()
        })
    }
    
    func viewWillAppear() {
        self.dataManager.loadPersonalAreaPreferences({ [unowned self] in
            setPagerInfo()
            view?.setUserBudget(self.getUserBudget())
        })
    }
    
    func backDidPressed() {
        moduleCoordinator?.end()
    }
    
    func closeDidPressed() {
        moduleCoordinator?.end()
    }
    
    func offerViewDidPressed() {
        let pullOffer = pullOfferCandidates?.first { $0.key.stringTag == PersonalAreaPullOffers.discreteModeVideo }
        guard let offer = pullOffer?.value else { return }
        personalAreaCoordinator?.didSelectOffer(offer: offer)
    }
    
    func financingChartsViewDidPressed() {
        self.trackEvent(.financingCharts, parameters: [:])
        moduleCoordinator?.goToGeneralBudget()
    }
    
    func frequentOperationsViewDidPressed() {
        self.trackEvent(.frequentOperations, parameters: [:])
        guard localAppConfig.isEnabledPlusButtonPG == true else {
            view?.showFeatureNotAvailable()
            return
        }
        if userPref.userPrefEntity?.globalPositionOnboardingSelected() == GlobalPositionOptionEntity.smart {
            moduleCoordinator?.goToSmartOperativeSelector(delegate: self, viewModels: availableActions, gpColorMode: userPref.userPrefEntity?.getPGColorMode() ?? .black)
        } else {
            moduleCoordinator?.goToOperativeSelector(delegate: self, viewModels: availableActions)
        }
    }
    
    private func reloadAvailableActions(_ viewModels: [GpOperativesViewModel]) {
        getOtherOperatives(viewModels.map { $0.type })
    }
    
    func productsViewDidPressed() {
        self.trackEvent(.products, parameters: [:])
        goToCustomProducts()
    }
    
    func saveChangesButtonDidPressed() {
        self.trackEvent(.saveChanges, parameters: [:])
        self.personalAreaCoordinator?.startGlobalLoading(completion: { [weak self] in
            guard let userPrefEntity = self?.userPref.userPrefEntity, let view = self?.view else { return }
            let index = view.getOptionPagerSelected()
            guard let currentPG = GlobalPositionOptionEntity(rawValue: index) else { return }
            userPrefEntity.setGlobalPositionOnboardingSelected(pgSelected: currentPG)
            
            switch currentPG {
            case .classic:
                self?.trackEvent(.save, parameters: [.pgType: PersonalAreaConfigPGPageConstants.classicPgType])
            case .smart:
                self?.trackEvent(.save, parameters: [.pgType: PersonalAreaConfigPGPageConstants.smartPgType])
            case .simple:
                self?.trackEvent(.save, parameters: [.pgType: PersonalAreaConfigPGPageConstants.simplePgType])
            }
            
            if [.classic, .smart].contains(currentPG) {
                userPrefEntity.setDiscreteMode(discreteModeIsOn: view.getDiscretModeIsOn())
                if view.getDiscretModeIsOn() == true {
                    self?.trackEvent(.discreteModeOn, parameters: [:])
                } else {
                    self?.trackEvent(.discreteModeOff, parameters: [:])
                }
                userPrefEntity.setChartMode(chartModeIsOn: view.getChartModeIsOn())
                if view.getChartModeIsOn() == true {
                    self?.trackEvent(.activateGraphics, parameters: [:])
                } else {
                    self?.trackEvent(.deactivateGraphics, parameters: [:])
                }
            }
            
            if [.simple].contains(currentPG) {
                userPrefEntity.setDiscreteMode(discreteModeIsOn: view.getDiscretModeIsOn())
                if view.getDiscretModeIsOn() == true {
                    self?.trackEvent(.discreteModeOn, parameters: [:])
                } else {
                    self?.trackEvent(.discreteModeOff, parameters: [:])
                }
            }
            
            if [.smart].contains(currentPG), let selectedColorIdentifier = view.getThemeColor(), let pgColorMode = PGColorMode(rawValue: selectedColorIdentifier) {
                userPrefEntity.setPGColorMode(pgColorMode: pgColorMode )
            }
            
            self?.dataManager.updateUserPreferencesValues(userPrefEntity: userPrefEntity, onSuccess: {
                self?.personalAreaCoordinator?.globalPositionDidReload()
            }, onError: { _ in
                self?.personalAreaCoordinator?.hideLoading(completion: {
                    self?.personalAreaCoordinator?.showAlertDialog(acceptTitle: localized("generic_button_accept"), cancelTitle: nil, title: nil, body: localized("generic_error_txt"), acceptAction: nil, cancelAction: nil)
                })
            })
        })
    }
    
    func currentIndexDidChange(_ index: Int) {
        self.userPref.currentPG = index
        checkElementsViews()
    }
    
    func didSwipe() {
        self.trackEvent(.pgSwipe, parameters: [:])
    }
    
}

extension PGPersonalizationPresenter: OtherOperativesViewControllerDelegate {
    func didSaveChanges(viewModels: [GpOperativesViewModel]) {
        self.personalAreaCoordinator?.startGlobalLoading(completion: { [weak self] in
            guard let strongSelf = self else { return }
            guard let userPrefEntity = strongSelf.userPref.userPrefEntity else { return }
            let frequentOperativesFinal: [PGFrequentOperativeOptionProtocol] = viewModels.map { $0.type }
            strongSelf.reloadAvailableActions(viewModels)
            let frequentOperativesKeys: [String] = frequentOperativesFinal.map { $0.rawValue }
            strongSelf.userPref.userPrefEntity?.setFrequentOperativesKeys(frequentOperativesKeys)
            strongSelf.dataManager.updateUserPreferencesValues(userPrefEntity: userPrefEntity, onSuccess: {
                strongSelf.personalAreaCoordinator?.globalPositionDidReload()
            }, onError: { _ in
                strongSelf.personalAreaCoordinator?.hideLoading(completion: {
                    strongSelf.personalAreaCoordinator?.showAlertDialog(acceptTitle: localized("generic_button_accept"), cancelTitle: nil, title: nil, body: localized("generic_error_txt"), acceptAction: nil, cancelAction: nil)
                })
            })
        })
    }
}

extension PGPersonalizationPresenter: EditBudgetHelper {
    private func getUserBudget() -> Double? {
        let months = self.pfmController?.monthsHistory ?? []
        let userBudget = self.userPref.userPrefEntity?.getBudget()
        let budget = self.getEditBudgetData(userBudget: userBudget, threeMonthsExpenses: months, resolver: self.dependenciesResolver)
        return Double(budget.budget)
    }
}

extension PGPersonalizationPresenter: OtherOperativesHelper {
    var otherOperativesDelegate: OtherOperativesActionDelegate? { nil }
    func didSelectAction(_ action: PGFrequentOperativeOptionProtocol, _ entity: Void) {}
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {}
    func goToMoreOperateOptions() {}
}

extension PGPersonalizationPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: PersonalAreaConfigurationPGPage {
        return PersonalAreaConfigurationPGPage()
    }
}
