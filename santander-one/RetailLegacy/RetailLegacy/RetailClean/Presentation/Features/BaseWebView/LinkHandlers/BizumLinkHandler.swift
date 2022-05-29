import Foundation
import CoreFoundationLib
import WebViews

class BizumLinkHandler: BaseWebViewLinkHandler {
    internal lazy var storeManager = ContactsStoreManager()
    
    enum Constants {
        enum Contacts {
            static let oldContactsUrl = "http://bizum/selectContact/"
            static let newContactsUrl = "http://bizum/selectContacts/"
            static let javascriptOtp = "setOTP('%@')"
        }
        enum Photo {
            static let photoJavascriptFunction = "setPhoto('\(BaseConstants.serializedTag)');"
            static let selectPhotoUrl = "http://bizum/selectPhoto/"
        }
        enum Back {
            static let invalidateBack = ["#!/seleccionar", "/seleccionCuenta.html", "/acceso.htm"]
            static let index = "index.jsp"
            static let goBackJavascriptFunction = "doGoBack()"
        }
        enum Pdf {
            static let pdfSignal1 = "appInterceptor=pdf"
            static let pdfSignal2 = "pdf=pdf"
        }
    }
    
    private enum UrlRedirection {
        case contactsOld
        case contactsNew
        case selectPhoto
        case downloadPdf
        
        init?(urlString: String?) {
            if urlString?.contains(Constants.Contacts.oldContactsUrl) == true {
                self = .contactsOld
            } else if urlString?.contains(Constants.Contacts.newContactsUrl) == true {
                self = .contactsNew
            } else if urlString?.contains(Constants.Photo.selectPhotoUrl) == true {
                self = .selectPhoto
            } else if urlString?.contains(Constants.Pdf.pdfSignal1) == true || urlString?.contains(Constants.Pdf.pdfSignal2) == true {
                self = .downloadPdf
            } else {
                return nil
            }
        }
    }
    
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    func set(storeManager: ContactsStoreManager) {
        self.storeManager = storeManager
    }
    
    func registerForOtp() {
        self.otpPushManager?.registerOtpHandler(handler: self)
    }
    
    deinit {
        self.otpPushManager?.unregisterOtpHandler()
    }
}

extension BizumLinkHandler: WebViewLinkHandler {
    
    func willHandle(url: URL?) -> Bool {
        guard UrlRedirection(urlString: url?.absoluteString) != nil else {
            return false
        }
        return true
    }
    
    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        guard let redirection = UrlRedirection(urlString: request?.url?.absoluteString) else {
            return true
        }
        
        switch redirection {
        case .contactsOld:
            self.handleOldContactsVersion()
        case .contactsNew:
            self.handleNewContactsVersion()
        case .selectPhoto:
            selectPhoto(andPlaceInto: Constants.Photo.photoJavascriptFunction)
        case .downloadPdf:
            downloadPdfWithUrl(request?.url, method: .get, displayLoading: displayLoading)
        }
        return false
    }
    
    func willHandleBack(url: URL?) -> Bool {
        
        guard let urlString = url?.absoluteString else {
            return false
        }
        if mustInvalidateBack(forUrl: urlString) {
            return true
        }
        return urlString.contains(Constants.Back.index)
    }
    
    func handleBack(url: URL?) {
        guard let urlString = url?.absoluteString else {
            return
        }
        
        guard !mustInvalidateBack(forUrl: urlString) else {
            delegate?.exitWebView(reloadGlobalPosition: true)
            return
        }
        
        delegate?.inject(javascript: Constants.Back.goBackJavascriptFunction)
    }
    
    private func mustInvalidateBack(forUrl urlString: String) -> Bool {
        return Constants.Back.invalidateBack.first { urlString.contains($0) } != nil
    }
}

extension BizumLinkHandler: OtpNotificationHandler {
    func handleOTPCode(_ code: String?, date: Date?) {
        guard let otpCode = code, !otpCode.isEmpty else { return }
        self.otpPushManager?.removeOtpFromUserPref()
        let javascriptOtp = BizumLinkHandler.Constants.Contacts.javascriptOtp
        Async.after(seconds: 2.0) {
            self.delegate?.inject(javascript: String(format: javascriptOtp, otpCode))
        }
    }
}

extension BizumLinkHandler: OpenWebviewNewContactsCapable { }
