//
//  CardTransactionDetailLocationView.swift
//  Cards
//
//  Created by Iván Estévez on 14/05/2020.
//

import UI
import CoreFoundationLib

protocol CardTransactionDetailLocationViewDelegate: AnyObject {
    func mapButtonPressed()
}

final class OldCardTransactionDetailLocationView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var pinImageView: UIImageView!
    @IBOutlet private weak var mapButton: WhiteLisboaButton!
    
    weak var delegate: CardTransactionDetailLocationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setViewModel(_ viewModel: CardTransactionDetailLocationItem) {
        titleLabel.text = viewModel.title
        addressLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.decoratedAddress, styles: nil),
                                   andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14),
                                                                                        lineHeightMultiple: 0.85))
        categoryLabel.text = viewModel.category
        mapButton.isHidden = !viewModel.showMapButton
        mapButton.setTitle(viewModel.showMapButton ? localized("transaction_button_seeMap") : "", for: .normal)
    }
}

private extension OldCardTransactionDetailLocationView {
    func setupView() {
        topSeparatorView.backgroundColor = .mediumSkyGray
        bottomSeparatorView.backgroundColor = .mediumSkyGray
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .bold, size: 14)
        addressLabel.textColor = .lisboaGray
        categoryLabel.textColor = .santanderRed
        categoryLabel.font = .santander(family: .text, type: .regular, size: 14)
        mapImageView.image = Assets.image(named: "imgMapTransaction")
        pinImageView.image = Assets.image(named: "icnLocationPin")
        mapButton.titleLabel?.font = .santander(family: .text, type: .regular, size: 14)
        mapButton.addAction { [weak self] in
            self?.delegate?.mapButtonPressed()
        }
    }
}
