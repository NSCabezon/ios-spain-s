import Foundation
import UI
import UIKit
import CoreFoundationLib
import OpenCombine

enum CardProductDetailIconState: State {
    case idle
    case didTapOnShowPAN
    case didTapOnSharePAN
    case didTapOnShareAccountNumber
}

final class CardProductDetailIconView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    private var isMasked: Bool?
    private var type: CardDetailDataType?
    var state: AnyPublisher<CardProductDetailIconState, Never>
    let stateSubject = CurrentValueSubject<CardProductDetailIconState, Never>(.idle)

    override init(frame: CGRect) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupViewModel(title: CardDetailTitle, isMasked: Bool, type: CardDetailDataType) {
        self.titleLabel?.text = title.title
        self.valueLabel.text = title.value
        self.isMasked = isMasked
        self.iconImageView.image = Assets.image(named: isMasked ? "icnEyeOpenPass" : "icnShare")?.withRenderingMode(.alwaysTemplate)
        self.iconImageView.tintColor = UIColor.darkTorquoise
        self.type = type
        self.configureImageShareAction()
        self.setAccessibilityIdentifiers(isMasked)
    }
}

private extension CardProductDetailIconView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers(_ isMasked: Bool) {
        if let type = type {
            self.view?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailListItem + "_\(type)"
            self.titleLabel.accessibilityIdentifier = AccessibilityCardDetail.cardDetailActionItemTitle + "_\(type)"
            self.valueLabel.accessibilityIdentifier = AccessibilityCardDetail.cardDetailActionItemDescription + "_\(type)"
        }
        
        if isMasked {
            self.iconImageView.accessibilityIdentifier = AccessibilityCardDetail.buttonPAN
        } else {
            self.iconImageView.accessibilityIdentifier = AccessibilityCardDetail.buttonShare
        }
    }
        
    func configureImageShareAction() {
        let tapGestureRecognizer: UITapGestureRecognizer
        switch self.type {
        case .pan:
            tapGestureRecognizer = self.getPANGestureRecognizer()
        case .creditCardAccountNumber:
            tapGestureRecognizer = self.getAccountNumberGestureRecognizer()
        default:
            tapGestureRecognizer = self.getPANGestureRecognizer()
        }
        self.iconImageView.isUserInteractionEnabled = true
        self.iconImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    func getPANGestureRecognizer() -> UITapGestureRecognizer {
        let selector = (self.isMasked ?? false) ? #selector(didTapOnShowPAN(tapGestureRecognizer:)) : #selector(didTapOnSharePAN(tapGestureRecognizer:))
        return UITapGestureRecognizer(target: self, action: selector)
    }

    func getAccountNumberGestureRecognizer() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(didTapOnShareAccountNumber(tapGestureRecognizer:)))
    }
    
    @objc func didTapOnShowPAN(tapGestureRecognizer: UITapGestureRecognizer) {
        stateSubject.send(.didTapOnShowPAN)
    }

    @objc func didTapOnSharePAN(tapGestureRecognizer: UITapGestureRecognizer) {
        stateSubject.send(.didTapOnSharePAN)
    }

    @objc func didTapOnShareAccountNumber(tapGestureRecognizer: UITapGestureRecognizer) {
        stateSubject.send(.didTapOnShareAccountNumber)
    }
}
