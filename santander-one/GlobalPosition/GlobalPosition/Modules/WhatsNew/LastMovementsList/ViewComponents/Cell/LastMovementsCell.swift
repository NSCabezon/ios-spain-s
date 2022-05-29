//
//  LastMovementsCell.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 15/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol LastMovementsCellDelegate: AnyObject {
    func didTapCrossSelling(_ item: UnreadMovementItem)
}

public final class LastMovementsCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var shortContractLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var bankImage: UIImageView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var crossSellingButton: CrossSellingButton!
    @IBOutlet private weak var fractionateItemView: FractionableItemView!

    public static let identifier = "LastMovementsCell"
    weak var delegate: LastMovementsCellDelegate?
    var indexPath: IndexPath?
    private var viewModel: UnreadMovementItem?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setupView()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.separatorView.dotted(with: [1, 1, 1, 1], color: UIColor.mediumSkyGray.cgColor)
    }

    func configWithItem(_ viewModel: UnreadMovementItem, isLastItem: Bool, indexPath: IndexPath) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.concept?.camelCasedString
        self.accountLabel.text = viewModel.alias
        self.shortContractLabel.text = " | \(viewModel.shortContract)"
        self.amountLabel.attributedText = viewModel.amountAttributedString
        self.indexPath = indexPath
        switch viewModel.type {
        case .card:
            self.bankImage.loadImage(urlString: viewModel.imageUrl,
                                     placeholder: Assets.image(named: "defaultCard"))
        case .account:
            self.bankImage.image = Assets.image(named: viewModel.imageUrl)
        }
        self.configureFractionalTitle(viewModel)
        self.configureCrossSelling(viewModel.crossSelling)
        self.separatorView.isHidden = isLastItem
    }
}

private extension LastMovementsCell {
    func setupView() {
        self.setAppearance()
        self.setIdentifiers()
    }
    
    func resetCell() {
        self.titleLabel.text = nil
        self.amountLabel.text = nil
        self.crossSellingButton.clearTitle()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
        self.titleLabel.numberOfLines = 2
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.titleLabel.textColor = .lisboaGray
        self.accountLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        self.accountLabel.textColor = .grafite
        self.amountLabel.textColor = .lisboaGray
        self.shortContractLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        self.shortContractLabel.textColor = .grafite
    }
    
    func setIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityLastMovementsList.titleCell
        self.accountLabel.accessibilityIdentifier = AccesibilityLastMovementsList.accountCell
        self.shortContractLabel.accessibilityIdentifier = AccesibilityLastMovementsList.accountCell
        self.amountLabel.accessibilityIdentifier = AccesibilityLastMovementsList.amountCell
        self.bankImage.accessibilityIdentifier = AccesibilityLastMovementsList.bankImageCell
        self.separatorView.accessibilityIdentifier = AccesibilityLastMovementsList.separatorCell
        self.crossSellingButton.accessibilityIdentifier = AccesibilityLastMovementsList.crossSellingButton
        self.fractionateItemView.accessibilityIdentifier = AccesibilityLastMovementsList.fractionalView
    }
    
    func configureFractionalTitle(_ viewModel: UnreadMovementItem) {
        guard viewModel.isFractionable else {
            self.fractionateItemView.isHidden = true
            return
        }
        self.fractionateItemView.isHidden = false
        let title = viewModel.getFractionalTitle()
        let customViewModel = FractionableItemViewModel(styledTitle: localized(title))
        self.fractionateItemView.setViewModel(customViewModel)
    }
    
    func configureCrossSelling(_ crossSelling: UnreadCrossSellingViewProtocol?) {
        if let crossSelling = crossSelling,
           crossSelling.isCrossSellingEnabled,
           let crossSellingSelected = crossSelling.crossSellingSelected {
            self.crossSellingButton.isHidden = false
            self.crossSellingButton.configureView(CrossSellingButtonViewModel(title: crossSellingSelected.actionNameCrossSelling))
            self.crossSellingButton.delegate = self
        } else {
            self.crossSellingButton.isHidden = true
        }
    }
}

extension LastMovementsCell: CrossSellingPressableButtonDelegate {
    public func didTapCrossSellingButton() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapCrossSelling(viewModel)
    }
}
