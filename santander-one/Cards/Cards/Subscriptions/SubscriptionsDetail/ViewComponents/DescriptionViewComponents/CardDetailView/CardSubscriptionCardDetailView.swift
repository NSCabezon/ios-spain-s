//
//  CardSubscriptionDateView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol DidTapInCardDetailViewDelegate: AnyObject {
    func didTapInCardDetailView()
}

public final class CardSubscriptionCardDetailView: XibView {
    @IBOutlet private weak var cardStaticLabel: UILabel!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var cardAliasLabel: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!

    private lazy var defaultImage: UIImage? = {
        return Assets.image(named: "defaultCard")
    }()
    private var viewModel: CardSubscriptionViewModel?
    weak var delegate: DidTapInCardDetailViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel) {
        self.viewModel = viewModel
        handleCardImage(viewModel)
        cardStaticLabel.text = localized("m4m_label_card")
        cardAliasLabel.attributedText = viewModel.cardAlias
        cardNumberLabel.attributedText = viewModel.cardNumber
    }
}

private extension CardSubscriptionCardDetailView {
    func setupView() {
        backgroundColor = .clear
        setStaticLabel()
        setCardAlias()
        setCardNumber()
        addTapGesture()
        setAccessibilityIds()
    }
    
    func setStaticLabel() {
        cardStaticLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        cardStaticLabel.textColor = .lisboaGray
        cardStaticLabel.textAlignment = .left
    }
    
    func setCardAlias() {
        cardAliasLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        cardAliasLabel.textColor = .lisboaGray
        cardAliasLabel.textAlignment = .right
        cardAliasLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setCardNumber() {
        cardNumberLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        cardNumberLabel.textColor = .lisboaGray
        cardNumberLabel.textAlignment = .right
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailCardDetailBaseView
        cardStaticLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailCardDetailStaticLabel
        cardAliasLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailCardDetailAliasLabel
        cardNumberLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailCardDetailNumberLabel
        cardImageView.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailCardDetailImageView
    }
    
    func handleCardImage(_ viewModel: CardSubscriptionViewModel) {        
        if let imageUrl = viewModel.cardImageUrl {
            cardImageView.loadImage(urlString: imageUrl,
                                    placeholder: defaultImage,
                                    completion: nil)
        } else {
            cardImageView.image = defaultImage
        }
    }
    
    func addTapGesture() {
        if let gestureRecognizers = gestureRecognizers, !gestureRecognizers.isEmpty {
            self.gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInCardDetailView))
        addGestureRecognizer(tap)
    }
    
    @objc func didTapInCardDetailView() {
        delegate?.didTapInCardDetailView()
    }
}
