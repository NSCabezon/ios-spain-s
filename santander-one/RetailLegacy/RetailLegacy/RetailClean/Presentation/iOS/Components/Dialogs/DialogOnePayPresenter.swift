import Foundation
import CoreFoundationLib

enum OnePayFXOption {
    case standard, immediate, none
}

protocol DialogOnePayDelegate: class {
    //! Selected button tapped on One Pay FX
    func goToOnePayFXTransfer(option: OnePayFXOption)
}

class DialogOnePayPresenter: PrivatePresenter<DialogOnePayViewController, OnePayTransferNavigatorProtocol, DialogOnePayPresenterProtocol> {
    private weak var delegate: DialogOnePayDelegate?
    
    override var screenId: String? {
        return TrackerPagePrivate.NoSepaTransferFxPayDialog().page
    }
    
    init(delegate: DialogOnePayDelegate, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: OnePayTransferNavigatorProtocol) {
        self.delegate = delegate
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
}

extension DialogOnePayPresenter: DialogOnePayPresenterProtocol {
    var titleText: LocalizedStylableText {
        return dependencies.stringLoader.getString("fxPay_title_popup_fxPayPaymentCurrency")
    }
    
    var imageName: String {
        return "icnOnePayfxRetail"
    }
    
    var texts: [LocalizedStylableText] {
        return [dependencies.stringLoader.getString("fxPay_label_popup_payPoundsDollars"), dependencies.stringLoader.getString("fxPay_label_popup_deliveryPeriod"),
        dependencies.stringLoader.getString("fxPay_label_popup_freeSent")]
    }
    
    var standarButtonComponents: DialogButtonComponents {
        return DialogButtonComponents(titled: dependencies.stringLoader.getString("fxPay_button_popup_standard"), does: {
            self.trackEvent(eventId: TrackerPagePrivate.NoSepaTransferFxPayDialog.Action.standard.rawValue, parameters: [:])
            self.delegate?.goToOnePayFXTransfer(option: .standard)
        })
    }
    
    var immediateButtonComponents: DialogButtonComponents {
        return DialogButtonComponents(titled: dependencies.stringLoader.getString("fxPay_button_popup_immediateSend"), does: {
            self.trackEvent(eventId: TrackerPagePrivate.NoSepaTransferFxPayDialog.Action.fxPay.rawValue, parameters: [:])
            self.delegate?.goToOnePayFXTransfer(option: .immediate)
        })
    }
}
