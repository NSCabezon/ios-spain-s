import UIKit
import UI
import CoreFoundationLib

protocol ChangedGPProductProtocol: AnyObject {
    func updateModel(_ info: GPCustomizationProductViewModel)
    func hideAllEditingFields()
    func didUpdateAlias(_ info: GPCustomizationProductViewModel)
}

protocol ChangedGPSectionProtocol: AnyObject {
    func updateModel(_ info: [GPCustomizationProductViewModel])
    func hideAllEditingFields()
    func didUpdateAlias(_ info: GPCustomizationProductViewModel)
    func trackMoved(_ info: GPCustomizationProductViewModel)
    func trackChangedSwitch(_ info: GPCustomizationProductViewModel)
}

final class GPCustomizationProductTableViewCell: UITableViewCell {
    private var model: GPCustomizationProductViewModel!
    private var aliasTextFieldSize: Int = 20
    private var charSet: CharacterSet = .alias
	
    weak var delegate: ChangedGPProductProtocol?

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var availableSwitch: UISwitch!
    @IBOutlet weak var editAliasView: UIView!
    @IBOutlet weak var editAliasTextField: LimitedTextField!
    @IBOutlet weak var saveNewAliasButton: WhiteLisboaButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        nameLabel.font = UIFont.santander(family: .text, size: 16.0)
        nameLabel.textColor = .lisboaGray

        editButton.setImage(Assets.image(named: "icnEdit"), for: .normal)

        availableSwitch.transform = CGAffineTransform(scaleX: 0.78, y: 0.77)
        availableSwitch.addTarget(self, action: #selector(switchDidChange), for: UIControl.Event.valueChanged)

        saveNewAliasButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 12)
        saveNewAliasButton.setTitle(localized("generic_button_change"), for: .normal)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTouchSaveButton))
        saveNewAliasButton.addGestureRecognizer(gesture)

        resetView()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        setReorderControlImage(Assets.image(named: "icnDragLine"))
        
        self.subviews.first(where: {
            let type = type(of: $0)
            let string = String(describing: type)
            return string == "UITableViewCellReorderControl"
        })?.frame.origin.x = self.frame.maxX - 5 - 25
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetView()
    }

    private func resetView() {
        DispatchQueue.main.async {
            self.editAliasView.backgroundColor = .skyGray
            self.editAliasTextField.textColor = .lisboaGray
            self.editAliasTextField.tintColor = .botonRedLight
            self.editAliasTextField.font = UIFont.santander(family: .text, type: .regular, size: 15)
            self.editAliasTextField.configure(maxLength: self.aliasTextFieldSize, characterSet: self.charSet, onlyCheckCharactersInTheReplacementString: true)
            self.editAliasTextField.delegate = nil
            self.editAliasView.isHidden = true
            self.cardImageView.image = nil
        }
    }

    private func configureInfo() {
        if let imageUrl = model.imageUrl {
            _ = cardImageView.loadImage(urlString: imageUrl, placeholder: Assets.image(named: "defaultCard"), completion: nil)
            cardImageView.isHidden = false
            cardImageView.alpha = model.isDisabled ? 0.5: 1.0
        } else {
            cardImageView.isHidden = true
        }
        editButton.isHidden = !model.isEditable
        nameLabel.alpha = model.isDisabled ? 0.5: 1.0
        nameLabel.text = model.customAlias ?? model.productName
        availableSwitch.isOn = model.isVisible
    }
	
    func configureTextfield(configuration: ProductAlias?) {
        guard let productAlias = configuration else {
            editAliasTextField.configure(maxLength: 20, characterSet: .alias, onlyCheckCharactersInTheReplacementString: true)
            return
        }
        aliasTextFieldSize = productAlias.maxChars
        charSet = productAlias.charSet
        editAliasTextField.configure(maxLength: aliasTextFieldSize, characterSet: charSet, onlyCheckCharactersInTheReplacementString: true)
    }
    
    func disableEditingMode() {
        editAliasView.isHidden = true
        endEditing(false)
        showsReorderControl = true
    }

    func setCellInfo(_ info: GPCustomizationProductViewModel) {
        self.model = info
        configureInfo()
        setAccessibility()
    }

    @IBAction func didTouchEditButton(_ sender: Any) {
        delegate?.hideAllEditingFields()
        var alias = model.customAlias ?? model.productName
        if aliasTextFieldSize < alias.count, let substring = alias.substring(0, aliasTextFieldSize) {
            alias = substring
        }
        editAliasTextField.text = alias
        editAliasView.isHidden = false
        showsReorderControl = false
        editAliasTextField.becomeFirstResponder()
    }

    @objc func didTouchSaveButton() {
        editAliasView.isHidden = true
        endEditing(false)
        showsReorderControl = true
        if let text = editAliasTextField.text, !text.isEmpty {
            let productName: String
            if model.productName.count > aliasTextFieldSize {
                productName = model.productName.substring(0, aliasTextFieldSize) ?? model.productName
            } else {
                productName = model.productName
            }
            model.customAlias = text != productName ? text: productName
            model.newAlias = text
        } else {
            model.newAlias = nil
        }
        delegate?.updateModel(model)
        model.updateAlias()
        delegate?.didUpdateAlias(model)
    }
    
    @objc func switchDidChange() {
        model.isVisible = availableSwitch.isOn
        delegate?.updateModel(model)
    }
    
    private func setAccessibility() {
        let type = model.productType?.rawValue.lowercased() ?? ""
        self.nameLabel.accessibilityIdentifier = "name_label_\(type)"
        self.editButton.accessibilityIdentifier = "edit_button_\(type)"
        self.cardImageView.accessibilityIdentifier = "card_image_\(type)"
        self.availableSwitch.accessibilityIdentifier = "available_switch_\(type)"
        self.editAliasTextField.accessibilityIdentifier = "edit_textfield_\(type)"
        self.saveNewAliasButton.accessibilityIdentifier = "changeAlias_button_\(type)"
    }
}
