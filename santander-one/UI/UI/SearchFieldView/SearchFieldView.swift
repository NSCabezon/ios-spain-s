//
//  SearchFieldView.swift
//  GlobalSearch
//
//  Created by César González Palomino on 24/02/2020.
//

import UIKit
import CoreFoundationLib

public enum SearchFieldViewMode {
    case white
    case general
    
    func clearButtonName() -> String {
        switch self {
        case .white:
            return "icnSearchClearWhite"
        default:
            return "clearField"
        }
    }
}

public final class SearchFieldView: XibView {
    public var textFieldAction: ((_ text: String) -> Void)?
    public var clearIconAction: (() -> Void)?
    public var mode: SearchFieldViewMode = .general

    @IBOutlet public weak var textField: WithoutTitleLisboaTextField!
    
    public var defaultSearchTextFieldStyle: LisboaTextFieldStyle {
        var lisboaTextFieldStyle = LisboaTextFieldStyle.default
        lisboaTextFieldStyle.fieldFont = UIFont.santander(size: 16)
        lisboaTextFieldStyle.fieldTextColor = .lisboaGray
        lisboaTextFieldStyle.containerViewBorderColor = UIColor.lightSky.cgColor
        lisboaTextFieldStyle.verticalSeparatorBackgroundColor = UIColor.darkTorquoise
        lisboaTextFieldStyle.extraInfoHorizontalSeparatorBackgroundColor = UIColor.lightSky
        lisboaTextFieldStyle.extraInfoViewBackgroundColor = .white
        lisboaTextFieldStyle.fieldBackgroundColor = .white
        lisboaTextFieldStyle.containerViewBackgroundColor = .white
        lisboaTextFieldStyle.visibleTitleLabelFont = UIFont.santander(size: 16.0)
        lisboaTextFieldStyle.titleLabelTextColor = UIColor.mediumSanGray
        
        return lisboaTextFieldStyle
    }
    
    private var extraInfoImage = Assets.image(named: "icnSearch")
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public func configure(with handler: TextFieldFormatter?,
                          title: String,
                          style: LisboaTextFieldStyle? = nil,
                          extraInfo: (image: UIImage?, action: (() -> Void)?)?,
                          disabledActions: [TextFieldActions]? = nil,
                          isNeededFloatingTitle: Bool) {
        if let image = extraInfo?.image {
            extraInfoImage = image
        }
        textField.configure(with: handler,
                            title: title,
                            style: style ?? defaultSearchTextFieldStyle,
                            extraInfo: extraInfo,
                            disabledActions: disabledActions)
        textField.setIsNeededFloatingTitle(isNeededFloatingTitle)
    }
    
    private func setup() {
        textField.setCustomStyle(defaultSearchTextFieldStyle)
        textField.configure(with: nil,
                            title: localized("globalSearch_inputText_search"),
                            style: defaultSearchTextFieldStyle,
                            extraInfo: (extraInfoImage, action: nil),
                            disabledActions: TextFieldActions.usuallyDisabledActions)
        textField.field.addTarget(self, action: #selector(textFieldDidChange),
                                  for: UIControl.Event.editingChanged)
        textField.field.autocapitalizationType = .none
        textField.field.returnKeyType = .done
        textField.setAllowOnlyCharacters(.search)
        textField.field.autocorrectionType = .no
        textField.field.accessibilityIdentifier = "areaInputTexts"
        textField.isAccessibilityElement = false
        textField.setAccessibleIdentifiers(titleLabelIdentifier: "globalSearchInputTitle", fieldIdentifier: "globalSearchInputField", imageIdentifier: "globalSearchInputImage")
    }
    
    public func updateTitle(_ title: String?) {
        self.textField.updateTitle(title)
    }
    
    @objc private func textFieldDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        if text.isEmpty {
            textField.configure(extraInfo: (extraInfoImage, action: nil))
        } else {
            textField.configure(extraInfo: (Assets.image(named: mode.clearButtonName()),
                                            action: { [weak self] in
                                                self?.textField.updateData(text: "")
                                                self?.textField.configure(extraInfo: (self?.extraInfoImage, action: nil))
                                                self?.clearIconAction?()
            }))
        }
        textFieldAction?(text)
    }
}
