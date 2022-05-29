//
//  CardTransactionDetailLocationView.swift
//  Pods
//
//  Created by Hernán Villamil on 8/4/22.
//

import UI
import OpenCombine
import CoreFoundationLib

final class CardTransactionDetailLocationView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var pinImageView: UIImageView!
    @IBOutlet private weak var mapButton: WhiteLisboaButton!
    let didSelectMapSubject = PassthroughSubject<Void, Never>()
    var item: CardTransactionDetailLocationItem? {
        didSet { configureViewWithItem(item) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private extension CardTransactionDetailLocationView {
    func commonInit() {
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
        mapButton.addAction { [unowned self] in
            didSelectMapSubject.send()
        }
    }
    
    func configureViewWithItem(_ item: CardTransactionDetailLocationItem?) {
        guard let unwrappedItem = item else { return }
        titleLabel.text = unwrappedItem.title
        addressLabel.configureText(withLocalizedString: LocalizedStylableText(text: unwrappedItem.decoratedAddress, styles: nil),
                                   andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text,
                                                                                                         type: .regular, size: 14),
                                                                                        lineHeightMultiple: 0.85))
        categoryLabel.text = unwrappedItem.category
        mapButton.isHidden = !unwrappedItem.showMapButton
        mapButton.setTitle(unwrappedItem.showMapButton ? localized("transaction_button_seeMap") : "", for: .normal)
    }
}
