//

import Foundation
import CoreFoundationLib

class CardPfdStatementSelectionPresenter: ProductSelectionPresenter<Card, CardPfdStatementNavigatorProtocol>, PresenterProgressBarCapable {
    
    private var selectedCard: Card?
    private var progress = Progress(totalUnitCount: 1)

    init(cards: [Card], dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: CardPfdStatementNavigatorProtocol) {
        super.init(
            products: cards,
            titleKey: "toolbar_title_pdfExtract",
            sectionTitleKey: "deeplink_label_selectOriginCard",
            dependencies: dependencies,
            sessionManager: sessionManager,
            navigator: navigator
        )
        self.barButtons = [.close]
    }
    
    var shouldShowProgress: Bool {
        return true
    }
    
    // MARK: - Overrided methods
    override func selected(index: Int) {
        let card = products[index]
        self.selectedCard = card
        dateForPdf(product: card)
        progress.completedUnitCount = 1
        view.setProgressBar(progress: progress)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        progress.completedUnitCount = 0
        view.setProgressBar(progress: progress)
    }
}

extension CardPfdStatementSelectionPresenter: CardPdfLauncher {
    var operativePresentationDelegate: OperativeLauncherPresentationDelegate? {
        return self
    }
    
    var errorHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
    
    var navigatorLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    
    func didCancelMonthSelection() {
        progress.completedUnitCount = 0
        view.setProgressBar(progress: progress)
    }
}

extension CardPfdStatementSelectionPresenter: OperativeLauncherPresentationDelegate {
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

extension CardPfdStatementSelectionPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        navigator.close()
    }
}
