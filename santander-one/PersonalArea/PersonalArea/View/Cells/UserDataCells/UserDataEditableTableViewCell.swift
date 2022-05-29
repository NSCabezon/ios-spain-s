//
//  UserDataEditableTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 15/01/2020.
//

import UIKit
import UI

class UserDataEditableTableViewCell: UserDataNavigableTableViewCell, UserDataEditorViewDelegate {
    
    @IBOutlet weak var editorView: UserDataEditorView?
    @IBOutlet private weak var bottomTurquoiseView: UIView!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint?
    
    weak var delegate: PersonalAreaActionCellDelegate?
    var action: PersonalAreaAction?

    private var editingMode: Bool = false {
        didSet {
            editorView?.isHidden = !editingMode
            bottomTurquoiseView.isHidden = !editingMode
        }
    }
    
    private var mode: UserDataEditableMode = .local
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func setCellInfo(_ info: Any?) {
        super.setCellInfo(info)
        guard let info = info as? UserDataEditableCellModelProtocol else { return }
        editingMode = info.editing
        editorView?.configureWith(titleLabel?.text ?? "", descriptionLabel?.text, allowedCharacters: .alias, self)
        editorView?.accessibilityIdentifier = info.editAccessibilityId
        mode = info.mode
        configureForMode(info.mode)
        self.setAccessibilityIdentifiers(info)
    }
    
    func saveValue(_ value: String) {
        editingMode = false
        guard let action = action else { return }
        delegate?.valueDidChange(action, value: value)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        guard let descriptionLabel = descriptionLabel else { return CGSize(width: targetSize.width, height: 70.0)}
        let height = heightWith(descriptionLabel.text ?? "", descriptionLabel.font, targetSize.width - 30)
        return CGSize(width: targetSize.width, height: max(50.0 + height, 70.0))
    }
}

private extension UserDataEditableTableViewCell {
    
    func heightWith(_ text: String, _ font: UIFont, _ width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func configureButton() {
        goToIcon?.image = Assets.image(named: "icnEdit")
        goToIcon?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(enableEditMode)))
        goToIcon?.isUserInteractionEnabled = true
    }
    
    func configureLabels() {
        titleLabel?.font = UIFont.santander(family: .text, type: .light, size: 16.0)
        titleLabel?.textColor = UIColor.lisboaGray
        
        descriptionLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        descriptionLabel?.textColor = UIColor.lisboaGray
    }
    
    @objc func enableEditMode() {
        editingMode = true
        _ = editorView?.becomeFirstResponder()
        delegate?.valueDidChange(.editText, value: "")
    }
    
    func commonInit() {
        configureLabels()
        configureButton()
        editorView?.isHidden = true
        bottomTurquoiseView.isHidden = true
        bottomTurquoiseView.backgroundColor = .darkTurqLight
    }
    
    func configureForMode( _ mode: UserDataEditableMode) {
        goToIcon?.isUserInteractionEnabled = mode == .local
        switch mode {
        case .local:
            buttonHeight?.constant = 32.0
            goToIcon?.image = Assets.image(named: "icnEdit")
        case .web:
            buttonHeight?.constant = 24.0
            goToIcon?.image = Assets.image(named: "icnArrowRightGray")
        case .none:
            buttonHeight?.constant = 0.0
            goToIcon?.image = nil
        }
    }
    
    func setAccessibilityIdentifiers(_ info: UserDataEditableCellModelProtocol) {
        self.goToIcon?.accessibilityIdentifier = info.accessibilityBtn
    }
}

extension UserDataEditableTableViewCell: PersonalAreaActionCellProtocol {
    func setCellDelegate(_ delegate: PersonalAreaActionCellDelegate?, action: PersonalAreaAction?) {
        self.delegate = delegate
        self.action = action
    }
}
