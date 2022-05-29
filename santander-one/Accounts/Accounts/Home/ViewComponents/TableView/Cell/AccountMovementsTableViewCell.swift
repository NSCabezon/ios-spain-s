//
//  MovementsTableViewCell.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import UIOneComponents
import UI
import CoreFoundationLib

protocol AccountMovementsTableViewCellDelegate: AnyObject {
    func didTapLoadOfferOnCell(_ viewModel: CrossSellingViewModel, indexPath: IndexPath)
    func gotoTransactionForViewModel(_ viewModel: CrossSellingViewModel)
    func didUpdateCrossSellingOfferImageWithHeight(_ height: CGFloat, atCell cell: AccountMovementsTableViewCell)
}

final class AccountMovementsTableViewCell: UITableViewCell {
    @IBOutlet private weak var discontinueLineView: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var highlightView: UIView!
    @IBOutlet private weak var stackBottomTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomStackView: UIStackView!
    private var crossellingViewModel: CrossSellingViewModel?
    @IBOutlet weak var amountLabelView: OneLabelHighlightedView!
    
    private var indexPath: IndexPath?
    weak var delegate: AccountMovementsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.highlightView.backgroundColor = .white
        self.crossellingViewModel = nil
        let subViews = bottomStackView.arrangedSubviews
        for subview in subViews {
            bottomStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        self.balanceLabel.isHidden = false
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        discontinueLineView.dotted(with: [1, 1, 1, 1], color: UIColor.mediumSkyGray.cgColor)
    }
    
    private func setupViews() {
        balanceLabel.textColor = .lisboaGray
        balanceLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        setAccessibilityIdentifiers()
    }
    
    func setupHighlightBackgroundColor(_ color: UIColor) {
        highlightView.backgroundColor = color
    }
}

extension AccountMovementsTableViewCell: AccountTransactionTableViewCell {
    func mustHideDiscontinueLine(_ isHidden: Bool) {
        self.discontinueLineView.isHidden = isHidden
    }
    
    func configure(withViewModel viewModel: TransactionViewModel) {
        descriptionLabel.text = viewModel.title
        amountLabelView.attributedText = viewModel.amountAttributeString
        
        if let value = viewModel.amountValue, value > 0 {
            amountLabelView.style = .lightGreen
        } else {
            amountLabelView.style = .clear
        }
        
        guard let balance = viewModel.balanceString else {
            self.balanceLabel.isHidden = true
            return
        }
        self.balanceLabel.text = balance
        if viewModel.isEasyPayEnabled {
            self.addFractionateView()
            stackBottomTopConstraint.constant = 10
        }
    }
}

extension AccountMovementsTableViewCell: CrossSellingTransactionTableViewCell {
    func configure(viewModel: CrossSellingViewModel, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.crossellingViewModel = viewModel
        guard viewModel.isCrossSellingEnabled else { return }
        self.addCrossSellingView(viewModel: viewModel)
        stackBottomTopConstraint.constant = 10
    }
}

private extension AccountMovementsTableViewCell {
    func addFractionateView() {
        let customFractionateView = FractionableItemView(frame: .zero)
        customFractionateView.translatesAutoresizingMaskIntoConstraints = false
        customFractionateView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let customViewModel = FractionableItemViewModel(styledTitle: localized("accounts_tag_optionsPostponePay"))
        customFractionateView.setViewModel(customViewModel)
        bottomStackView.addArrangedSubview(customFractionateView)
    }

    func addCrossSellingView(viewModel: CrossSellingViewModel) {
        let customCrossSellingView = CrossSellingButton()
        customCrossSellingView.translatesAutoresizingMaskIntoConstraints = false
        customCrossSellingView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let buttonViewModel = CrossSellingButtonViewModel(title: viewModel.actionNameCrossSelling)
        customCrossSellingView.configureView(buttonViewModel)
        bottomStackView.addArrangedSubview(customCrossSellingView)
        customCrossSellingView.delegate = self
    }

    func didTapLoadOffers() {
        guard let viewModel =  self.crossellingViewModel,
              let indexPath = self.indexPath else { return }
        self.delegate?.didTapLoadOfferOnCell(viewModel, indexPath: indexPath)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "accountHome_movement_view"
        self.descriptionLabel.accessibilityIdentifier = "accountHome_movement_descriptionLabel"
        self.amountLabelView.accessibilityIdentifier = "accountHome_movement_amountLabel"
        self.balanceLabel.accessibilityIdentifier = "accountHome_movement_balanceLabel"
        descriptionLabel.isAccessibilityElement = true
        amountLabelView.isAccessibilityElement = true
        balanceLabel.isAccessibilityElement = true
    }
}

extension AccountMovementsTableViewCell: CrossSellingPressableButtonDelegate {
    func didTapCrossSellingButton() {
        didTapLoadOffers()
    }
}
