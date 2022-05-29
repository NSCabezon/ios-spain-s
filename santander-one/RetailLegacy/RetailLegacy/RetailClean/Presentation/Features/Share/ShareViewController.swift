import UIKit
import MessageUI
import UI

protocol SharePresenterProtocol {
    func shareByMail()
    func shareBySms()
    func share()
    func showError(errorDesc: String)
    func getIdentifiers() -> ShareIdentifiers?
}

class ShareViewController: BaseViewController<SharePresenterProtocol> {
    
    @IBOutlet private weak var shareView: UIStackView!
    @IBOutlet private weak var mailLabel: UILabel!
    @IBOutlet private weak var smsLabel: UILabel!
    @IBOutlet private weak var shareLabel: UILabel!
    @IBOutlet private weak var smsImageView: UIImageView!
    @IBOutlet private weak var mailImageView: UIImageView!
    @IBOutlet private weak var shareImageView: UIImageView!
    @IBOutlet private weak var smsContainer: UIView!
    @IBOutlet private weak var mailContainer: UIView!
    @IBOutlet private weak var shareContainer: UIView!
    
    
    override class var storyboardName: String {
        return "Share"
    }
    
    override func prepareView() {
        super.prepareView()

        shareView.arrangedSubviews.forEach { $0.drawRoundedAndShadowed() }
        
        let fontConstant: CGFloat = UIDevice.current.isSmallScreenIphone ? 14.0 : 16.0
        smsImageView.image = Assets.image(named: "icnSmss")
        mailImageView.image = Assets.image(named: "icnMailMadrid")
        shareImageView.image = Assets.image(named: "icnShareMadrid")
        mailLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontConstant)))
        smsLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontConstant)))
        shareLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontConstant)))
        
        mailLabel.set(localizedStylableText: stringLoader.getString("generic_button_mail"))
        smsLabel.set(localizedStylableText: stringLoader.getString("generic_button_sms"))
        shareLabel.set(localizedStylableText: stringLoader.getString("generic_button_share"))
        if let identifiers = presenter.getIdentifiers() {
            smsLabel.accessibilityIdentifier = identifiers.labelSMS
            smsImageView.accessibilityIdentifier = identifiers.iconSMS
            smsImageView.image?.accessibilityIdentifier = identifiers.iconSMS ?? "" + "Image"
            smsContainer.accessibilityIdentifier = identifiers.containerSMS
            mailLabel.accessibilityIdentifier = identifiers.labelMail
            mailImageView.accessibilityIdentifier = identifiers.iconMail
            mailImageView.image?.accessibilityIdentifier = identifiers.iconMail ?? "" + "Image"
            mailContainer.accessibilityIdentifier = identifiers.containerMail
            shareLabel.accessibilityIdentifier = identifiers.labelShare
            shareImageView.accessibilityIdentifier = identifiers.iconShare
            shareImageView.image?.accessibilityIdentifier = identifiers.iconShare ?? "" + "Image"
            shareContainer.accessibilityIdentifier = identifiers.containerShare
        }
    }
    
    @IBAction func shareByMail(_ sender: Any) {
        presenter.shareByMail()
    }
    
    @IBAction func shareBySms(_ sender: Any) {
        presenter.shareBySms()
    }
    
    @IBAction func share(_ sender: Any) {
        presenter.share()
    }
}
