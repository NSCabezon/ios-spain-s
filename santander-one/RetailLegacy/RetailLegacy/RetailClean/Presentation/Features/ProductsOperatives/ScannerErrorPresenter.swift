import Foundation
import CoreFoundationLib

protocol ScannerErrorPresenterDelegate: class {
    func scannerErrorDidSelectScanAgain()
    func scannerErrorDidSelectManual()
    func scannerErrorDidSelectClose()
    func scannerErrorDidSelectGoBack()
}

class ScannerErrorPresenter: PrivatePresenter<ScannerErrorViewController, Void, ScannerErrorPresenterProtocol> {
    
    // MARK: - Public attributes
    
    let errorTitle: LocalizedStylableText
    let errorDescription: LocalizedStylableText
    weak var delegate: ScannerErrorPresenterDelegate?
    
    // MARK: - Public methods
    
    init(dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: Void, title: LocalizedStylableText, description: LocalizedStylableText) {
        self.errorTitle = title
        self.errorDescription = description
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        barButtons = [.close]
        setBarButtons()
    }
}

extension ScannerErrorPresenter: ScannerErrorPresenterProtocol {
    
    var viewTitle: LocalizedStylableText {
        return localized(key: "toolbar_title_errorScan")
    }
    
    var scanAgainTitle: LocalizedStylableText {
        return localized(key: "errorScan_buttom_newScan")
    }
    
    var manualTitle: LocalizedStylableText {
        return localized(key: "errorScan_buttom_introduceManual")
    }
    
    func userDidSelectScanAgain() {
        delegate?.scannerErrorDidSelectScanAgain()
    }
    
    func userDidSelectManual() {
        delegate?.scannerErrorDidSelectManual()
    }
    
    func userDidSelectBack() {
        delegate?.scannerErrorDidSelectGoBack()
    }
}

extension ScannerErrorPresenter: CloseButtonAwarePresenterProtocol {
    
    func closeButtonTouched() {
        delegate?.scannerErrorDidSelectClose()
    }
}
