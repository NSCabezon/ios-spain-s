//
//  EmptyChartCollectionViewCell.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 1/3/22.
//

import UIKit
import UI
import UIOneComponents
import OpenCombine
import CoreFoundationLib
import CoreDomain

final class EmptyChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var tooltipLabel: UILabel!
    private var subject = PassthroughSubject<ChartCollectionViewCellState, Never>()
    public var publisher: AnyPublisher<ChartCollectionViewCellState, Never> {
        return subject.eraseToAnyPublisher()
    }
    var isVisible: Bool = true {
        didSet {
            setAppearance()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
    }
    
    func setCellInto(_ labelKey: String, tooltipLabelKey: String, isVisible: Bool) {
        self.isVisible = isVisible
        [tooltipImageView, tooltipLabel].forEach { $0.isHidden = (tooltipLabelKey == "") }
        self.textLabel.text = localized(labelKey)
        tooltipLabel.text = localized(tooltipLabelKey)
        setAccessibility(setViewAccessibility: setAccessbilityInfo)
        layoutIfNeeded()
    }
}

private extension EmptyChartCollectionViewCell {
    func setAppearance() {
        containerView.backgroundColor = isVisible ? .oneWhite : .oneSkyGray
        textLabel.font = .typography(fontName: .oneB400Regular)
        textLabel.textColor = .oneLisboaGray
        tooltipImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTooltip)))
        tooltipImageView.isUserInteractionEnabled = true
        tooltipImageView.image = Assets.image(named: "oneIcnHelp")
        tooltipLabel.font = .typography(fontName: .oneB300Regular)
        tooltipLabel.numberOfLines = 2
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = isVisible ? UIColor.oneMediumSkyGray.cgColor : UIColor.oneBrownGray.cgColor
        containerView.clipsToBounds = true
        tooltipImageView.backgroundColor = .clear
        containerImageView.setLeavesLoader()
        containerImageView.contentMode = .scaleAspectFill
    }
    
    func setAccessbilityInfo() {
        tooltipLabel.accessibilityLabel = tooltipLabel.text
        tooltipLabel.accessibilityTraits = .button
        tooltipLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTooltip)))
        tooltipLabel.isUserInteractionEnabled = true
    }
    
    func setAccessibilityIdentifiers(categorization: AnalysisAreaCategorization) {
        tooltipImageView.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        tooltipLabel.accessibilityIdentifier = "\(categorization.prefixKey)\(AnalysisAreaAccessibility.chartTooltipLabel)"
        tooltipImageView.accessibilityIdentifier = "\(categorization.prefixKey)\(AnalysisAreaAccessibility.chartTooltipImage)"
        self.accessibilityIdentifier = "\(categorization.prefixKey)\(AnalysisAreaAccessibility.chartCollectionCell)"
    }
    
    @objc func didTapTooltip() {
        subject.send(.didTapToolTip)
    }
}

extension EmptyChartCollectionViewCell: AccessibilityCapable {}
