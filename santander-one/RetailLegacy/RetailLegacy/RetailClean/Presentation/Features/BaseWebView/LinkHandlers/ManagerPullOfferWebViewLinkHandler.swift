import Foundation
import CoreFoundationLib
import WebViews

class ManagerPullOfferWebViewLinkHandler: BaseWebViewLinkHandler {
    var pullOfferAction: OpenWebviewAction?
    
    enum Constants {
        static let photoJavascriptFunction = "setPhoto('\(BaseConstants.serializedTag)');"
        static let selectPhotoUrl = "santanderretail://action?type=pick_image"
        static let selectCamera = "santanderretail://action?type=camera"
        static let selectGallery = "santanderretail://action?type=gallery"
        static let taxesBad1Url = "/recibosSC/inicio.jsp"
        static let taxesBad2Url = "/recibosSC/index.jsp"
        static let fundBad2Url = "/planesSC/index.jsp"
        static let javascriptOtp = "setOTP('%@')"
    }
    
    private enum UrlRedirection {
        case downloadPdf(httpMethod: HTTPMethodType)
        case selectPhoto
        case selectCamera
        case selectGallery
        case badURL
        case openDeepLink(DeepLink)
        case redirect(URLRequest)

        init?(urlString: String?, pullOfferAction: OpenWebviewAction?) {
            var redirection: UrlRedirection?
            guard let url: String = urlString else {
                return nil
            }
            if url.uppercased().contains("APPINTERCEPTOR=PDF") || url.uppercased().contains("PDF=PDF") {
                redirection = url.uppercased().contains("PDFMETHOD=GET") ? .downloadPdf(httpMethod: .get) : .downloadPdf(httpMethod: .post)
            } else if url.uppercased().contains("PDF") {
                redirection = .downloadPdf(httpMethod: .post)
            } else if url.contains(Constants.selectPhotoUrl) {
                redirection = .selectPhoto
            } else if url.contains(Constants.selectCamera) {
                redirection = .selectCamera
            } else if url.contains(Constants.selectGallery) {
                redirection = .selectGallery
            } else if url.contains(Constants.taxesBad1Url)
                || url.contains(Constants.taxesBad2Url)
                || url.contains(Constants.fundBad2Url) {
                redirection = .badURL
            } else if let navigation = (pullOfferAction?.navigations?.first { $0.url == url }) {
                var userInfo: [DeepLinkUserInfoKeys: String] = [:]
                if let offerId = navigation.id {
                    userInfo = [DeepLinkUserInfoKeys.identifier: offerId]
                }
                if let deepLink = DeepLink(navigation.operative, userInfo: userInfo) {
                    redirection = .openDeepLink(deepLink)
                }
            } else if url.uppercased().contains("METHOD=POST") == true {
                guard var urlComponents: URLComponents = URLComponents(string: url),
                let queryItems: [URLQueryItem] = urlComponents.queryItems  else {
                    return nil
                }
                let queryItemsFiltered: [URLQueryItem] = queryItems.filter { (item: URLQueryItem) -> Bool in
                    return item.name.uppercased() != "REDIRECTION" || item.value?.uppercased() != "POST"
                }
                urlComponents.queryItems = queryItemsFiltered
                let components: String? = urlComponents.query
                urlComponents.query = nil
                guard let source: URL = urlComponents.url else {
                    return nil
                }
                var urlRequest: URLRequest = URLRequest(url: source)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = components?.data(using: String.Encoding.utf8)
                redirection = .redirect(urlRequest)
            }
            if let redirection = redirection {
                self = redirection
            } else {
                return nil
            }
        }
    }
    
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    func registerForOtp() {
        self.otpPushManager?.registerOtpHandler(handler: self)
    }
    
    deinit {
        self.otpPushManager?.unregisterOtpHandler()
    }
}

extension ManagerPullOfferWebViewLinkHandler: WebViewLinkHandler {
    func willHandle(url: URL?) -> Bool {
        guard UrlRedirection(urlString: url?.absoluteString, pullOfferAction: pullOfferAction) != nil else {
            return false
        }
        return true
    }
    
    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        guard let redirection = UrlRedirection(urlString: request?.url?.absoluteString, pullOfferAction: pullOfferAction) else {
            return true
        }
        switch redirection {
        case .downloadPdf(let httpMethod):
            if pullOfferAction?.isIgnorePdfEnabled == true {
                delegate?.showLoading()
                return true
            } else {
                self.downloadPdfWithUrl(request?.url, method: httpMethod, displayLoading: displayLoading)
            }
        case .selectPhoto:
            self.selectPhoto(andPlaceInto: Constants.photoJavascriptFunction)
        case .selectCamera:
            self.selectCamera(andPlaceInto: Constants.photoJavascriptFunction)
        case .selectGallery:
            self.selectGallery(andPlaceInto: Constants.photoJavascriptFunction)
        case .badURL:
            return exitWebViewWhenBack()
        case .openDeepLink(let deepLink):
            delegate?.open(deepLink: deepLink)
        case .redirect(let request):
            delegate?.open(request: request)
        }
        return false
    }
    
}

extension ManagerPullOfferWebViewLinkHandler: OtpNotificationHandler {
    func handleOTPCode(_ code: String?, date: Date?) {
        guard let otpCode = code, !otpCode.isEmpty else { return }
        self.otpPushManager?.removeOtpFromUserPref()
        let javascriptOtp = ManagerPullOfferWebViewLinkHandler.Constants.javascriptOtp
        self.delegate?.inject(javascript: String(format: javascriptOtp, otpCode))
    }
}
