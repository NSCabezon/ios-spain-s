//
//  CardTransactionDetailWithoutLocationView.swift
//  Pods
//
//  Created by Hernán Villamil on 8/4/22.
//

import UI

final class CardTransactionDetailWithoutLocationView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var pinImageView: UIImageView!
    var title: String? {
        didSet { titleLabel.text = title }
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

private extension CardTransactionDetailWithoutLocationView {
    func commonInit() {
        topSeparatorView.backgroundColor = .mediumSkyGray
        bottomSeparatorView.backgroundColor = .mediumSkyGray
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        mapImageView.image = Assets.image(named: "imgMapTransaction")
        pinImageView.image = Assets.image(named: "icnLocationPin")
    }
}
