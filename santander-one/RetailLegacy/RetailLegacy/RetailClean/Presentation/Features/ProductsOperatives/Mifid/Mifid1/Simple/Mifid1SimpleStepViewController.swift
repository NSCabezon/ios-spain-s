//

import UIKit

let mifidStoryboardIdentifier = "Mifid"

protocol Mifid1StepPresenterProtocol: Presenter {
    var cancelButtonTitle: LocalizedStylableText { get }
    var continueButtonTitle: LocalizedStylableText { get }
    func cancelButton()
    func continueButton()
}

class Mifid1SimpleStepViewController: BaseViewController<Mifid1StepPresenterProtocol> {
    
    @IBOutlet weak var messageTitleTextView: UITextView!
    @IBOutlet weak var messageSubtitleLabel: UILabel!
    @IBOutlet weak var cancelButton: WhiteButton!
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    var messageSubtitle: String {
        get {
            return messageSubtitleLabel.text ?? ""
        }
        set {
            if newValue == "" {
                messageSubtitleLabel.isHidden = true
                scrollView.isScrollEnabled = false
            }
            messageSubtitleLabel.text = newValue
        }
    }
    
    var titleMessage: LocalizedStylableText? {
        didSet {
            guard let text = titleMessage else { return }
            messageTitleTextView.set(localizedStylableText: text)
        }
    }
    
    func hideTitle() {
        messageTitleTextView.text = nil
        topMargin.constant = 0 
    }
    
    override class var storyboardName: String {
        return mifidStoryboardIdentifier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTitleTextView.linkTextAttributes = [.foregroundColor: UIColor.sanRed]
        messageTitleTextView.contentInset = .zero
        messageTitleTextView.textContainerInset = .zero
        messageTitleTextView.textContainer.lineFragmentPadding = 0
        messageTitleTextView.font = .latoRegular(size: 14)
        messageTitleTextView.isEditable = false
        messageTitleTextView.textColor = .sanGreyDark
        messageTitleTextView.textAlignment = .left
        messageTitleTextView.isScrollEnabled = false
        messageTitleTextView.dataDetectorTypes = [.link]
        messageSubtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .left))
        
        cancelButton.configureHighlighted(font: .latoMedium(size: 14))
        cancelButton.set(localizedStylableText: presenter.cancelButtonTitle, state: .normal)
        continueButton.configureHighlighted(font: .latoMedium(size: 14))
        continueButton.set(localizedStylableText: presenter.continueButtonTitle, state: .normal)
        
        self.setupAccesibilityIds()
    }
    
    private func setupAccesibilityIds() {
        self.navigationBarTitleLabel.accessibilityIdentifier = "mifid_title_acceptClosure"
        self.messageTitleTextView.accessibilityIdentifier = "mifid_popupError_stocksMifidInformation"
        self.messageSubtitleLabel.accessibilityIdentifier = "otherText"
        self.cancelButton.accessibilityIdentifier = "mifidBtnCancel"
        self.cancelButton.titleLabel?.accessibilityIdentifier = "generic_button_cancel"
        self.continueButton.accessibilityIdentifier = "mifidBtnContinue"
        self.continueButton.titleLabel?.accessibilityIdentifier = "generic_button_continue"
    }
    
    @IBAction func cancelButtonAction(_ sender: WhiteButton) {
        presenter.cancelButton()
    }
    
    @IBAction func continueButtonAction(_ sender: RedButton) {
        presenter.continueButton()
    }
    
}

extension Mifid1SimpleStepViewController: MifidView {}
