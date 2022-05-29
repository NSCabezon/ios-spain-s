//
//  QuickBalanceMovementView.swift
//  Login
//
//  Created by Iván Estévez on 03/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class QuickBalanceMovementView: XibView {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var movementLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var sanImageView: UIImageView!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var separatorView: DottedLineView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setViewModel(_ viewModel: QuickBalanceMovementViewModel) {
        dateLabel.text = viewModel.date
        movementLabel.text = viewModel.movement
        amountLabel.attributedText = viewModel.amountAttributedString
        accountLabel.text = viewModel.account
    }
}

private extension QuickBalanceMovementView {
    func setupView() {
        dateLabel.font = .santander(family: .text, type: .regular, size: 13)
        dateLabel.textColor = .black
        movementLabel.font = .santander(family: .text, type: .regular, size: 13)
        movementLabel.textColor = .black
        amountLabel.font = .santander(family: .text, type: .bold, size: 13)
        amountLabel.textColor = .black
        sanImageView.image = Assets.image(named: "icnLogoSanSmall")
        accountLabel.font = .santander(family: .text, type: .regular, size: 12)
        accountLabel.textColor = .lisboaGray
        separatorView.backgroundColor = .clear
        separatorView.strokeColor = .lightSanGray
    }
}
