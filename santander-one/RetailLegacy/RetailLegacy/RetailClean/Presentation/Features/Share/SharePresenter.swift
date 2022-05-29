protocol ShareNavigatorProtocol: MenuNavigator {}

enum ShareType {
    case mail
    case sms
    case share
}

struct ShareIdentifiers {
    var iconSMS: String?
    var labelSMS: String?
    var containerSMS: String?
    var iconMail: String?
    var labelMail: String?
    var containerMail: String?
    var iconShare: String?
    var labelShare: String?
    var containerShare: String?
}

protocol ShareDelegate: class {
    func didShare(type: ShareType)
    func getRichStringToShare() -> String?
    func getStringToShare() -> String?
    func getExtraTrackShareParameters() -> [String: String]?
}

extension ShareDelegate where Self: TrackerEventProtocol {
    func didShare(type: ShareType) {
        switch type {
        case .mail:
            trackEvent(eventId: TrackerPagePrivate.Generic.Action.mail.rawValue, parameters: getExtraTrackShareParameters() ?? [:])
        case .sms:
            trackEvent(eventId: TrackerPagePrivate.Generic.Action.sms.rawValue, parameters: getExtraTrackShareParameters() ?? [:])
        case .share:
            trackEvent(eventId: TrackerPagePrivate.Generic.Action.share.rawValue, parameters: getExtraTrackShareParameters() ?? [:])
        }
    }
    
    func getExtraTrackShareParameters() -> [String: String]? {
        return nil
    }
    
    func getRichStringToShare() -> String? {
        return nil
    }
}

class SharePresenter: PrivatePresenter<ShareViewController, ShareNavigatorProtocol, SharePresenterProtocol> {
    weak var delegate: ShareDelegate?
    private var identifiers: ShareIdentifiers?
    
    public func setIdentifiers(_ identifiers: ShareIdentifiers) {
        self.identifiers = identifiers
    }
}

extension SharePresenter: Presenter {}

extension SharePresenter: ProgressBarIgnorable {}

extension SharePresenter: SharePresenterProtocol {
    
    func shareByMail() {
        let richStringToShare = delegate?.getRichStringToShare()
        let standardStringToShare = delegate?.getStringToShare()
        if let stringToShare = richStringToShare ?? standardStringToShare {
            let share: ShareCase = .mail(delegate: view, content: stringToShare, subject: nil, toRecipients: [], isHTML: richStringToShare != nil)
            guard share.canShare() else {
                showError(keyDesc: stringLoader.getString("generic_error_settingsMail").text)
                return
            }
            share.show(from: view)
            delegate?.didShare(type: .mail)
        }
    }
    
    func shareBySms() {
        if let stringToShare = delegate?.getStringToShare() {
            let share: ShareCase = .sms(delegate: view, content: stringToShare)
            guard share.canShare() else {
                showError(keyDesc: stringLoader.getString("generic_error_canNotSendSms").text)
                return
            }
            share.show(from: view)
            delegate?.didShare(type: .sms)
        }
    }
    
    func share() {
        if let stringToShare = delegate?.getStringToShare() {
            let share: ShareCase = .share(content: stringToShare)
            share.show(from: view)
            delegate?.didShare(type: .share)
        }
    }
    
    func showError(errorDesc: String) {
        self.showError(keyDesc: errorDesc)
    }
    
    func getIdentifiers() -> ShareIdentifiers? {
        return self.identifiers
    }
}
