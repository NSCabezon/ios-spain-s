//
//  OneFavoriteContactCardView.swift
//  UIOneComponents
//
//  Created by Juan Diego Vázquez Moreno on 3/9/21.
//

import UI
import CoreFoundationLib

// MARK: - Layout Constants

private enum LayoutConstants {
    static let checkIcon: String = "icnCheckOvalGreen"
    static let cornerRadiusType: OneCornerRadiusType = .oneShRadius8
    static let shadowType: OneShadowsType = .oneShadowLarge
    static let nameFont: FontName = .oneB300Bold
    static let accountFont: FontName = .oneB300Regular
}

// MARK: - Delegate

public protocol OneFavoriteContactCardDelegate: AnyObject {
    func didSelectFavoriteContact(_ contactName: String)
}

// MARK: - OneFavoriteContactCard

public final class OneFavoriteContactCardView: XibView {
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var avatarView: OneAvatarView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var accountNumberLabel: UILabel!
    @IBOutlet private weak var accountLogoImageView: UIImageView!

    public weak var delegate: OneFavoriteContactCardDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
}

// MARK: - Public functions

public extension OneFavoriteContactCardView {
    func setupFavoriteContactViewModel(_ viewModel: OneFavoriteContactCardViewModel) {
        self.configureAvatar(viewModel.avatar)
        self.configureByStatus(viewModel.cardStatus)
        self.configureBankLogo(viewModel.bankLogoURL)
        self.setLabelTexts(viewModel)
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

// MARK: - Configurations

private extension OneFavoriteContactCardView {

    // MARK: - Layout configuration

    func configureView() {
        self.configureViews()
        self.configureLabels()
        self.configureImageViews()
        self.configureDefaultStatus()
        self.setAccessibilityIdentifiers()
    }

    func configureViews() {
        self.contentView.setOneCornerRadius(type: LayoutConstants.cornerRadiusType)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnCard))
        self.view?.addGestureRecognizer(tapGestureRecognizer)
    }

    func configureLabels() {
        self.nameLabel.font = .typography(fontName: LayoutConstants.nameFont)
        self.accountNumberLabel.font = .typography(fontName: LayoutConstants.accountFont)
    }

    func configureImageViews() {
        self.checkImageView.image = Assets.image(named: LayoutConstants.checkIcon)
    }

    func configureDefaultStatus() {
        self.configureByStatus(.inactive)
    }

    // MARK: - Status configuration

    func configureAvatar(_ viewModel: OneAvatarViewModel) {
        self.avatarView.setupAvatar(viewModel)
    }

    func configureByStatus(_ status: OneFavoriteContactCardViewModel.CardStatus) {
        self.contentView.backgroundColor = status.backgroundColor
        switch status {
        case .inactive:
            self.contentView.setOneShadows(type: LayoutConstants.shadowType)
            self.checkImageView.isHidden = true
        case .selected:
            self.contentView.setOneShadows(type: .none)
            self.checkImageView.isHidden = false
        }
    }
    
    func configureBankLogo(_ logoUrl: String?) {
        guard let logoUrl = logoUrl else {
            self.accountLogoImageView.isHidden = true
            return
        }
        _ = self.accountLogoImageView.setImage(url: logoUrl, options: [], completion: { [weak self] image in
            self?.accountLogoImageView.image = image
            self?.accountLogoImageView.isHidden = (self?.accountLogoImageView.image == nil)
        })
    }

    func setLabelTexts(_ viewModel: OneFavoriteContactCardViewModel) {
        self.nameLabel.text = viewModel.name
        self.accountNumberLabel.text = viewModel.shortIBAN
    }

    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneFavoriteContactCardView + (suffix ?? "")
        self.nameLabel.accessibilityIdentifier = AccessibilityOneComponents.oneFavoriteContactCardName + (suffix ?? "")
        self.accountNumberLabel.accessibilityIdentifier = AccessibilityOneComponents.oneFavoriteContactCardAccount + (suffix ?? "")
        self.checkImageView.accessibilityIdentifier = AccessibilityOneComponents.oneFavoriteContactCardCheckIcn + (suffix ?? "")
        self.accountLogoImageView.accessibilityIdentifier = AccessibilityOneComponents.oneFavoriteContactCardBankLogo + (suffix ?? "")
        self.checkImageView.accessibilityIdentifier = AccessibilityOneComponents.oneFavoriteContactCardCheckIcn + (suffix ?? "")
        self.avatarView.setAccessibilitySuffix(suffix ?? "")
        self.view?.isUserInteractionEnabled = true
    }
}

// MARK: - Private functions

private extension OneFavoriteContactCardView {
    @objc func didTapOnCard() {
        guard let contactName = self.nameLabel.text else { return }
        self.delegate?.didSelectFavoriteContact(contactName)
    }
}
