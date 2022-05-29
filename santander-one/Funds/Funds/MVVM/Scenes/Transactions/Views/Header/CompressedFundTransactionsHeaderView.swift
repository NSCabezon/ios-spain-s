//
//  CompressedFundTransactionsHeaderView.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 20/4/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine

final class CompressedFundTransactionsHeaderView: XibView {
    @IBOutlet private weak var fundAliasLabel: UILabel!
    @IBOutlet private weak var filterImageView: UIImageView!
    @IBOutlet private weak var filterLabel: UILabel!
    @IBOutlet private weak var filterButton: UIButton!
    private var anySubscriptions = Set<AnyCancellable>()
    let selectFundSubject = PassthroughSubject<FundMovements, Never>()
    var didSelectFilterButton: (() -> Void)?

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

    @IBAction func filterButtonDidPressed(_ sender: Any) {
        self.didSelectFilterButton?()
    }
}

private extension CompressedFundTransactionsHeaderView {
    func setupView() {
        setupGradientLayer()
        fundAliasLabel.font = .santander(family: .text, type: .bold, size: 18)
        fundAliasLabel.textColor = .lisboaGray
        filterImageView.image = Assets.image(named: "icnFilter")?.withRenderingMode(.alwaysTemplate)
        filterImageView.tintColor = .darkTorquoise
        filterLabel.textColor = .darkTorquoise
        filterLabel.font = .santander(family: .text, type: .regular, size: 12)
        filterLabel.text = localized("generic_button_filters")
        fundAliasLabel.accessibilityIdentifier = AccessibilityIdFundsTransactions.fundsLabelCarrouselAliasBar.rawValue
        filterLabel.accessibilityIdentifier = AccessibilityIdFundsTransactions.genericButtonFiltersBar.rawValue
        filterButton.accessibilityIdentifier = AccessibilityIdFundsTransactions.btnFiltersBar.rawValue
        setAccessibility { [weak self] in
            self?.filterButton.accessibilityLabel = localized("generic_button_filters")
        }
    }

    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.skyGray.cgColor]
        gradientLayer.frame = self.view?.bounds ?? .zero
        self.view?.layer.insertSublayer(gradientLayer, at: 0)
    }

    func bind() {
        self.selectFundSubject
            .sink { [unowned self] fundMovements in
                self.fundAliasLabel.text = fundMovements.fund.alias
                self.setAccessibility {
                    self.fundAliasLabel.accessibilityLabel = localized("voiceover_fundName", [StringPlaceholder(.value, fundMovements.fund.alias ?? "")]).text
                }
            }.store(in: &self.anySubscriptions)
    }
}

extension CompressedFundTransactionsHeaderView: AccessibilityCapable {}
