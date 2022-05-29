import UIKit
import IQKeyboardManagerSwift

protocol Mifid3ComplexStepPresenterProtocol: Presenter {
    var cancelButtonTitle: LocalizedStylableText { get }
    var continueButtonTitle: LocalizedStylableText { get }
    func cancelButtonAction()
    func continueAction()
}

class Mifid1FillStepViewController: BaseViewController<Mifid3ComplexStepPresenterProtocol>, UITextViewDelegate {
    
    @IBOutlet weak var titleMessageLabel: UILabel!
    @IBOutlet weak var legalTextLabel: UILabel!
    @IBOutlet weak var confirmationTextView: UITextView!
    @IBOutlet weak var cancelButton: WhiteButton!
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet weak var iconEditButton: UIButton!
    
    var questionText: String {
        get {
            guard let legalText = legalTextLabel.text else { return "" }
            return legalText.deleteAccent().uppercased().replacingOccurrences(of: "\"", with: "")
        }
        set {
            legalTextLabel.text = "\"\(newValue)\""
        }
    }
    
    var confirmationQuestionText: String? {
        get {
            return confirmationTextView.text?.deleteAccent().uppercased()
        }
        set {
            confirmationTextView.text = newValue
        }
    }
    
    var titleLegalText: String? {
        didSet {
            guard let title = titleLegalText else { return }
            titleMessageLabel.text = title
        }
    }
    
    override class var storyboardName: String {
        return mifidStoryboardIdentifier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .uiBackground
        titleMessageLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14), textAlignment: .center))
        
        legalTextLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14), textAlignment: .center))
        
        confirmationTextView.layer.cornerRadius = 5
        confirmationTextView.layer.masksToBounds = true
        confirmationTextView.layer.borderColor = UIColor.lisboaGray.cgColor
        confirmationTextView.layer.borderWidth = 1
        confirmationTextView.tintColor = .sanRed
        confirmationTextView.delegate = self
        
        cancelButton.configureHighlighted(font: .latoMedium(size: 14))
        cancelButton.set(localizedStylableText: presenter.cancelButtonTitle, state: .normal)
        
        continueButton.configureHighlighted(font: .latoMedium(size: 14))
        continueButton.set(localizedStylableText: presenter.continueButtonTitle, state: .normal)
        configureKeyboard()
    }
    
    private func configureKeyboard() {
        IQKeyboardManager.shared.toolbarBarTintColor = .sanRed
        IQKeyboardManager.shared.toolbarTintColor = .uiWhite
        confirmationTextView.keyboardToolbar.doneBarButton.setTitleTextAttributes([.font: UIFont.latoBold(size: 16)], for: .normal)
    }
    
    @IBAction func cancelAction(_ sender: WhiteButton) {
        presenter.cancelButtonAction()
    }
    @IBAction func acceptAction(_ sender: RedButton) {
        presenter.continueAction()
    }
    
    @IBAction func textViewButtonAction(_ sender: UIButton) {
        confirmationTextView.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            iconEditButton.isHidden = false
        } else {
            iconEditButton.isHidden = true
        }
    }
}

extension Mifid1FillStepViewController: MifidView {}
