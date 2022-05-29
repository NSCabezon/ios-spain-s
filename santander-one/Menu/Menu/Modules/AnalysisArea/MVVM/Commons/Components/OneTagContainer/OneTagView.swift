//
//  OneTagView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 20/4/22.
//

import CoreFoundationLib
import UI
import UIOneComponents

public class OneTagView: UIView {
    var identifier: String = "" {
        willSet {
            self.closeFilter.identifier = newValue
        }
    }
    private lazy var imageClose: UIImageView = {
        let closeImage = UIImageView()
        closeImage.image = Assets.image(named: "tagCloseIcon")
        closeImage.translatesAutoresizingMaskIntoConstraints = false
        return closeImage
    }()
    private lazy var closeFilter: OneTagButton = {
        let closeFltr = OneTagButton()
        closeFltr.backgroundColor = .clear
        closeFltr.translatesAutoresizingMaskIntoConstraints = false
        closeFltr.addTarget(nil, action: Selector("closeButtonTapped:"), for: .touchUpInside)
        return closeFltr
    }()
    private lazy var tagDescriptionLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.font = .typography(fontName: .oneB300Bold)
        tagLabel.textColor = .oneDarkTurquoise
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.backgroundColor = .clear
        return tagLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    public func setTagLabel(_ text: LocalizedStylableText) {
        self.tagDescriptionLabel.configureText(withLocalizedString: text)
    }
    
    private func setupViews() {
        self.addSubview(imageClose)
        self.addSubview(tagDescriptionLabel)
        self.backgroundColor = .oneWhite
        self.setOneCornerRadius(type: .oneShRadius4)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.oneDarkTurquoise.cgColor
        self.tagDescriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 7).isActive = true
        self.tagDescriptionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.imageClose.widthAnchor.constraint(equalToConstant: 16).isActive = true
        self.imageClose.heightAnchor.constraint(equalToConstant: 16).isActive = true
        self.imageClose.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4).isActive = true
        self.imageClose.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.addSubview(closeFilter)
        self.closeFilter.fullFit()
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: self.groupAccessibilityElements)
    }
}

extension OneTagView {
    public func setText(_ lText: LocalizedStylableText) {
        self.tagDescriptionLabel.configureText(withLocalizedString: lText)
        self.setAccessibilityLabels(lText.text)
    }
    
    func setAccessibilityIdentifiers(_ mainAccessibilityIdentifier: String) {
        self.accessibilityIdentifier = mainAccessibilityIdentifier
        closeFilter.accessibilityIdentifier = "btn_close_\(mainAccessibilityIdentifier)"
        imageClose.accessibilityIdentifier = "tagCloseIcn_\(mainAccessibilityIdentifier)"
        tagDescriptionLabel.accessibilityIdentifier = "description_label_\(mainAccessibilityIdentifier)"
    }
}

private extension OneTagView {
    func setAccessibilityIdentifiers() {
        imageClose.isAccessibilityElement = true
        setAccessibility { self.imageClose.isAccessibilityElement = false }
        imageClose.accessibilityIdentifier = "closeFilterImage"
        closeFilter.accessibilityIdentifier = "closeFilter"
        tagDescriptionLabel.accessibilityIdentifier = "search_tab_expenses"
    }

    func setAccessibilityLabels(_ text: String) {
        closeFilter.accessibilityLabel = localized("voiceover_removeFilter")
        tagDescriptionLabel.accessibilityLabel = text
    }
    
    func groupAccessibilityElements() {
        self.accessibilityElements = {
            var elements: [Any] = []
            elements.append(contentsOf: [closeFilter, tagDescriptionLabel])
            return elements
        }()
    }
}

extension OneTagView: AccessibilityCapable { }

class OneTagButton: UIButton {
    var identifier: String = ""
}
