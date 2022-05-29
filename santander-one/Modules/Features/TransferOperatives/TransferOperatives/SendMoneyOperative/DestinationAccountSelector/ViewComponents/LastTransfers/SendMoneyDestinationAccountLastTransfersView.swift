//
//  SendMoneyDestinationAccountLastTransfersView.swift
//  TransferOperatives
//
//  Created by Juan Diego Vázquez Moreno on 29/9/21.
//

import UI
import CoreFoundationLib

private enum Constants {
    enum Layout {
        static let clockIcon: String = "icnOneRecentTransfer"
        static let arrowIcon: String = "icnArrowDown"
    }
    enum EmptyState {
        static let title: String = "generic_label_empty"
        static let subtitle: String = "sendMoney_label_emptyRecentTransfer"
    }
}

public protocol SendMoneyDestinationAccountLastTransfersViewDelegate: AnyObject {
    func didSelectPastTransfer(index: Int)
    func didSelectView(_ view: UIView)
}

public final class SendMoneyDestinationAccountLastTransfersView: XibView {

    enum ViewStatus {
        case loading
        case empty
        case filled(rows: [OnePastTransferViewModel])
    }

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var lastTransfersCollectionView: SendMoneyDestinationAccountLastTransfersCollectionView!
    @IBOutlet private weak var emptyContainerView: UIView!
    @IBOutlet private weak var emptyStateView: EmptyStateView!
    @IBOutlet private weak var loadingContainerView: UIView!
    @IBOutlet private weak var loadingImageView: UIImageView!

    private var accessibilitySuffix: String = "_recent"
    
    weak var delegate: SendMoneyDestinationAccountLastTransfersViewDelegate?

    var viewStatus: ViewStatus = .empty {
        didSet {
            if case let .filled(rows) = viewStatus {
                self.lastTransfersCollectionView.setRows(rows)
            } else {
                self.lastTransfersCollectionView.setRows([])
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

    func configureLastTransfersView(title: LocalizedStylableText,
                                    viewStatus: ViewStatus) {
        self.configureLabels()
        self.titleLabel.configureText(withLocalizedString: title)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.viewStatus = viewStatus
    }

    func updateViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }

    func reloadLastTransfers() {
        self.lastTransfersCollectionView.reloadLastTransfers()
    }

    func scrollToSelectedLastTransfer() {
        self.lastTransfersCollectionView.scrollToSelectedLastTransfer()
    }

    func toggleView(opened: Bool) {
        self.opened = opened
    }

    @objc func didTapOnView() {
        self.delegate?.didSelectView(self)
    }
}

// MARK: - Private methods
private extension SendMoneyDestinationAccountLastTransfersView {
    func setupView() {
        self.configureTopView()
        self.configureLabels()
        self.configureImageViews()
        self.configureEmptyStateView()
        self.configureLoadingView()
        self.configureLastTransfersCollectionView()
        self.setAccessibilityIdentifiers()
    }

    func configureTopView() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(viewTap)
    }

    func configureLabels() {
        self.titleLabel.applyStyle(
            LabelStylist(textColor: .oneLisboaGray, font: .typography(fontName: .oneB400Regular), textAlignment: .right)
        )
    }

    func configureImageViews() {
        self.leftImageView.image = Assets.image(named: Constants.Layout.clockIcon)
        self.rightImageView.image = Assets.image(named: Constants.Layout.arrowIcon)
    }

    func configureEmptyStateView() {
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

    func configureLastTransfersCollectionView() {
        self.lastTransfersCollectionView.collectionDelegate = self
        self.updateContentVisibility()
    }

    func setAccessibilityIdentifiers() {
        self.leftImageView.accessibilityIdentifier = AccessibilitySendMoneyDestination.Carousels.Recents.leftIcon
        self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneyDestination.Carousels.Recents.title
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
            self.toggleViewsVisibility(collectionViewHidden: true, emptyViewHidden: true, loadingViewHidden: true)
            return
        }
        switch viewStatus {
        case .loading:
            self.toggleViewsVisibility(collectionViewHidden: true, emptyViewHidden: true, loadingViewHidden: false)
        case .empty:
            self.toggleViewsVisibility(collectionViewHidden: true, emptyViewHidden: false, loadingViewHidden: true)
        case .filled:
            self.toggleViewsVisibility(collectionViewHidden: false, emptyViewHidden: true, loadingViewHidden: true)
        }
    }

    func toggleViewsVisibility(collectionViewHidden: Bool, emptyViewHidden: Bool, loadingViewHidden: Bool) {
        self.lastTransfersCollectionView.isHidden = collectionViewHidden
        self.emptyContainerView.isHidden = emptyViewHidden
        self.loadingContainerView.isHidden = loadingViewHidden
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

// MARK: - LastTransfersCollectionView delegate
extension SendMoneyDestinationAccountLastTransfersView: SendMoneyDestinationAccountLastTransfersCollectionViewDelegate {
    public func didSelectPastTransfer(index: Int) {
        self.delegate?.didSelectPastTransfer(index: index)
    }
}

extension SendMoneyDestinationAccountLastTransfersView: AccessibilityCapable {}
