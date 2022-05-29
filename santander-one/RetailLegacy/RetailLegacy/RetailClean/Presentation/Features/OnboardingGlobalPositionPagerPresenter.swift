//
//  OnboardingGlobalPositionPagerPresenter.swift
//  RetailClean
//
//  Created by alvola on 03/10/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import CoreDomain
import CoreFoundationLib

public enum GlobalPositionOption: Int, CaseIterable {
    case classic = 0
    case simple
    case smart
    
    func value() -> Int {
        return self.rawValue
    }
    
    var trackName: String {
        switch self {
        case .classic:
            return "clas"
        case .simple:
            return "sen"
        case .smart:
            return "smrt"
        }
    }
}

final class OnboardingGlobalPositionPagerPresenter: BaseOnboardingPresenter<OnboardingPagerViewController, OnboardingNavigator, OnboardingPresenterProtocol> {
    private lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependencies.dependenciesEngine)
        manager.setDataManagerProcessDelegate(self)
        return manager
    }()
    
    override func loadViewData() {
        super.loadViewData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
        self.setInfoPager()
    }
    
    // MARK: - TrackerScreenProtocol
    
    override var screenId: String? {
        return OnboardingPg().page
    }
}

extension OnboardingGlobalPositionPagerPresenter: OnboardingPresenterProtocol {
    func goBack() { navigator.goBack() }
    
    func goContinue() {
        guard let delegate = self.delegate, let onboardingUserData = self.onboardingUserData else { return }
        let gpOptionSelected: GlobalPositionOption? = GlobalPositionOption(rawValue: view.getOptionPagerSelected())
        let gpChanged = gpOptionSelected != delegate.currentGlobalPosition
        var smartColorChanged: Bool = false
        
        if [.smart].contains(gpOptionSelected) {
            if let selectedPGButton = view.pagerView?.themeColorSelectorView.getSelectedButtonType() {
                smartColorChanged = !(onboardingUserData.smartThemeColor == selectedPGButton.rawValue)
                onboardingUserData.smartThemeColor = selectedPGButton.rawValue
            }
        }
        delegate.isGlobalPositionChanged = gpChanged || smartColorChanged
        trackEvent(eventId: OnboardingPg.Action.continueAction.rawValue, parameters: [TrackerDimension.pgType.key: gpOptionSelected?.trackName ?? ""])
        if gpChanged || smartColorChanged {
            delegate.currentGlobalPosition = gpOptionSelected ?? .classic
            let pgColorMode = PGColorMode(rawValue: onboardingUserData.smartThemeColor)
            let input = UpdateOptionsOnboardingUserPrefUseCaseInput(
                userId: onboardingUserData.userId,
                onboardingFinished: nil,
                globalPositionOptionSelected: gpOptionSelected,
                photoThemeOptionSelected: nil,
                smartColor: pgColorMode,
                alias: nil)
            UseCaseWrapper(
                with: useCaseProvider.getUpdateOptionsOnboardingUserPrefUseCase(input: input),
                useCaseHandler: useCaseHandler,
                errorHandler: nil,
                onSuccess: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.reloadFullAndGoNext()
                }, onError: { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    strongSelf.navigator.next()
                })
        } else {
            navigator.next()
        }
    }
    
    func scrolledToNewOption() {
        trackEvent(eventId: OnboardingPg.Action.swipe.rawValue, parameters: [:])
    }
}

private extension OnboardingGlobalPositionPagerPresenter {
    func setInfoPager() {
        guard let currentGlobalPosition = onboardingUserData?.globalPositionOnboardingSelectedValue else {
            return
        }
        guard let userData = onboardingUserData, let smartTheme = PGColorMode(rawValue: userData.smartThemeColor) else {
            return
        }
        //TODO: - For the moment in App we use GlobalPositionOption, when Onboarding move to module, replace this to GlobalPositionOptionEntity
        delegate?.currentGlobalPosition = GlobalPositionOption(rawValue: currentGlobalPosition) ?? .classic
        view.setInfo(
            [PageInfo(id: GlobalPositionOption.classic.value(), title: localized(key: "onboarding_title_classic"), description: localized(key: "onboarding_text_classic"), imageName: "imgPgClassic"),
             PageInfo(id: GlobalPositionOption.simple.value(), title: localized(key: "onboarding_title_simple"), description: localized(key: "onboarding_text_simple"), imageName: "imgPgSimple"),
             PageInfo(id: GlobalPositionOption.smart.value(), title: localized(key: "onboarding_title_young"), description: localized(key: "onboarding_text_young"), imageName: smartTheme.imageName(), smartColorMode: smartTheme, isEditable: true)],
            title: localized(key: "onboarding_title_choosePg"),
            currentIndex: currentGlobalPosition,
            bannedIndexes: [],
            isGlobalPosition: true)
    }
    
    func reloadFullAndGoNext() {
        let loadingText = LoadingText(title: self.localized(key: "login_popup_loadingPg"), subtitle: self.localized(key: "loading_label_moment"))
        let topInset = 44 + Double(UIScreen.main.statusBarHeight)
        let completion = {
            self.sessionDataManager.load()
        }
        let type = LoadingViewType.onDrawer(completion: completion, shakeDelegate: nil)
        let info = LoadingInfo(type: type, loadingText: loadingText, placeholders: nil, topInset: topInset, background: .white)
        showLoading(info: info)
    }
    
    @objc func reloadContent() {
        self.setInfoPager()
    }
    
    // MARK: - Handles session
    func handleLoadSessionDataSuccess() {
        guard self.delegate != nil else {
            self.hideLoading()
            return
        }
        self.navigator.next()
        self.hideLoading()
    }
    
    func handleLoadSessionError(error: LoadSessionError) {
        switch error {
        case .generic, .unauthorized, .networkUnavailable, .intern:
            self.view.showGenericErrorDialog(withDependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine)
        case .other(let errorMessage):
            self.onErrorLoadingPG(LocalizedStylableText(text: errorMessage, styles: nil))
        }
        self.hideLoading()
    }
    
    func onErrorLoadingPG(_ error: LocalizedStylableText) {
        let accept = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: nil)
        Dialog.alert(title: nil, body: error, withAcceptComponent: accept, withCancelComponent: nil, source: view)
    }
}

extension OnboardingGlobalPositionPagerPresenter: SessionDataManagerProcessDelegate {
    func handleProcessEvent(_ event: SessionProcessEvent) {
        switch event {
        case .fail(let error):
            self.handleLoadSessionError(error: error)
        case .loadDataSuccess:
            self.handleLoadSessionDataSuccess()
        case .updateLoadingMessage:
            break
        case .cancelByUser:
            break
        }
    }
}
