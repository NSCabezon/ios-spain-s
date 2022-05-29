//
//  InteractiveSectoredChartView.swift
//  UI
//
//  Created by Mario Rosales Maillo on 9/6/21.
//

import Foundation
import UIKit
import CoreFoundationLib

public protocol InteractiveSectoredChartViewDelegate: AnyObject {
    func didSelect(sector: ChartSectorData?)
}

@IBDesignable
public final class InteractiveSectoredChartView: SectoredChartView {
    
    public var centerAttributedTextBottom: NSAttributedString?
    
    private enum Config {
        // Height for each sector label
        static let labelHeight: CGFloat = 19
        // Size for each sector icon, width/height
        static let iconSize: CGFloat = 50
        // Space bewteen icon and label for each sector
        static let iconMargin: CGFloat = 5
        // Size for the big center icon, width/height
        static let centerIconSize: CGFloat = 34
        // Alpha when sectors are not selected
        static let unselectedAlpha: CGFloat = 0.3
        // Main chart size, max is 0.5
        static let graphScale: CGFloat = 0.30
        // Inner radius for the center white hole
        static let innerRadioDelta: Double = 1.38
        // Offset of each category icon from center
        static let iconPositionOffset: CGFloat = 1.35
        // Allow inner label to overflow the center hole, to use all the available space for text
        static let innerFrameOverflow: CGFloat = 10
        // Index when no sector is selected
        static let unsetIndex: Int = -1
    }
    
    override public var graphScale: CGFloat { Config.graphScale }

    private var sectorViews = [UIView]()
    private var centerView: UIView?
    private var selectedSector: (index: Int, status: SelectedChartSectorStatus) = (Config.unsetIndex, .notSet)
    
    public weak var delegate: InteractiveSectoredChartViewDelegate?
    
    /// The font to be used on the icon labels
    public var iconLabelFont: UIFont = .systemFont(ofSize: 11.0, weight: .heavy) {
        didSet {
            textAttributes[.font] = sectorLabelFont
            setNeedsDisplay()
        }
    }
    
    public var categoriesAttributtedTexts: [NSAttributedString] = [NSAttributedString]()
    
    /// variable for the icon that is drawn in the center of the pie-chart
    public var centerIcon: UIImage? {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        innerRadioDelta = Config.innerRadioDelta
        iconPositionOffset = Config.iconPositionOffset
        addGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        innerRadioDelta = Config.innerRadioDelta
        iconPositionOffset = Config.iconPositionOffset
        addGesture()
    }
    
    public func reset() {
        selectedSector = (Config.unsetIndex, .notSet)
        sectorViews.forEach { view in view.removeFromSuperview() }
        sectorViews.removeAll()
        centerView?.removeFromSuperview()
    }
    
    override func innerRect() -> CGRect {
        let side = ((innerRadius*innerRadius) / 2).squareRoot() * 2
        return CGRect(x: center.x, y: center.y, width: side + Config.innerFrameOverflow, height: side)
    }
    
    override func drawSectorLabels() {
        let center = bounds.center
        let radius = min(frame.width, frame.height) * graphScale
        
        sectorViews.forEach { view in view.removeFromSuperview() }
        sectorViews.removeAll()

        forEachSector { sector, startAngle, endAngle in
        
            // Get the angle midpoint.
            let halfAngle = startAngle + (endAngle - startAngle) * graphScale
                
            // Get the 'center' of the segment.
            var segmentCenter = center
            segmentCenter = segmentCenter.projected(by: radius * textPositionOffset.toCGFloat, angle: halfAngle)
                
            // Draw icons
            if let iconImage = sector.icon {
                let iconCenter = center.projected(by: radius * iconPositionOffset, angle: halfAngle)
                
                let view = UIView(frame: CGRect(centeredOn: iconCenter,
                                                size: CGSize(width: Config.iconSize, height: Config.iconSize)))
                view.tag = getIndexFor(sector: sector)
                view.isUserInteractionEnabled = true
                view.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelectSector(_:)))]
                self.addSubview(view)
                self.sectorViews.append(view)
                let imgHeight = view.frame.height - (Config.labelHeight + Config.iconMargin)
                let imgView = UIImageView(frame: CGRect(centeredOn: CGPoint(x: view.bounds.center.x, y: imgHeight/2),
                                                        size: CGSize(width: imgHeight, height: imgHeight)))
                imgView.contentMode = .scaleAspectFit
                imgView.image = iconImage
                view.addSubview(imgView)
                
