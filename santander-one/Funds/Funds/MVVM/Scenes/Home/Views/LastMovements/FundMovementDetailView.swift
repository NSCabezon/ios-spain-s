//
//  FundMovementDetailView.swift
//  Funds
//

import UI
import CoreFoundationLib

final class FundMovementDetailView: XibView {
    @IBOutlet private weak var detailStackView: UIStackView!
    @IBOutlet weak var detailStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var shareContainerView: UIView!
    @IBOutlet private weak var shareView: UIView!
    @IBOutlet private weak var shareStackView: UIStackView!
    @IBOutlet private weak var shareImageView: UIImageView!
    @IBOutlet private weak var shareLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    var viewModel: FundMovementDetails?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func didSelectShare(_ sender: UIButton) {
        self.viewModel?.didSelectShare()
    }

    func setViewModel(_ viewModel: FundMovementDetails) {
        self.viewModel = viewModel
        setAccessibilityIdentifiers()
        self.setupView()
    }
}

private extension FundMovementDetailView {
    func setupView() {
        self.setupShareButtonView()
        self.detailStackView.removeAllArrangedSubviews()
        guard let detailsInfo = self.viewModel?.details, detailsInfo.isNotEmpty else {
            self.detailStackViewHeightConstraint.constant = 0
            return
        }
        detailsInfo.forEach({
            let fundMovementDetailInfoView = FundMovementDetailInfoView()
            fundMovementDetailInfoView.setupView(title: $0.title, value: $0.value, titleId: $0.titleIdentifier, valueId: $0.valueIdentifier)
            self.detailStackView.addArrangedSubview(fundMovementDetailInfoView)
        })
        let totalDetailInfoViewHeight = detailsInfo.count * 20
        let totalDetailInfoSpacing = (detailsInfo.count - 1) * 16
        self.detailStackViewHeightConstraint.constant = CGFloat(totalDetailInfoViewHeight + totalDetailInfoSpacing + 23 + 5)
    }

    func setAccessibilityIdentifiers() {
        shareImageView.accessibilityIdentifier = AccessibilityIdFundLastMovements.icnShare.rawValue
        shareLabel.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsButtonShare.rawValue
        shareButton.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsBgButton.rawValue
        setAccessibility { [weak self] in
            self?.shareButton.accessibilityLabel = localized("generic_button_share")
        }
    }

    func setupShareButtonView() {
        self.shareImageView.image = UIImage(named: "icnShare", in: .module, compatibleWith: nil)
        self.shareLabel.text = localized("funds_button_share")
        self.shareContainerView.applyGradientBackground(colors: [.skyGray, .oneSkyGray])
        self.shareView.layer.cornerRadius = 4
        self.shareView.layer.shadowColor = UIColor.oneLisboaGray.cgColor
        self.shareView.layer.shadowRadius = 7
        self.shareView.layer.shadowOpacity = 0.15
        self.shareView.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
}

extension FundMovementDetailView: AccessibilityCapable {}
