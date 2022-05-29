//

import Foundation

class OperativeProductSelectionPresenter<Profile: OperativeProductSelectionProfile>: OperativeStepPresenter<ProductSelectionViewController, VoidNavigator, ProductSelectionPresenterProtocol>, ProductSelectionPresenterProtocol {
    
    // MARK: - Public attributes
    
    lazy var products: [Profile.Product] = {
        guard let profile = self.profile else { return [] }
        return profile.products()
    }()
    
    var tooltipMessage: LocalizedStylableText?
    var profile: Profile?
    
    // MARK: - Overrided methods
    
    override func loadViewData() {
        super.loadViewData()
        guard let profile = self.profile else { return }
        self.setTitle()
        setupHeader()
        showProducts(sectionTitleKey: profile.subtitle())
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        profile?.evaluateBeforeShowing(completion: onSuccess)
    }
    
    override var screenId: String? {
        return profile?.screenIdProductSelection
    }
    
    var progressBarBackgroundStyle: ProductSelectionProgressStyle {
        return .white
    }
    
    // MARK: - Private
    
    private func setupHeader() {
        let section = TableModelViewSection()
        profile?.setupHeader(for: section)
        view.sections += [section]
    }
    
    
    func setTitle() {
        guard let profile = self.profile else { return }
        let parameter: ProductSelection<Profile.Product> = containerParameter()
        if let message = parameter.tooltipMessage {
            let localizedTitle = dependencies.stringLoader.getString(profile.title())
            view.prepareNavigationBar(using: localizedTitle)
            tooltipMessage = dependencies.stringLoader.getString(message)
        } else {
            set(title: profile.title())
        }
    }
    
    func getTitle() -> String? {
        guard let profile = self.profile else { return nil }
        return profile.title()
    }
    
    // MARK: - ProductSelectionPresenterInput
    
    func selected(index: Int) {
        profile?.selected(index)
    }
}

extension OperativeProductSelectionPresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: view, completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view, shouldTriggerHaptic: true)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}
