import Foundation
import CoreFoundationLib

class OTPPushInfoPresenter: PrivatePresenter<OTPPushInfoViewController, OTPPushInfoNavigatorProtocol, OTPPushInfoPresenterProtocol> {
    
    private var device: OTPPushDevice
    
    // MARK: - TrackerManager
    
    override var screenId: String? {
        return TrackerPagePrivate.OtpPush().page
    }
    
    // MARK: - Public methods
    
    init(device: OTPPushDevice, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: OTPPushInfoNavigatorProtocol) {
        self.device = device
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.set(acceptText: localized(key: "otpPush_buttom_updateSecureDevice"))
        view.styledTitle = localized(key: "toolbar_title_secureDevice")
        view.show(barButton: .close)
        view.add(sections: buildSections())
    }
    
    // MARK: - Private methods
    
    private func buildSections() -> [TableModelViewSection] {
        let headerSection = TableModelViewSection()
        
        let headerViewModel = GenericOperativeHeaderTitleAndDescriptionViewModel(title: stringLoader.getString("otpPush_label_secureDevice"), description: stringLoader.getString("otpPush_label_registeredDevice"))
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderTitleAndDescriptionView.self, dependencies: dependencies)
        headerSection.items = [headerCell]
        
        let infoSection = TableModelViewSection()
        
        let confirmationHeader = SimpleConfirmationTableViewHeaderModel(localized(key: "summary_item_terminal"), device.model, false, topSpace: 24, dependencies)
        infoSection.items.append(confirmationHeader)
        
        if let alias = device.alias, !alias.isEmpty {
            let accountItem = ConfirmationTableViewItemModel(stringLoader.getString("summary_item_alias"), alias, false, dependencies)
            infoSection.items.append(accountItem)
        }
        
        let registrationDateItem = ConfirmationTableViewItemModel(stringLoader.getString("summary_item_registrationDate"), dependencies.timeManager.toString(date: device.registrationDate, outputFormat: .dd_MMM_yyyy) ?? "", true, dependencies)
        infoSection.items.append(registrationDateItem)
        
        return [headerSection, infoSection]
    }
}

extension OTPPushInfoPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        navigator.dismiss()
    }
}

extension OTPPushInfoPresenter: OTPPushInfoPresenterProtocol {
    func registerSelected() {
        launchOtpPushOperative(device: device, withDelegate: self)
    }
}

extension OTPPushInfoPresenter: EnableOtpPushOperativeLauncher {}

extension OTPPushInfoPresenter: OperativeLauncherDelegate {
    
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
}

extension OTPPushInfoPresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}
