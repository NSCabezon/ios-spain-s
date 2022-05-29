//
//  BaseCardCollectionViewCell.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 26/02/2020.
//

import UI
import CoreFoundationLib

public enum CardState {
    case active
    case inactive
}

public protocol CardStateConformable {
   func applyStyle(forState state: CardState)
   var cardState: CardState {get set}
}

/// Common elements for every Card, override applyStyle method on subclases to customize UI
public class BaseCardCollectionViewCell: UICollectionViewCell, CardStateConformable {
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var eyeIcon: UIImageView?
    @IBOutlet weak var cvvFakeView: UIView?
    @IBOutlet weak var verticalSeparator: UIView?
    @IBOutlet weak var cardImg: UIImageView?
    @IBOutlet weak var cvvView: CVVView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var shareImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var shareImageViewHeight: NSLayoutConstraint!
    
    public var cardState: CardState = .active
    var currentTask: CancelableTask?
    var viewModel: CardViewModel?
    weak var delegate: CardsCollectionViewCellDelegate?

    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    /// override this method to customize others elements that need be customized
    /// - Parameter state: the state of the card
    public func applyStyle(forState state: CardState) {
        guard let viewModel = self.viewModel else { return }
        self.cardState = state
        if cardState == .active {
            self.shareImageView.isUserInteractionEnabled = true
        } else {
            self.shareImageView.isUserInteractionEnabled = delegate?.isPANAlwaysSharable() ?? true
        }
        self.cvvFakeView?.isUserInteractionEnabled = cardState == .active
        self.cvvFakeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedEyeIcon)))
        self.eyeIcon?.image = Assets.image(named: "icnVisible") ?? eyeIcon?.image
        self.eyeIcon?.changeImageTintColor(tintedWith: viewModel.tintColor)
        switch state {
        case .active:
            if let cardImageUrlString = viewModel.fullCardImageStringUrl {
                currentTask = cardImg?.loadImage(urlString: cardImageUrlString, placeholder: viewModel.cardImageFallback)
            }
            self.verticalSeparator?.backgroundColor = viewModel.tintColor
        case .inactive:
            self.cardImg?.image = Assets.image(named: "defaultdDisabledCard")
            self.activateButton?.layer.masksToBounds = true
            self.activateButton?.layer.cornerRadius = (activateButton?.bounds.height ?? 0.0) / 2.0
            self.activateButton?.layer.borderWidth = 1.0
            self.activateButton?.setTitleColor(UIColor.white, for: .normal)
            self.activateButton?.layer.borderColor = UIColor.darkTorquoise.cgColor
            self.activateButton?.backgroundColor = UIColor.darkTorquoise
            self.activateButton?.setTitle(localized("frequentOperative_label_activate"), for: .normal)
            self.activateButton?.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
            self.activateButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activateButtonDidPressed)))
            self.activateButton?.isUserInteractionEnabled = true
        }
        self.setMaskedPANStyle()
        self.cvvView.setColor(viewModel.tintColor)
        self.shareImageViewWidth.constant = viewModel.shareImageViewNewSize
        self.shareImageViewHeight.constant = viewModel.shareImageViewNewSize
    }
    
    @objc private func activateButtonDidPressed() {
        guard let viewModel = self.viewModel else { return }
        delegate?.didTapOnActivateCard(viewModel)
    }
}

// MARK: - Private methods

private extension BaseCardCollectionViewCell {
    func commonInit() {
        setAccesibilityIdentifiers()
    }
    
    @objc func didPressedEyeIcon() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnCVVViewModel(viewModel)
    }
    
    @objc func didTapOnShare() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnShareViewModel(viewModel)
    }
    
    @objc func didTapOnPANAEye() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnShowPAN(viewModel)
    }
    
    @objc func showNotAvailableOperation() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func setAccesibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityBaseCardHeader.cardData
        eyeIcon?.accessibilityIdentifier = AccessibilityBaseCardHeader.eyeIcon
        cvvFakeView?.accessibilityIdentifier = AccessibilityBaseCardHeader.cvvFakeView
        verticalSeparator?.accessibilityIdentifier = AccessibilityBaseCardHeader.verticalSeparator
        cardImg?.accessibilityIdentifier = AccessibilityBaseCardHeader.cardImg
        cvvView.accessibilityIdentifier = AccessibilityBaseCardHeader.cvvView
        shareImageView.accessibilityIdentifier = AccessibilityBaseCardHeader.shareImageView
        self.activateButton?.accessibilityIdentifier = AccessibilityBaseCardHeader.homeCardBtnHeaderActivateCard
    }
    
    func setMaskedPANStyle() {
        guard let viewModel = self.viewModel else { return }
        self.shareImageView.image = Assets.image(named: viewModel.shareImageView)
        self.shareImageView.changeImageTintColor(tintedWith: viewModel.tintColor)
        if viewModel.maskedPAN {
            self.shareImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnPANAEye)))
        } else {
            self.shareImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnShare)))
        }
    }
}
