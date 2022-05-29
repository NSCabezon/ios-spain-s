//
//  OneAlertView.swift
//  UIOneComponents
//
//  Created by José María Jiménez Pérez on 20/9/21.
//

import UI
import CoreFoundationLib
import OpenCombine

public enum OneAlertType {
    case textOnly(stringKey: String)
    case textAndLink(stringKey: String, linkKey: String)
    case textAndImage(imageKey: String, stringKey: String)
    case textImageAndLink(imageKey: String, stringKey: String, linkKey: String)
}

public class OneAlertView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var alertDescriptionLabel: UILabel!
    @IBOutlet private weak var alertLink: OneAppLink!
    @IBOutlet private weak var linkContainerView: UIView!
    public let linkSubject = PassthroughSubject<Void, Never>()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
    }
    
    public func setType(_ type: OneAlertType) {
        switch type {
        case .textOnly(let stringKey): self.configureTextOnlyWith(stringKey)
        case .textAndImage(let imageKey, let stringKey): self.configureText(stringKey, andImage: imageKey)
        case .textAndLink(let stringKey, let linkKey):
            self.configureTextOnlyWith(stringKey)
            self.configureLink(linkKey)
        case .textImageAndLink(let imageKey, let stringKey, let linkKey):
            self.configureText(stringKey, andImage: imageKey)
            self.configureLink(linkKey)
        }
    }
}

private extension OneAlertView {
    func configureViews() {
        self.alertDescriptionLabel.font = .typography(fontName: .oneB300Regular)
        self.alertDescriptionLabel.textColor = .oneLisboaGray
        self.setupContainer()
        self.setAccessibilityIdentifiers()
    }
    
    func setupContainer() {
        self.containerView.backgroundColor = .onePaleYellow
    }
    
    func configureTextOnlyWith(_ stringKey: String) {
        self.imageView.isHidden = true
        self.linkContainerView.isHidden = true
        self.alertDescriptionLabel.configureText(withKey: stringKey)
    }
    
    func configureText(_ stringKey: String, andImage imageKey: String) {
        self.imageView.isHidden = false
        self.linkContainerView.isHidden = true
        self.alertDescriptionLabel.configureText(withKey: stringKey)
        self.imageView.image = Assets.image(named: imageKey)?.withRenderingMode(.alwaysTemplate)
        self.imageView.tintColor = .oneBlack
    }
    
    func configureLink(_ linkKey: String) {
        self.alertLink.configureButton(type: .secondary,
                                       style: OneAppLink.ButtonContent(text: localized(linkKey),
                                                                       icons: .none,
                                                                       textAlignment: .left))
        self.alertLink.addTarget(self, action: #selector(onAlertLinkTouchUpInside), for: .touchUpInside)
        self.linkContainerView.isHidden = false
    }
    
    func setAccessibilityIdentifiers() {
        self.imageView.accessibilityIdentifier = AccessibilityOneComponents.oneAlertView
        self.alertDescriptionLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAlertIcn
        self.alertLink.accessibilityIdentifier = AccessibilityOneComponents.oneAlertLink
        self.accessibilityIdentifier = AccessibilityOneComponents.oneAlertTitle
    }
    
    @objc func onAlertLinkTouchUpInside() {
        linkSubject.send()
    }
}
