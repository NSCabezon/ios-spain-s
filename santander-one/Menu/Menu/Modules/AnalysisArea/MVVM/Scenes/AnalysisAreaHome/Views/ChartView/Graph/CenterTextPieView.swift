//
//  CenterTextPieView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 18/2/22.
//

import Foundation
import UIKit
import UIOneComponents
import UI

protocol CentertextPieViewRepresentable: PieChartViewRepresentable {
    var centerIconKey: String { get }
    var centerTitleText: String { get }
    var centerSubtitleText: String { get }
    var archWidth: CGFloat { get }
    var amountBackgroundColor: UIColor { get }
    var graphIndentifierKey: String { get }
}

class CenterTextPieView: PieChartView {
    private var representable: CentertextPieViewRepresentable?
    private var centerIcon: UIImage?
    var arcWidth: CGFloat = 28.0
    private var centerView: UIView?
    private var graphIndentifierKey: String?
    var currentCenterTitleText: String?
    var currentSubTitleText: String?
    var amountBackgroundColor: UIColor?
    var centerTitleLabel: UILabel {
        let label = UILabel(frame: .zero)
        label.text = currentCenterTitleText ?? representable?.centerTitleText
        label.textColor = .oneLisboaGray
        label.backgroundColor = amountBackgroundColor
        label.textAlignment = .center
        label.font = .typography(fontName: .oneH300Bold)
        label.accessibilityIdentifier = "\(graphIndentifierKey ?? "")\(AnalysisAreaAccessibility.chartCenterLabel)"
        label.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        label.set(lineHeightMultiple: 0.8)
        return label
    }
    private var centerDescriptionLabel: UILabel {
        let bottomLabel = UILabel(frame: .zero)
        bottomLabel.text = currentSubTitleText ?? representable?.centerSubtitleText
        bottomLabel.textColor = .oneBrownishGray
        bottomLabel.layer.cornerRadius = 4
        bottomLabel.lineBreakMode = .byWordWrapping
        bottomLabel.textAlignment = .center
        bottomLabel.numberOfLines = 2
        bottomLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        bottomLabel.accessibilityIdentifier = "\(graphIndentifierKey ?? "")\(AnalysisAreaAccessibility.chartCenterLabelAmount)"
        let isLargeText = currentSubTitleText?.count ?? 0 > 10
        bottomLabel.font = .typography(fontName: .oneB300Regular)
        bottomLabel.sizeToFit()
        bottomLabel.clipsToBounds = true
        return bottomLabel
    }
    var totalImage: UIImageView {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        image.contentMode = .scaleAspectFit
        image.image = centerIcon
        image.accessibilityIdentifier = "\(graphIndentifierKey ?? "")\(AnalysisAreaAccessibility.chartCenterImage)"
        return image
    }
    
    var innerRect: CGRect {
        let side = ((innerCircleDiameter*innerCircleDiameter) / 2).squareRoot()
        return CGRect(x: viewCenter.x, y: viewCenter.y, width: side, height: side)
    }
    
    override func build() {
        super.build()
        drawSteps.append(drawCenterText)
        setNeedsDisplay()
    }
    
    func reset() {
        centerView?.removeFromSuperview()
    }
    
    func setChartInfo(_ representable: CentertextPieViewRepresentable) {
        super.setChartInfo(representable)
        self.representable = representable
        self.arcWidth = representable.archWidth
        self.centerIcon = Assets.image(named: representable.centerIconKey)
        self.amountBackgroundColor = representable.amountBackgroundColor
        self.graphIndentifierKey = representable.graphIndentifierKey
        setNeedsDisplay()
    }
    
    func getCenterStackView() -> UIStackView {
        let stackView = setStackView()
        let image = totalImage
        let titleLabel = centerTitleLabel
        let descriptionLabel = centerDescriptionLabel
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.baselineAdjustment = .alignCenters
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            descriptionLabel.widthAnchor.constraint(lessThanOrEqualToConstant: innerRect.width),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: stackView.bottomAnchor)
        ])
        descriptionLabel.sizeToFit()
        stackView.layoutIfNeeded()
        return stackView
    }
}

extension CenterTextPieView {
    
    func setStackView() -> UIStackView {
        let view = UIStackView(frame: CGRect(centeredOn: viewCenter, size: CGSize(width: innerCircleDiameter, height: innerRect.height)))
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.heightAnchor.constraint(lessThanOrEqualToConstant: innerRect.height).isActive = true
        view.spacing = 0
        view.alignment = .center
        view.axis = .vertical
        addSubview(view)
        view.center = viewCenter
        view.distribution = .fillProportionally
        return view
    }
}

private extension CenterTextPieView {
    
    func drawCenterText() {
        centerView?.removeFromSuperview()
        centerView = getCenterStackView()
    }
    
}
