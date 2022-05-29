import UIKit
import UI

protocol EnableOtpPushChangeAliasPresenterProtocol: Presenter {
    func nextStep()
    func didTapBack()
    func didTapClose()
}

class EnableOtpPushChangeAliasViewController: BaseViewController<EnableOtpPushChangeAliasPresenterProtocol> {
    
    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var aliasTextfield: CustomTextField!
    @IBOutlet weak var aliasHorizontalSeparator: UIView!
    @IBOutlet weak var aliasVerticalSeparator: UIView!
    @IBOutlet weak var aliasView: UIView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var aliasWritteButton: UIButton!
    @IBOutlet weak var aliasDictationButton: UIButton!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var continueButton: RedWhiteButton!
    @IBOutlet weak var backgroudnButton: UIButton!
    var alias: String? {
        return aliasTextfield.text
    }
    
    // MARK: - Class functions
    
    override class var storyboardName: String {
        return "PersonalArea"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_secureDevice")
        )
        builder.setRightActions(
            .close(action: #selector(didTapClose))
        )
        builder.setLeftAction(
            .back(action: #selector(didTapBack))
        )
        builder.build(on: self, with: nil)
        self.editField()
    }

    override func prepareView() {
        super.prepareView()
        self.aliasDictationButton.setImage(Assets.image(named: "icnMicrophone"), for: .normal)
        self.aliasTextfield.formattedDelegate.maxLength = 20
        self.aliasTextfield.delegate = self
        self.view.backgroundColor = UIColor.white
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 20)
        self.titleLabel.textColor = UIColor.gray
        self.titleLabel.set(localizedStylableText: localized(key: "secureDevice_title_alias"))
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 16)
        self.descriptionLabel.textColor = UIColor.gray
        self.descriptionLabel.set(localizedStylableText: localized(key: "secureDevice_label_registrer"))
        self.aliasLabel.font = UIFont.santander(family: .text, type: .regular, size: 17)
        self.aliasLabel.textColor = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1)//???: Que color es este
        self.aliasLabel.set(localizedStylableText: localized(key: "secureDevice_imput_alias"))
        self.aliasTextfield.textColor = UIColor.gray
        self.aliasTextfield.font = UIFont.santander(family: .text, type: .regular, size: 17)
        self.aliasTextfield.backgroundColor = UIColor.clear
        self.aliasTextfield.text = UIDevice.current.model
        self.aliasView.backgroundColor = UIColor.sky30
        self.aliasView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.aliasView.layer.borderWidth = 1
        self.aliasHorizontalSeparator.backgroundColor = UIColor.mediumSkyGray
        self.aliasVerticalSeparator.backgroundColor = UIColor.darkTurqLight
        self.separator.backgroundColor = UIColor.mediumSkyGray
        self.aliasTextfield.tintColor = UIColor.darkTurqLight
    }
    
    // MARK: - Action Functions
    
    @IBAction func editField() {
        changeFieldVisibility(isFieldVisible: true)
        aliasTextfield.becomeFirstResponder()
    }
    
    @IBAction func dictationField() {
        Toast.show(localized(key: "generic_alert_notAvailableOperation").text)
    }
    
    @IBAction func hiddeField() {
        aliasTextfield.resignFirstResponder()
    }
    
    @objc func didTapBack() {
        presenter.didTapBack()
    }
    @objc func didTapClose() {
        presenter.didTapClose()
    }
    
    // MARK: - Public functions
    
    func configureNextStep(withTitle title: LocalizedStylableText) {
        continueButton.configureHighlighted(font: .latoBold(size: 16), isRed: false)
        continueButton.set(localizedStylableText: title.uppercased(), state: .normal)
        continueButton.onTouchAction = { [weak self] _ in
            self?.presenter.nextStep()
        }
    }
    
    func set(title: LocalizedStylableText) {
        self.title = title.text
    }

    func getDeviceName() -> String {
        return UIDevice.current.name
    }
}

// MARK: - ModuleViewController
//
extension EnableOtpPushChangeAliasViewController: ModuleViewController {}

// MARK: - UITextFieldDelegate

extension EnableOtpPushChangeAliasViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let isEmptyText = textField.text?.isEmpty ?? true
        changeFieldVisibility(isFieldVisible: !isEmptyText)
        return true
    }
}

// MARK: - Private Functions

private extension EnableOtpPushChangeAliasViewController {
    func changeFieldVisibility(isFieldVisible: Bool) {
        backgroudnButton.isHidden = !isFieldVisible
        aliasWritteButton.isHidden = isFieldVisible
        UIView.animate(withDuration: 0.5,
        delay: 0.0,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 1,
        options: [],
        animations: {
            self.aliasLabel.font = UIFont.santander(family: .text, type: .regular, size: isFieldVisible ? 12: 17)
            self.aliasTextfield.isHidden = !isFieldVisible
            self.stackview.layoutIfNeeded()
         },
        completion: nil)
    }
}