                let iconLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height-Config.labelHeight,
                                                          width: view.frame.width, height: Config.labelHeight))
                iconLabel.text = "    \(sector.value.asFinancialAgregatorPercentText())"
                iconLabel.textColor = sector.colors.textColor
                iconLabel.textAlignment = .center
                iconLabel.textFont = iconLabelFont
                iconLabel.backgroundColor = .clear
                iconLabel.layer.cornerRadius = iconLabel.frame.size.height/2
                iconLabel.layer.borderWidth = 1
                iconLabel.layer.borderColor = sector.colors.sector.withAlphaComponent(0.3).cgColor
                iconLabel.clipsToBounds = true
                
                let dot = UIView(frame: CGRect(x: 7, y: (iconLabel.frame.height/2)-3, width: 6, height: 6))
                dot.backgroundColor = sector.colors.textColor
                dot.layer.cornerRadius = 3
                dot.clipsToBounds = true
                iconLabel.addSubview(dot)
                
                view.addSubview(iconLabel)
            }
        }
    }
    
    override func drawCenterText(context: CGContext) {
        guard let centerAttributedText = self.centerAttributedTextTop,
              let centerAttributedTextBottom = self.centerAttributedTextBottom,
              drawCenterTextEnabled && centerAttributedText.length > 0 else { return }
        centerView?.removeFromSuperview()
        
        let view = UIStackView(frame: innerRect())
        view.spacing = -4
        view.axis = .vertical
        view.center = bounds.center
        addSubview(view)
        let label = getLabel()
        
        if selectedSector.status == .selected {
            view.addArrangedSubview(label)
            label.attributedText = sectors[selectedSector.index].categoryAtttributtedText
        } else {
            let image = UIImageView(frame: CGRect(x: 0, y: 0, width: Config.centerIconSize, height: Config.centerIconSize))
            image.contentMode = .scaleAspectFit
            image.image = selectedSector.status == .selected ? nil : centerIcon
            view.addArrangedSubview(image)
            view.addArrangedSubview(label)
            label.attributedText = centerAttributedText
            image.image = centerIcon
            let bottomLabel = getLabel()
            bottomLabel.attributedText = centerAttributedTextBottom
            view.addArrangedSubview(bottomLabel)
        }
        centerView = view
    }
    
    public override func draw(_ rect: CGRect) {
        // Get current context.
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        // Radius is the half the frame's width or height (whichever is smallest).
        // to keep proportional image
        let radius = min(frame.width, frame.height) * graphScale
        self.graphRadius = radius
        // Center of the view.
        let viewCenter = bounds.center
        // Empty paths
        paths.removeAll()
        // Loop through the values array.
        forEachSector { sector, startAngle, endAngle in
            let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
            let arcPath = UIBezierPath(arcCenter: viewCenter,
                                       radius: radius,
                                       startAngle: startAngle,
                                       endAngle: endAngle,
                                       clockwise: true)
            resolveColorFor(sectorData: sector).setFill()
            arcPath.addLine(to: center)
            arcPath.fill()
            paths.append((sector, arcPath))
        }
        // semitransparent circle
        let outerCircle = UIBezierPath(arcCenter: viewCenter,
                                       radius: outerRadius,
                                       startAngle: -.pi * graphScale,
                                       endAngle: 2 * .pi, clockwise: true)
        innerCircleColor.setFill()
        outerCircle.fill()
        // center circle white must be same as background to simulate hole
        let innerCircle = UIBezierPath(arcCenter: viewCenter,
                                       radius: innerRadius,
                                       startAngle: -.pi * graphScale,
                                       endAngle: 2 * .pi, clockwise: true)
        UIColor.white.setFill()
        innerCircle.fill()
        drawCenterText(context: ctx)
        guard selectedSector.status == .notSet else { return }
        drawSectorLabels()
    }
    
    override func forEachSector(_ body: (ChartSectorData, _ startAngle: CGFloat, _ endAngle: CGFloat) -> Void) {
        let valueCount = sectors.lazy.map { $0.value }.reduce(0, +)
        var startAngle: CGFloat = -.pi / 2
        // Loop through the values array.
        for sector in sectors {
            // Get the end angle of this segment.
            let endAngle = startAngle + .pi * 2 * (CGFloat(sector.value) / CGFloat(valueCount))
            defer { startAngle = endAngle }
            body(sector, startAngle, endAngle)
        }
    }
}

private extension InteractiveSectoredChartView {
    
    func addGesture() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapView(_ gesture: UITapGestureRecognizer) {
        let point: CGPoint = gesture.location(in: self)
        
        for sectorPath in paths where sectorPath.path.contains(point) {
            selectSectorFor(index: getIndexFor(sector: sectorPath.sector))
            return
        }
        selectSectorFor(index: selectedSector.index)
    }
    
    @objc func didSelectSector(_ gesture: UITapGestureRecognizer) {
        guard let index = (gesture.view)?.tag else { return }
        selectSectorFor(index: index)
    }
    
    func selectSectorFor(index: Int) {
        guard selectedSector.status == .none || selectedSector.status == .notSet else {
            selectedSector = (Config.unsetIndex, .none)
            sectorViews.forEach { view in view.alpha = 1.0 }
            setNeedsDisplay()
            return
        }
        selectedSector = (index, index != Config.unsetIndex ? .selected : .none)
        guard selectedSector.status == .selected else { return }
        delegate?.didSelect(sector: sectors[safe: index])
        
        for (index, view) in sectorViews.enumerated() {
            view.alpha = selectedSector.index != index ? Config.unselectedAlpha : 1.0

        }
        setNeedsDisplay()
    }
    
    func resolveColorFor(sectorData: ChartSectorData) -> UIColor {
        let index = getIndexFor(sector: sectorData)
        switch selectedSector.status {
        case .notSet, .none:
            return sectorData.colors.sector
        case .selected:
            return sectorData.colors.sector.withAlphaComponent(selectedSector.index == index ? 1 : 0.2)
        }
    }
    
    func getLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.center = center
        label.accessibilityIdentifier = accessibilityIdentifierString
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }
}
