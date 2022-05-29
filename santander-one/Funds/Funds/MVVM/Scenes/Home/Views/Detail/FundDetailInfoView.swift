//
//  FundDetailInfoView.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 11/3/22.
//

import Foundation
import OpenCombine
import CoreFoundationLib
import UIOneComponents
import UI

protocol FundDetailInfoViewDelegate: AnyObject {
    func didTapOnShare(_ item: Shareable)
}

final class FundDetailInfoView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var shareImageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    
    weak var delegate: FundDetailInfoViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setViewModel(_ viewModel: FundDetailInfoModel) {
        self.setupInfo(with: viewModel)
    }

    @IBAction func shareTapped() {
        delegate?.didTapOnShare(self)
    }
}

private extension FundDetailInfoView {

    func setupView() {
        titleLabel.textColor = .oneBrownishGray
        titleLabel.font = .santander(family: .micro, type: .regular, size: 14)
        valueLabel.textColor = .oneLisboaGray
        valueLabel.font = .santander(family: .micro, type: .regular, size: 14)
        shareImageView.image = Assets.image(named: "icnShareAccount")
        shareButton.accessibilityIdentifier = "icnShareAccountBtn"
        shareImageView.isHidden = true
        shareButton.isHidden = true
    }

    func setupInfo(with model: FundDetailInfoModel) {
        titleLabel.text = model.title
        valueLabel.text = model.value
        titleLabel.accessibilityIdentifier = model.titleIdentifier
        valueLabel.accessibilityIdentifier = model.valueIdentifier
        shareImageView.isHidden = !model.shareable
        shareButton.isHidden = !model.shareable
        setAccessibility { [weak self] in
            self?.titleLabel.accessibilityLabel = localized(model.titleIdentifier ?? "") + " " + model.value
            self?.valueLabel.isAccessibilityElement = false
            self?.shareButton.accessibilityLabel = model.shareIdentifier
        }
    }
}

extension FundDetailInfoView: Shareable {
    func getShareableInfo() -> String { valueLabel.text ?? "" }
}

extension FundDetailInfoView: AccessibilityCapable {}
