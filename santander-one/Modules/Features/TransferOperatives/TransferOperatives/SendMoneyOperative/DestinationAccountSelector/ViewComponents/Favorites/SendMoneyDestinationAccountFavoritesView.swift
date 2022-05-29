//
//  SendMoneyDestinationAccountFavoritesView.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 27/9/21.
//

import UI
import CoreFoundationLib

protocol SendMoneyDestinationAccountFavoritesViewDelegate: AnyObject {
    func didSelectFavoriteAccount(_ cardViewModel: OneFavoriteContactCardViewModel)
    func didSelectSeeAllFavorites()
    func didSelectView(_ view: UIView)
}

final class SendMoneyDestinationAccountFavoritesView: XibView {
    private enum Constants {
        static let starIcon: String = "icnStar"
        static let arrowIcon: String = "icnArrowDown"
        enum EmptyState {
            static let title: String = "generic_label_empty"
            static let subtitle: String = "sendMoney_label_emptyDontHaveContact"
        }
    }
    
    enum ViewStatus {
        case loading
        case empty
        case filled(sections: [SendMoneyDestinationAccountFavoritesSection])
    }
    
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var favoritesCollectionView: SendMoneyDestinationAccountFavoritesCollectionView!
    @IBOutlet private weak var emptyContainerView: UIView!
    @IBOutlet private weak var emptyStateView: EmptyStateView!
    @IBOutlet private weak var loadingContainerView: UIView!
    @IBOutlet private weak var loadingImageView: UIImageView!

    private var accessibilitySuffix: String = "_favorite"

    weak var delegate: SendMoneyDestinationAccountFavoritesViewDelegate?

    var viewStatus: ViewStatus = .empty {
        didSet {
            if case let .filled(sections) = viewStatus {
                self.favoritesCollectionView.setSections(sections)
            } else {
                self.favoritesCollectionView.setSections([])
            }
            self.updateContentVisibility()
        }
    }
    
    private var opened: Bool = false {
        didSet {
            self.updateArrow()
            self.updateContentVisibility()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configureFavoritesView(title: LocalizedStylableText,
                                viewStatus: ViewStatus) {
        self.configureTitleLabel()
        self.titleLabel.configureText(withLocalizedString: title)
        self.viewStatus = viewStatus
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }

    func updateViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    func scrollToSelectedFavorite() {
        self.favoritesCollectionView.scrollToSelected()
    }

    func toggleView(opened: Bool) {
        self.opened = opened
    }
    
    @objc func didTapOnView() {
        self.delegate?.didSelectView(self)
    }
}

private extension SendMoneyDestinationAccountFavoritesView {
    func setupView() {
        self.configureTopView()
        self.configureTitleLabel()
        self.configureImageViews()
        self.configureFavoritesCollectionView()
        self.configureEmptyView()
        self.configureLoadingView()
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func configureTopView() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(viewTap)
    }
    
    func configureTitleLabel() {
        self.titleLabel.applyStyle(LabelStylist(textColor: UIColor.oneLisboaGray,
                                                font: .typography(fontName: .oneB400Regular),
                                                textAlignment: .right))
    }
    
    func configureImageViews() {
        self.leftImageView.image = Assets.image(named: Constants.starIcon)?.withRenderingMode(.alwaysTemplate)
        self.leftImageView.tintColor = .oneBostonRed
        self.rightImageView.image = Assets.image(named: Constants.arrowIcon)
    }
    
    func configureFavoritesCollectionView() {
        self.favoritesCollectionView.favoritesCollectionDelegate = self
    }

    func configureEmptyView() {
        self.emptyStateView.configure(
            titleKey: Constants.EmptyState.title,
            infoKey: Constants.EmptyState.subtitle,
            buttonTitleKey: nil
        )
        self.emptyStateView.setAccessibilitySuffix(self.accessibilitySuffix)
    }

    func configureLoadingView() {
        self.loadingImageView.setNewJumpingLoader()
    }

    func setAccessibilityIdentifiers() {
        self.leftImageView.accessibilityIdentifier = AccessibilitySendMoneyDestination.Carousels.Favorites.leftIcon
        self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneyDestination.Carousels.Favorites.title
    }

    func updateAccessibilityIdentifiers() {
        self.rightImageView.accessibilityIdentifier = self.opened ?
            AccessibilitySendMoneyDestination.Carousels.Common.rightIconUp + self.accessibilitySuffix :
            AccessibilitySendMoneyDestination.Carousels.Common.rightIconDown + self.accessibilitySuffix
    }
    
    func updateArrow() {
        let rotation = self.opened ? self.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        self.rightImageView?.transform = rotation
        self.updateAccessibilityIdentifiers()
    }

    func updateContentVisibility() {
        guard self.opened else {
            self.favoritesCollectionView.isHidden = true
            self.emptyContainerView.isHidden = true
            self.loadingContainerView.isHidden = true
            return
        }
        switch viewStatus {
        case .loading:
            self.favoritesCollectionView.isHidden = true
            self.emptyContainerView.isHidden = true
            self.loadingContainerView.isHidden = false
        case .empty:
            self.favoritesCollectionView.isHidden = true
            self.emptyContainerView.isHidden = false
            self.loadingContainerView.isHidden = true
        case .filled:
            self.favoritesCollectionView.isHidden = false
            self.emptyContainerView.isHidden = true
            self.loadingContainerView.isHidden = true
        }
    }
    
    func setAccessibilityInfo() {
        self.topView.isAccessibilityElement = true
        self.updateAccessibility()
    }
    
    func updateAccessibility() {
        let tapTwiceTo: String = localized("voiceover_tapTwiceTo")
        let open: String = localized("voiceover_open")
        self.topView.accessibilityHint = self.opened ? nil : "\(tapTwiceTo) \(open)"
        self.topView.accessibilityLabel = self.titleLabel.text
    }
}

extension SendMoneyDestinationAccountFavoritesView: SendMoneyDestinationAccountFavoritesCollectionViewDelegate {
    func didSelectFavoriteAccount(_ cardViewModel: OneFavoriteContactCardViewModel) {
        self.delegate?.didSelectFavoriteAccount(cardViewModel)
    }
    
    func didSelectAllFavorites() {
        self.delegate?.didSelectSeeAllFavorites()
    }
}

extension SendMoneyDestinationAccountFavoritesView: AccessibilityCapable {}
