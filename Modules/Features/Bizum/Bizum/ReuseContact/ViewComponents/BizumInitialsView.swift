//
//  BizumInitialsView.swift
//  Bizum
//
//  Created by Margaret López Calderón on 13/11/2020.
//

import UI
import CoreFoundationLib

struct BizumInitialsViewModel {
    let colorModel: ColorsByNameViewModel
    let initials: String
}

protocol BizumInitialsViewProtocol {
    func configureView(with viewModel: BizumInitialsViewModel)
}

final class BizumInitialsView: XibView {
    @IBOutlet var initialsView: UIView!
    @IBOutlet var initialsLabel: UILabel! {
        didSet {
            self.initialsLabel.textColor = .white
            self.initialsLabel.font = .santander(family: .text, type: .bold, size: 15)
            self.initialsLabel.accessibilityIdentifier = AccessibilityBizumReuseContact.reuseContactLabelInitials
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = self.frame.height / 2
        layer.masksToBounds = true
    }

}

extension BizumInitialsView: BizumInitialsViewProtocol {
    func configureView(with viewModel: BizumInitialsViewModel) {
        self.initialsView.backgroundColor = viewModel.colorModel.color
        self.initialsLabel.text = viewModel.initials
    }
}
