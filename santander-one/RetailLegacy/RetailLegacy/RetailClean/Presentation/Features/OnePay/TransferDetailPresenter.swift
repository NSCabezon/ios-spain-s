import Foundation
import CoreFoundationLib
import PdfCommons

protocol TransferDetailNavigatorProtocol: MenuNavigator, OperativesNavigatorProtocol {
    func goToCancelTransferConfirmation(transferScheduled: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, account: Account, operativeDelegate: OperativeLauncherDelegate)
    func goToPdf(with data: Data, title: String, pdfSource: PdfSource)
}

protocol TransferDetailDataType {
    var title: String? { get }
    var actionTitle: [LocalizedStylableText] { get }
    var toolTipDisplayer: ToolTipDisplayer? { get set }
    func makeViewModels() -> [TableModelViewSection]
    func viewLoaded()
    func executeAction(_ position: Int, in presenter: TransferDetailPresenter)
}

extension TransferDetailDataType {
    
    func executeAction(_ position: Int, in presenter: TransferDetailPresenter) {
    }
}

class TransferDetailPresenter: PrivatePresenter<TransferDetailViewController, TransferDetailNavigatorProtocol & OperativesNavigatorProtocol, TransfersDetailPresenterProtocol> {
    private let transferDetailData: TransferDetailDataType
    private let pdfCreator = PDFCreator()
    
    init(transferDetailData: TransferDetailDataType, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: TransferDetailNavigatorProtocol) {
        var transferDetail = transferDetailData
        self.transferDetailData = transferDetail
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        transferDetail.toolTipDisplayer = self.view
    }
    
    override func loadViewData() {
        super.loadViewData()
        transferDetailData.viewLoaded()
        view.setSections(transferDetailData.makeViewModels())
    }
    
    func showPDF(_ data: String) {
        let title = stringLoader.getString("toolbar_title_detailOnePay").text
        pdfCreator.createPDF(html: data, completion: { [weak self]  data in
            self?.navigator.goToPdf(with: data, title: title, pdfSource: .transferSummary)
            }, failed: { [weak self] in
                self?.showError(keyDesc: nil)
        })
    }
    
}

extension TransferDetailPresenter: Presenter {}

extension TransferDetailPresenter: OperativeLauncherPresentationDelegate, OperativeLauncherDelegate {
    
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
    
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
}

extension TransferDetailPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension TransferDetailPresenter: TransfersDetailPresenterProtocol {
    
    var title: String? {
        return transferDetailData.title
    }
    
    var buttonTitle: [LocalizedStylableText] {
        return transferDetailData.actionTitle
    }

    func executeAction(_ position: Int) {
        transferDetailData.executeAction(position, in: self)
    }
    
}
