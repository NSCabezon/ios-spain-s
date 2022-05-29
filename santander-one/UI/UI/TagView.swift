//
//  TagView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 11/02/2020.
//

import CoreFoundationLib

public class TagView: UIView {
    
    var identifier: String = "" {
        willSet {
            self.closeFilter.identifier = newValue

        }
    }
    
    /// close button wich contain the identifier of the view. This view does not recognize touch of this button. It will be reoc
    private lazy var imageClose: UIImageView = {
        let closeImage = UIImageView()
        closeImage.image = Assets.image(named: "tagCloseIcon")
        closeImage.translatesAutoresizingMaskIntoConstraints = false
        return closeImage
    }()
    
    private lazy var closeFilter: TagButton = {
        let closeFltr = TagButton()
        closeFltr.backgroundColor = .clear
        closeFltr.translatesAutoresizingMaskIntoConstraints = false
        closeFltr.addTarget(nil, action: Selector("closeButtonTapped:"), for: .touchUpInside)
        return closeFltr
    }()
    
    private lazy var tagDescriptionLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.font = UIFont.santander(family: .text, type: .regular, size: 10.0)
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
        self.backgroundColor = UIColor.skyGray
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.layer.cornerRadius = 3
        
        self.imageClose.widthAnchor.constraint(equalToConstant: 16).isActive = true
        self.imageClose.heightAnchor.constraint(equalToConstant: 16).isActive = true
        self.imageClose.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4).isActive = true
        self.imageClose.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.tagDescriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.tagDescriptionLabel.leftAnchor.constraint(equalTo: self.imageClose.rightAnchor, constant: 2).isActive = true
        self.tagDescriptionLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
        self.tagDescriptionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(closeFilter)
        self.closeFilter.fullFit()
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: self.groupAccessibilityElements)
    }
}

extension TagView {
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

private extension TagView {
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

extension TagView: AccessibilityCapable { }

public class TagButton: UIButton {
    var identifier: String = ""
}
