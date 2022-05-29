import CoreFoundationLib

class EnvironmentsSelectorPresenter: PrivatePresenter<EnvironmentsSelectorViewController, PublicHomeNavigator, EnvironmentsSelectorPresenterContract>, EnvironmentsSelectorPresenterContract {

    private struct LocalizationKeys {
        struct Selectors {
            static let bsanTitle = "environment_select_ws"
            static let publicFilesTitle = "environment_select_pf"
            static let inbentaTitle = "environment_select_inbenta"
        }
    }

    var completion: (() -> Void)?

    private var bsanEnvironments: [BSANEnvironment]?
    private var publicFilesEnvironments: [PublicFilesEnvironment]?
    private var process: AtomicInteger = AtomicInteger()
    
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return false
    }

    override func loadViewData() {
        getBSANEnvironments()
    }

    func checkHasPersistedUser() {
        UseCaseWrapper(with: useCaseProvider.getCheckPersistedUserUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler,
                onSuccess: { (_) in self.existsPersistedUser(true) },
                onError: { (_) in self.existsPersistedUser(false) })
    }

    func existsPersistedUser(_ hasPersistedUser: Bool) {
        if hasPersistedUser {
            view.disableBsanEnvironmentSelector()
        }
    }

    func environmentsSelected(selectors: [EnvironmentSelectorViewModel]) {
        saveEnvironments(selectors: selectors)
    }

    func addSelectorToView(selector: EnvironmentSelectorViewModel) {
        view.fillSelector(selector: selector)
    }

    func environmentsSelectionCancelled() {
    }
    
    func didSelectFeatureFlags() {
        navigator.goToFeatureFlags()
    }

    private func saveEnvironments(selectors: [EnvironmentSelectorViewModel]) {
        guard let bsanEnvironments = bsanEnvironments,
              let publicFilesEnvironments = publicFilesEnvironments else {
            return
        }

        if let bsanEnvironment = bsanEnvironments.first(where: { getSelector(selectors: selectors, key: LocalizationKeys.Selectors.bsanTitle)?.selected.title == $0.name }) {
            changeBSANEnvironment(bsanEnvironment)
        }
        if let publicFilesEnvironment = publicFilesEnvironments.first(where: { getSelector(selectors: selectors, key: LocalizationKeys.Selectors.publicFilesTitle)?.selected.title == $0.name }) {
            changePublicFilesEnvironment(publicFilesEnvironment)
        }
    }

    private func afterSaveEnvironments() {
        if process.decrementAndGet() == 0 {
            completion?()
        }
    }

    private func getSelector(selectors: [EnvironmentSelectorViewModel], key: String) -> EnvironmentSelectorViewModel? {
        return selectors.first(where: { $0.title.text == localized(key: key).text })
    }

    // MARK: - BSAN Environments funcs
    private func changeBSANEnvironment(_ bsanEnvironment: BSANEnvironment) {
        process.increment()
        UseCaseWrapper(with: useCaseProvider.getChangeBSANEnvironmentUseCase(ChangeBSANEnvironmentUseCaseInput(bsanEnvironment: bsanEnvironment)), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler,
                onSuccess: { (_) in self.afterSaveEnvironments() },
                onError: { (_) in self.afterSaveEnvironments() })
    }

    private func getCurrentBSANEnvironment() {
        UseCaseWrapper(with: useCaseProvider.getGetCurrentBSANEnvironmentUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler,
                onSuccess: { (result) in
                    let selectors = self.view.getSelectors()
                    guard let wsSelector = (selectors.first {
                        $0.title.text == self.localized(key: LocalizationKeys.Selectors.bsanTitle).text
                    }) else {
                        return
                    }
                    self.view.select(on: wsSelector, valueWithName: result.bsanEnvironment.name)
                })
    }

    private func getBSANEnvironments() {
        UseCaseWrapper(with: useCaseProvider.getGetBSANEnvironmentsUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler,
                onSuccess: { (result) in
                    self.bsanEnvironments = result.bsanEnvironments
                    let bsanEnviromentIdentifier = "bsanEnviromentElement_"
                    let bsanOptions = self.bsanEnvironments!.map {
                        EnvironmentViewModel(title: $0.name,
                                             url: $0.urlBase,
                                             accessibilityIdentifier: bsanEnviromentIdentifier + $0.name)
                    }
                    self.addSelectorToView(selector: EnvironmentSelectorViewModel(title: self.localized(key: LocalizationKeys.Selectors.bsanTitle), environments: bsanOptions))
                    self.getCurrentBSANEnvironment()
                    self.getPublicFilesEnvironments()
                })
    }

    // MARK: - PublicFiles Environments funcs
    private func changePublicFilesEnvironment(_ publicFilesEnvironment: PublicFilesEnvironment) {
        process.increment()
        UseCaseWrapper(with: useCaseProvider.getChangePublicFilesEnvironmentUseCase(ChangePublicFilesEnvironmentUseCaseInput(publicFilesEnvironment: publicFilesEnvironment)), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler,
                onSuccess: { (_) in self.afterSaveEnvironments() },
                onError: { (_) in self.afterSaveEnvironments() })
    }

    private func getCurrentPublicFilesEnvironment() {
        UseCaseWrapper(with: useCaseProvider.getGetCurrentPublicFilesEnvironmentUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler,
                onSuccess: { (result) in
                    let selectors = self.view.getSelectors()
                    guard let publicFilesSelector = (selectors.first {
                        $0.title.text == self.localized(key: LocalizationKeys.Selectors.publicFilesTitle).text
                    }) else {
                        return
                    }
                    self.view.select(on: publicFilesSelector, valueWithName: result.publicFilesEnvironment.name)
                })
    }

    private func getPublicFilesEnvironments() {
        UseCaseWrapper(with: useCaseProvider.getGetPublicFilesEnvironmentsUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler,
                onSuccess: { (result) in
                    self.publicFilesEnvironments = result.publicFilesEnvironments
                    let publicFileEnviromentIdentifier = "publicFileEnviromentElement_"
                    let publicFilesOptions = self.publicFilesEnvironments!.map {
                        EnvironmentViewModel(title: $0.name,
                                             url: $0.urlBase,
                                             accessibilityIdentifier: publicFileEnviromentIdentifier + $0.name)
                    }
                    self.addSelectorToView(selector: EnvironmentSelectorViewModel(title: self.localized(key: LocalizationKeys.Selectors.publicFilesTitle), environments: publicFilesOptions))
                    self.getCurrentPublicFilesEnvironment()
                })
    }
}
