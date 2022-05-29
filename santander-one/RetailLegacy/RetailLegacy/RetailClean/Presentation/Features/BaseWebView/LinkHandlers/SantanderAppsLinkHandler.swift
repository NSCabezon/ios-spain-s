import Foundation
import WebViews
import CoreFoundationLib

enum SantanderEcosystem: CaseIterable {
    case retail
    case wallet
    case moneyPlan
    case broker
    case videoCall
    case santanderWatch
    case mini
    case accionistas
    case empresas
    case miComercio
    case criptoCalculadora
    case agro
    
    var scheme: String? {
        switch self {
        case .retail:
            return "santanderretail://"
        case .moneyPlan:
            return SingleSignOnToApp.moneyPlan.getUrl(params: nil)
        case .broker:
            return SingleSignOnToApp.broker.getUrl(params: nil)
        case .videoCall:
            return SingleSignOnToApp.videoCall.getUrl(params: nil)
        case .wallet,
             .santanderWatch,
             .mini,
             .accionistas,
             .empresas,
             .miComercio,
             .criptoCalculadora,
             .agro:
            return nil
        }
    }
    
    var storeId: Int {
        switch self {
        case .retail:
            return 408_043_474
        case .moneyPlan:
            return SingleSignOnToApp.moneyPlan.storeId
        case .broker:
            return SingleSignOnToApp.broker.storeId
        case .videoCall:
            return SingleSignOnToApp.videoCall.storeId
        case .wallet:
            return 979_216_560
        case .santanderWatch:
            return 1_007_514_901
        case .mini:
            return 1_094_814_948
        case .accionistas:
            return 808_231_070
        case .empresas:
            return 976_662_821
        case .miComercio:
            return 12341234
        case .criptoCalculadora:
            return 1_086_679_515
        case .agro:
            return 1_108_352_776
        }
    }
}

class SantanderAppsLinkHandler: BaseWebViewLinkHandler {
    enum Constants {
        static let appStoreUrl = "itunes.apple.com/"
    }
    private lazy var pattern: NSRegularExpression = {
        do {
            return try NSRegularExpression(pattern: "\(Constants.appStoreUrl).*?/app/.*?/id(\\d*)")
        } catch let error {
            RetailLogger.e(String(describing: type(of: self)), "Invalid regular expression: \(error.localizedDescription). Dying.")
            fatalError()
        }
    }()
}

extension SantanderAppsLinkHandler: WebViewLinkHandler {
    
    func willHandle(url: URL?) -> Bool {
        guard let urlString = url?.absoluteString else {
            return false
        }
        return urlString.contains(Constants.appStoreUrl)
    }
    
    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        guard let urlString = request?.url?.absoluteString else {
            return true
        }
        if let appId = appId(inUrl: urlString), let appIdNumber = Int(appId) {
            let found = (SantanderEcosystem.allCases.first { $0.storeId == appIdNumber })
            let scheme = found?.scheme
            delegate?.openApp(scheme: scheme, identifier: appIdNumber)
        }
        return false
    }
    
    private func appId(inUrl url: String) -> String? {
        if let match = pattern.firstMatch(in: url, options: [], range: NSRange(url.startIndex..., in: url)) {
            return url.substring(with: match.range(at: 1))
        }
        return nil
    }
}
