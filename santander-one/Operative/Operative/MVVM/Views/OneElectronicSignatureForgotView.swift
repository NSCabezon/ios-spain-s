//
//  OneElectronicSignatureForgotView.swift
//  UI
//
//  Created by Angel Abad Perez on 21/12/21.
//

import UI
import CoreFoundationLib
import OpenCombine
import UIOneComponents

public protocol OneElectronicSignatureForgotViewDelegate: AnyObject {
    func didTapAcceptButton()
}

// Reactive
public protocol ReactiveOneElectronicSignatureForgotView {
    var publisher: AnyPublisher<Void, Never> { get }
}

public final class OneElectronicSignatureForgotView: XibView {
    private enum Constants {
        static let titleKey: String = "signing_title_popup_rememberInfo"
        static let subtitleKey: String = "signing_text_popup_rememberInfoSigning"
        static let acceptButtonKey: String = "otp_button_understand"
        enum HorizontalStackView {
            static let spacing: CGFloat = 15.0
        }
        enum Icon {
            enum Constraints {
                static let width: CGFloat = 24.0
                static let height: CGFloat = 24.0
            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var acceptButton: OneFloatingButton!
    
    public weak var delegate: OneElectronicSignatureForgotViewDelegate?
    // Reactive
    private let stateSubject = PassthroughSubject<Void, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension OneElectronicSignatureForgotView {
    
    struct OneElectronicSignatureForgotItemViewModel {
        let iconName: String
        let descriptionKey: String
    }
    
    var horizontalStackView: UIStackView {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .top
        horizontalStackView.spacing = Constants.HorizontalStackView.spacing
        return horizontalStackView
    }
    var iconImageView: UIImageView {
        let imageView = UIImageView()
        imageView.heightAnchor.constraint(equalToConstant: Constants.Icon.Constraints.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Constants.Icon.Constraints.width).isActive = true
        return imageView
    }
    var itemLabel: UILabel {
        let label = UILabel()
        label.numberOfLines = .zero
        label.applyStyle(LabelStylist(textColor: UIColor.oneLisboaGray,
                                      font: .typography(fontName: .oneB300Regular),
                                      textAlignment: .left))
        return label
    }
    
    func setupView() {
        self.configureLabels()
        self.configureButton()
        self.setLabelTexts()
        self.setVerticalItems()
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH200Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.font = .typography(fontName: .oneB300Regular)
        self.subtitleLabel.textColor = .oneLisboaGray
    }
    
    func configureButton() {
        self.acceptButton.isEnabled = true
        self.acceptButton.configureWith(type: .primary,
                                              size: .medium(
                                                OneFloatingButton.ButtonSize.MediumButtonConfig(
                                                    title: localized(Constants.acceptButtonKey),
                                                    icons: .none,
                                                    fullWidth: false
                                                )
                                              ),
                                              status: .ready)
        self.acceptButton.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
    }
    
    func setLabelTexts() {
        self.titleLabel.configureText(withKey: Constants.titleKey)
        self.subtitleLabel.configureText(withKey: Constants.subtitleKey)
    }
    
    func setVerticalItems() {
        let items = [
            OneElectronicSignatureForgotItemViewModel(iconName: "oneIcnPhone",
                                                      descriptionKey: "signing_text_popup_rememberInfoForward"),
            OneElectronicSignatureForgotItemViewModel(iconName: "oneIcnEnvelope",
                                                      descriptionKey: "signing_text_popup_rememberInfoRequest"),
            OneElectronicSignatureForgotItemViewModel(iconName: "oneIcnLocation",
                                                      descriptionKey: "signing_text_popup_rememberInfoVisitOffice")
        ]
        items.forEach {
            let horizontalStackView = self.horizontalStackView
            let iconImageView = self.iconImageView
            iconImageView.image = Assets.image(named: $0.iconName)
            iconImageView.accessibilityIdentifier = $0.iconName
            horizontalStackView.addArrangedSubview(iconImageView)
            let label = self.itemLabel
            label.configureText(withKey: $0.descriptionKey)
            label.accessibilityIdentifier = $0.descriptionKey
            horizontalStackView.addArrangedSubview(label)
            self.mainStackView.addArrangedSubview(horizontalStackView)
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityOperative.ForgotSignatureView.forgotView
        self.titleLabel.accessibilityIdentifier = AccessibilityOperative.ForgotSignatureView.forgotTitle
        self.subtitleLabel.accessibilityIdentifier = AccessibilityOperative.ForgotSignatureView.forgotSubtitle
    }
    
    @objc func didTapAcceptButton() {
        self.delegate?.didTapAcceptButton()
        stateSubject.send()
    }
}

// Reactive
extension OneElectronicSignatureForgotView: ReactiveOneElectronicSignatureForgotView {

    public var publisher: AnyPublisher<Void, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
