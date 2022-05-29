import UIKit
import UI
import CoreFoundationLib

protocol MonthSelectionPresenterProtocol: Presenter {
    var titleText: LocalizedStylableText { get }
    var subtitleText: LocalizedStylableText { get }
    var cancelButton: LocalizedStylableText { get }
    var continueButton: LocalizedStylableText { get }
    var months: [String] { get }
    var stringLoader: StringLoader { get }
    var firtsMonth: String { get }
    func monthDidSelected(_ month: String)
    func didCancelSelection()
}

struct PickerModel: PickerElement {
    var value: String
    var accessibilityIdentifier: String?
}

class MonthSelectionViewController: BaseViewController<MonthSelectionPresenterProtocol>, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cancelButton: WhiteButton!
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet weak var dateTextField: NotCopyPasteTextField!
    
    var pickerView: PickerController<PickerModel>?
    
    private let cellIdentifier = "monthCell"
    
    override class var storyboardName: String {
        return "MonthSelectionDialog"
    }
    
    override func prepareView() {
        super.prepareView()
        
        if let containerView = titleLabel.superview {
            containerView.clipsToBounds = true
            containerView.layer.cornerRadius = 4
        }
        
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 18), textAlignment: .left))
        titleLabel.set(localizedStylableText: presenter.titleText)
        
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14), textAlignment: .left))
        subtitleLabel.set(localizedStylableText: presenter.subtitleText)
        
        dateTextField.text = presenter.firtsMonth.camelCasedString
        dateTextField.rightViewMode = .always
        let arrowImg = UIImageView(image: Assets.image(named: "icnArrowDownRed"))
        let size = arrowImg.frame.width
        arrowImg.frame = CGRect(x: -20, y: 0, width: size+20, height: size)
        arrowImg.contentMode = UIView.ContentMode.scaleAspectFit
        dateTextField.rightView = arrowImg
        dateTextField.delegate = self
        (dateTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: UIFont.latoRegular(size: 16), textAlignment: .center))
        
        cancelButton.set(localizedStylableText: presenter.cancelButton, state: .normal)
        continueButton.set(localizedStylableText: presenter.continueButton, state: .normal)
        
        let model = presenter.months.map { PickerModel(value: $0.camelCasedString)}
        pickerView = PickerController(elements: model, labelPrefix: "", relatedView: dateTextField, selectionViewType: .accessoryView)
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: {
            guard let dateText = self.dateTextField.text else { return }
            self.presenter.monthDidSelected(dateText)
        })
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.presenter.didCancelSelection()
        dismiss(animated: true)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(paste(_:)))
            ? false
            : super.canPerformAction(action, withSender: sender)
    }
}
