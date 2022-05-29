//
//  CompressedFundsHomeHeaderView.swift
//  Funds
//
import UI
import Foundation
import CoreFoundationLib
import OpenCombine

final class CompressedFundsHomeHeaderView: XibView {
    @IBOutlet private weak var fundAliasLabel: UILabel!
    @IBOutlet private weak var fundAmountLabel: UILabel!
    private var fund: Fund?
    private var anySubscriptions = Set<AnyCancellable>()
    let selectFundSubject = PassthroughSubject<Fund, Never>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.bind()
    }
}

private extension CompressedFundsHomeHeaderView {
    func setupView() {
        self.setupGradientLayer()
        self.fundAliasLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.fundAliasLabel.textColor = .lisboaGray
        self.fundAmountLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.fundAmountLabel.textColor = .lisboaGray
        self.fundAliasLabel.accessibilityIdentifier = "fundProductLabelScrollTopAlias"
        self.fundAliasLabel.isAccessibilityElement = true
        self.fundAmountLabel.accessibilityIdentifier = "fundProductLabelScrollTopAmount"
        self.fundAmountLabel.isAccessibilityElement = true
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.skyGray.cgColor]
        gradientLayer.frame = self.view?.bounds ?? .zero
        self.view?.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func bind() {
        self.selectFundSubject
            .sink { [unowned self] fund in
                self.fund = fund
                self.fundAliasLabel.text = fund.alias
                let fundAlias = StringPlaceholder(.value, self.fund?.alias ?? "")
                self.fundAmountLabel.text = fund.amount
                self.setAccessibility {
                    self.fundAliasLabel.accessibilityLabel = localized("funds_label_fundNumber", [fundAlias]).text
                    self.fundAmountLabel.accessibilityLabel = "\(localized("funds_label_totalInvestment")) \(self.fund?.amount ?? "")"
                }
            }.store(in: &self.anySubscriptions)
    }
}

extension CompressedFundsHomeHeaderView: AccessibilityCapable {}
