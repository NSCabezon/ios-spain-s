import Foundation
import CoreFoundationLib

class BarcodeScannerPresenter: OperativeStepPresenter<BarcodeScannerViewController, BarcodeScannerNavigatorProtocol, BarcodeScannerPresenterProtocol> {
    // MARK: - Overrided methods
    private var operativeData: BillAndTaxesOperativeData?
    
    override var screenId: String? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        switch type {
        case .bills: return TrackerPagePrivate.BillAndTaxesPayBillScanner().page
        case .taxes: return TrackerPagePrivate.BillAndTaxesPayTaxScanner().page
        }
    }
    
    override var shouldShowProgress: Bool {
        return false
    }
    
    override func loadViewData() {
        super.loadViewData()
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        guard let type = operativeData?.typeOperative else { return }
        switch type {
        case .bills:
            view.setTitle(stringLoader.getString("receiptsAndTaxes_title_scansBarcodeReceipts"))
        case .taxes:
            view.setTitle(stringLoader.getString("receiptsAndTaxes_title_scansBarcodeTaxes"))
        }
        view.setSubtitle(stringLoader.getString("receiptsAndTaxes_label_windowOverBarcode"))
        view.setManualModeButton(stringLoader.getString("receiptsAndTaxes_buttom_manual"))
        cameraIsReady()
    }
    
    override func viewShown() {
        //RESET PARAMETER
        let parameter: BillAndTaxesOperativeData = containerParameter()
        parameter.paymentBillTaxes = nil
        container?.saveParameter(parameter: parameter)
        //RESET CAMERA
        view.changeScannerDetection(pauseDetection: false)
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        guard let modeType = operativeData?.modeTypeSelector, case .camera = modeType else {
            onSuccess(false)
            return
        }
        
        let photoPermissionHelper = PhotoPermissionHelper()
        switch photoPermissionHelper.authorizationStatus(type: .cameraAccess) {
        case .authorized:
            onSuccess(true)
        case .denied:
            onSuccess(false)
        case .notDetermined:
            photoPermissionHelper.askAuthorization(type: .cameraAccess, completion: { (authorized: Bool) in
                if authorized {
                    onSuccess(true)
                } else {
                    onSuccess(false)
                }
            })
        case .restricted:
            onSuccess(false)
        }
    }
}

extension BarcodeScannerPresenter: BarcodeScannerPresenterProtocol {
    func barcodeDetected(code: String?) {
        guard let codeScan = code else {
            showScannerError()
            return
        }
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        guard let selectedAccount = operativeData.productSelected, let type = operativeData.typeOperative else { return }
        
        let input = PreValidateScannerBillsAndTaxesUseCaseInput(code: codeScan, type: type, originAccount: selectedAccount)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: dependencies.useCaseProvider.getPreValidateScannerBillsAndTaxesUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
            self?.hideAllLoadings {
                guard let strongSelf = self else { return }
                let parameter: BillAndTaxesOperativeData = strongSelf.containerParameter()
                parameter.paymentBillTaxes = result.paymentBillTaxes
                strongSelf.container?.saveParameter(parameter: parameter)
                strongSelf.container?.stepFinished(presenter: strongSelf)
            }
            }, onError: { [weak self] (error) in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    switch error?.validationError {
                    case .other?:
                        strongSelf.showScannerError()
                    case .notValidFormat?:
                        strongSelf.showScannerError()
                    case .service?:
                        strongSelf.showError(keyTitle: nil, keyDesc: error?.getErrorDesc(), phone: nil, completion: {
                            strongSelf.view.changeScannerDetection(pauseDetection: false)
                        })
                    case .none:
                        strongSelf.showScannerError()
                    case .invalidTypeBills?:
                        strongSelf.showError(keyTitle: nil, keyDesc: "receiptsAndTaxes_alert_title_scannedTaxes", phone: nil, completion: {
                            strongSelf.view.changeScannerDetection(pauseDetection: false)
                        })
                    case .invalidTypeTaxes?:
                        strongSelf.showError(keyTitle: nil, keyDesc: "receiptsAndTaxes_alert_label_scannedReceipts", phone: nil, completion: {
                            strongSelf.view.changeScannerDetection(pauseDetection: false)
                        })
                    }
                }
        })
    }
    
    func showError() {
        self.showError(keyDesc: "Your device does not support scanning a code from an item. Please use a device with a camera.")
    }
    
    func close() {
        view.changeScannerDetection(pauseDetection: true)
        closeButtonTouched(completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.changeScannerDetection(pauseDetection: false)
        })
    }
    
    func goToManualMode() {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return }
        switch type {
        case .bills:
            trackEvent(eventId: TrackerPagePrivate.BillAndTaxesPayBillScanner.Action.manualMode.rawValue, parameters: [:])
        case .taxes:
            trackEvent(eventId: TrackerPagePrivate.BillAndTaxesPayTaxScanner.Action.manualMode.rawValue, parameters: [:])
        }
        if parameter.modeTypeSelector == .camera { //Prevents decreasing number on back navigation
            self.number -= 1
        }
        parameter.modeTypeSelector = .manual
        container?.saveParameter(parameter: parameter)
        container?.rebuildSteps()
        container?.stepFinished(presenter: self)
    }
    
    func cameraIsReady() {
        // this is necessary because some times the forced orientation didn't work properly the first time and we have to wait until the view is in the correct orientation
        if view.orientation() == view.forcedOrientationForPresentation() {
            view.prepareCamera()
            view.startCapturing()
        } else {
            DispatchQueue(label: "check.camera.is.ready").asyncAfter(deadline: .now() + 0.5) {
                DispatchQueue.main.async { [weak self] in
                    self?.cameraIsReady()
                }
            }
        }
    }
    
    private func showScannerError() {
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        let errorTitle: String
        let errorDescription: String
        guard let type = operativeData.typeOperative else { return }
        switch type {
        case .taxes:
            errorTitle = "errorScan_title_dataRecoveryTaxes"
            errorDescription = "errorScan_label_dataRecoveryTaxes"
        case .bills:
            errorTitle = "errorScan_title_dataRecoveryReceipts"
            errorDescription = "errorScan_label_dataRecoveryReceipts"
        }
        navigator.goToError(
            title: dependencies.stringLoader.getString(errorTitle),
            description: dependencies.stringLoader.getString(errorDescription),
            delegate: self
        )
    }
}

extension BarcodeScannerPresenter: ScannerErrorPresenterDelegate {
    
    func scannerErrorDidSelectScanAgain() {
        navigator.goBack { [weak self] in
            self?.view.startCapturing()
        }
    }
    
    func scannerErrorDidSelectManual() {
        navigator.goBack { [weak self] in
            self?.goToManualMode()
        }
    }
    
    func scannerErrorDidSelectClose() {
        self.closeButtonTouched()
    }
    
    func scannerErrorDidSelectGoBack() {
        navigator.goBack { [weak self] in
            self?.view.startCapturing()
        }
    }
}
