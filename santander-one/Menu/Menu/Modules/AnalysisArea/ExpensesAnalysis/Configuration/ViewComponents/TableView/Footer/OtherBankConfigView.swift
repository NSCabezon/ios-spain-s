//
//  OtherBankConfigView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 6/7/21.
//

import UI
import CoreFoundationLib

protocol OtherBankConfigViewDelegate: AnyObject {
    func didPressOtherBankConfig(_ viewModel: OtherBankConfigViewModel)
}

final class OtherBankConfigView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var bankImageView: UIImageView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var dottedLineView: DottedLineView!
    private var viewModel: OtherBankConfigViewModel?
    weak var delegate: OtherBankConfigViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBAction func didPressedOtherBankConfigView(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didPressOtherBankConfig(viewModel)
    }
    
    func setViewModel(_ viewModel: OtherBankConfigViewModel) {
        self.viewModel = viewModel
        self.setBankImage(viewModel)
        self.setLasCell(viewModel)
    }
}

private extension OtherBankConfigView {
    func setupView() {
        self.arrowImageView.image = Assets.image(named: "icnGoPG")
        self.setAccessibilityIdentifiers()
    }
    
    func setBankImage(_ viewModel: OtherBankConfigViewModel) {
        if let bankIconUrl = viewModel.bankIconUrl {
            self.bankImageView.loadImage(urlString: bankIconUrl)
        } else {
            self.bankImageView.image = nil
        }
    }
    
    func setLasCell(_ viewModel: OtherBankConfigViewModel) {
        guard viewModel.isLastCell else { return }
        self.containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 6)
        self.dottedLineView.isHidden = true
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.footerOtherBanksButton
    }
}
