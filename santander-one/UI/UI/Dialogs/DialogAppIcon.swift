//
//  DialogChangeAppIcon.swift
//  UI
//
//  Created by David Gálvez Alonso on 22/09/2020.
//

import CoreFoundationLib

public struct DialogAppIcon {
    let iconName: String?
    let action: ((_ exitConfirmed: Bool, _ checkButtonSelected: Bool) -> Void)?
    
    public init(
        iconName: String?,
        action: ((_ exitConfirmed: Bool, _ checkButtonSelected: Bool) -> Void)?
    ) {
        self.iconName = iconName
        self.action = action
    }
    
    public func show(in viewController: UIViewController) {
        let dialogViewController = DialogAppIconViewController(with: self)
        dialogViewController.modalPresentationStyle = .overCurrentContext
        dialogViewController.modalTransitionStyle = .crossDissolve
        viewController.present(dialogViewController, animated: true, completion: nil)
    }
}

final class DialogAppIconViewController: UIViewController {
    private let dialog: DialogAppIcon
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var smallTitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var confirmButton: WhiteLisboaButton!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var checkLabel: UILabel!
        
    init(with dialog: DialogAppIcon) {
        self.dialog = dialog
        super.init(nibName: "DialogAppIconViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFrame()
        configureLabels()
        configureButtons()
        setAccessibilityIdentifiers()
    }
}

// MARK: - Private methods
private extension DialogAppIconViewController {
    func configureFrame() {
        guard let iconName = self.dialog.iconName else { return }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        alertView.backgroundColor = UIColor.white
        alertView.layer.cornerRadius = 5.0
        separatorView.backgroundColor = .mediumSky
        logoImageView.image = UIImage(named: iconName)
        logoImageView.drawRoundedAndShadowedNew(radius: 20.0)
    }
    
    func configureLabels() {
        self.smallTitleLabel.configureText(withKey: "pg_title_popup_specialDays", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16.0)))
        self.smallTitleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "pg_title_popup_changeIcnApp", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 20.0), lineHeightMultiple: 0.75))
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.configureText(withKey: "pg_text_popup_automaticChangeApp", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12.0), lineHeightMultiple: 0.82))
        self.descriptionLabel.textColor = .lisboaGray
        self.checkLabel.configureText(withKey: "generic_label_notShow", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0)))
        self.checkLabel.textColor = .mediumSanGray
        self.checkLabel.isUserInteractionEnabled = true
        self.checkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkButtonAction)))
    }
    
    func configureButtons() {
        closeButton.setImage(Assets.image(named: "icnCloseGray"), for: .normal)
        closeButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        confirmButton.addSelectorAction(target: self, #selector(confirmButtonPressed))
        confirmButton.setTitle(localized("pg_popup_changeIcnApp"), for: UIControl.State.normal)
        confirmButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        checkButton.isSelected = false
        checkButton.setImage(Assets.image(named: "icnCheckBoxSelectedGreen"), for: .selected)
        checkButton.setImage(Assets.image(named: "icnCheckBoxUnSelected"), for: .normal)
    }

    @objc func confirmButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        self.dialog.action?(true, checkButton.isSelected)
    }
    
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        self.dialog.action?(false, checkButton.isSelected)
    }
        
    @IBAction func checkButtonAction(_ sender: Any) {
        checkButton.isSelected.toggle()
    }
    
    func setAccessibilityIdentifiers() {
        alertView.accessibilityIdentifier = AccessibilityDialogAppIcon.alertView.rawValue
        closeButton.accessibilityIdentifier = AccessibilityDialogAppIcon.closeButton.rawValue
        smallTitleLabel.accessibilityIdentifier = AccessibilityDialogAppIcon.smallTitleLabel.rawValue
        titleLabel.accessibilityIdentifier = AccessibilityDialogAppIcon.titleLabel.rawValue
        logoImageView.accessibilityIdentifier = AccessibilityDialogAppIcon.logoImageView.rawValue
        descriptionLabel.accessibilityIdentifier = AccessibilityDialogAppIcon.descriptionLabel.rawValue
        confirmButton.accessibilityIdentifier = AccessibilityDialogAppIcon.confirmButton.rawValue
        checkButton.accessibilityIdentifier = AccessibilityDialogAppIcon.checkButton.rawValue
    }
}
