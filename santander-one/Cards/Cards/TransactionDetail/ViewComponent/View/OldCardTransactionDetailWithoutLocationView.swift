//
//  CardTransactionDetailWithoutLocationView.swift
//  Cards
//
//  Created by Iván Estévez on 14/05/2020.
//

import UI

final class OldCardTransactionDetailWithoutLocationView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var pinImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

private extension OldCardTransactionDetailWithoutLocationView {
    func setupView() {
        topSeparatorView.backgroundColor = .mediumSkyGray
        bottomSeparatorView.backgroundColor = .mediumSkyGray
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        mapImageView.image = Assets.image(named: "imgMapTransaction")
        pinImageView.image = Assets.image(named: "icnLocationPin")
    }
}
