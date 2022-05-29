//
//  BankProductsFooterView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 6/7/21.
//

import UI
import CoreFoundationLib

protocol BankProductsFooterViewDelegate: AnyObject {
    func didSelectAddOtherBanks()
    func didSelectOtherBankConfig(_ viewModel: OtherBankConfigViewModel)
}

final class BankProductsFooterView: XibView {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var stackRoundedView: UIView!
    @IBOutlet private weak var banksStackView: UIStackView!
    @IBOutlet private weak var addBanksImageView: UIImageView!
    @IBOutlet private weak var addBanksLabel: UILabel!
    @IBOutlet private weak var addBanksButton: UIButton!
    weak var delegate: BankProductsFooterViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBAction func didPressedAddBanksButton(_ sender: Any) {
        self.delegate?.didSelectAddOtherBanks()
    }
    
    func setViewModels(_ viewModels: [OtherBankConfigViewModel]) {
        guard !viewModels.isEmpty else { return }
        self.setBanksStackView(viewModels)
    }
}

private extension BankProductsFooterView {
    func setupBorders() {
        self.stackRoundedView.layer.cornerRadius = 6
        self.stackRoundedView.layer.borderColor = UIColor.lightSkyBlue.cgColor
        self.stackRoundedView.layer.borderWidth = 1
        self.stackRoundedView.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            self.stackRoundedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            self.banksStackView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        }
    }
    
    func setupView() {
        self.separatorView.backgroundColor = .mediumSkyGray
        self.containerView.backgroundColor = .skyGray
        self.banksStackView.isHidden = true
        self.setAddBanksButton()
        self.setAccessibilityIdentifiers()
    }
    
    func setAddBanksButton() {
        self.addBanksImageView.image = Assets.image(named: "icnHigherAmount")
        self.addBanksLabel.setSantanderTextFont(type: .regular, size: 16, color: .darkTorquoise)
        self.addBanksLabel.text = localized("analysis_button_addOtherBanks")
    }
    
    func setAccessibilityIdentifiers() {
        self.banksStackView.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.footerOtherBanksStackView
        self.addBanksButton.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.footerOtherBanksButton
    }
    
    func setBanksStackView(_ viewModels: [OtherBankConfigViewModel]) {
        self.addHeaderToBanksStackView()
        self.addOtherBanksViewsToStackView(with: viewModels)
        self.banksStackView.isHidden = false
        self.setupBorders()
    }
    
    func addHeaderToBanksStackView() {
        let headerView = OtherBanksConfigHeaderView()
        self.banksStackView.addArrangedSubview(headerView)
    }
    
    func addOtherBanksViewsToStackView(with viewModels: [OtherBankConfigViewModel]) {
        viewModels.forEach {
            let otherBankView = OtherBankConfigView()
            otherBankView.setViewModel($0)
            otherBankView.delegate = self
            self.banksStackView.addArrangedSubview(otherBankView)
        }
    }
}

extension BankProductsFooterView: OtherBankConfigViewDelegate {
    func didPressOtherBankConfig(_ viewModel: OtherBankConfigViewModel) {
        self.delegate?.didSelectOtherBankConfig(viewModel)
    }
}
