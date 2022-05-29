//
//  SectoredChartView.swift
//
//  Created by Boris Chirino Fernandez on 26/08/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//
import UIKit
import CoreFoundationLib
import Foundation

public enum SelectedChartSectorStatus: Comparable {
    case notSet
    case none
    case selected
}

@IBDesignable
public class SectoredChartView: UIView {
    
    public var graphScale: CGFloat { 0.5 }
    var paths = [(sector:ChartSectorData, path: UIBezierPath)]()
    
    /// An array of structs representing the segments of the pie chart.
    public var sectors = [ChartSectorData]() {
        didSet { setNeedsDisplay() }
    }
    
    /// An array for the accessibility Identifier
    public var accessibilityIdentifierString: String = "financing_label_totalDebt"
    
    /// Defines whether the segment labels should be shown when drawing the pie
    /// chart.
    @IBInspectable
    public var showSectorLabels: Bool = true {
        didSet { setNeedsDisplay() }
    }
        
    // The ratio of how far away from the center of the pie chart the text
    // will appear.
    @IBInspectable
    public var textPositionOffset: Double = 0.67 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable
    public var iconPositionOffset: CGFloat = 0.30 {
        didSet { setNeedsDisplay() }
    }
    
    /// The font to be used on the segment labels
    public var sectorLabelFont: UIFont = .systemFont(ofSize: 14.0, weight: .light) {
        didSet {
            textAttributes[.font] = sectorLabelFont
            setNeedsDisplay()
        }
    }
    
    /// variable for the text that is drawn in the center of the pie-chart
    public var centerAttributedTextTop: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    
    /// decreasing this value make the inner circle bigger ( may overlap the outer ring)
    @IBInspectable
    public var innerRadioDelta: Double = 1.5 {
        didSet { setNeedsDisplay() }
    }
    
    /// decreasing this value make the outer ring bigger toward the edges of the graphic
    @IBInspectable
    public var outerRadioDelta: Double = 1.2 {
        didSet { setNeedsDisplay() }
    }
    
    var innerRadius: CGFloat {
        graphRadius / innerRadioDelta.toCGFloat
    }
    
    var outerRadius: CGFloat {
        graphRadius / outerRadioDelta.toCGFloat
    }
    
    var graphRadius: CGFloat = 0.0
    
    /// if enabled, centertext is drawn
    var drawCenterTextEnabled = true
    
    /// style for sectors labels
    private let paragraphStyle: NSParagraphStyle = {
        var paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return paragraph
    }()
    
    lazy var textAttributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: self.paragraphStyle, .font: self.sectorLabelFont
    ]
    
    lazy var innerCircleColor: UIColor = {
        return UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.2)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        // When overriding drawRect, you must specify this to maintain transparency.
        isOpaque = false
    }

    public override func prepareForInterfaceBuilder() {
        // Sample data for ib
        sectors = [
            ChartSectorData( value: 57.56, iconName: "icnMortageCat",
            colors: ChartSectorData.Colors(sector: #colorLiteral(red: 1.0, green: 0.121568627, blue: 0.28627451, alpha: 1.0), textColor: .black)),
            ChartSectorData( value: 30, iconName: "icnCardCat",
            colors: ChartSectorData.Colors(sector: #colorLiteral(red: 0.478431373, green: 0.423529412, blue: 1.0, alpha: 1.0), textColor: .black)),
            ChartSectorData( value: 13.0, iconName: "icnHomeCat",
            colors: ChartSectorData.Colors(sector: #colorLiteral(red: 0.392156863, green: 0.945098039, blue: 0.717647059, alpha: 1.0), textColor: .black))
        ]
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
            
            sector.colors.sector.setFill()
            
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
        drawSectorLabels()
    }
    
    func drawSectorLabels() {
        
        guard showSectorLabels else { return }
        
        let center = bounds.center
        let radius = min(frame.width, frame.height) * graphScale
            
        forEachSector { sector, startAngle, endAngle in
            // Get the angle midpoint.
            let halfAngle = startAngle + (endAngle - startAngle) * graphScale
                
            // Get the 'center' of the segment.
            var segmentCenter = center
            segmentCenter = segmentCenter.projected(by: radius * textPositionOffset.toCGFloat, angle: halfAngle)
                
            let textToRender = sector.value.asFinancialAgregatorPercentText()
                
            textAttributes[.foregroundColor] = sector.colors.textColor
                
            let textRenderSize = textToRender.size(withAttributes: textAttributes)
                
            // Text bound.
            let renderRect = CGRect(
                centeredOn: segmentCenter, size: textRenderSize
            )
                
            textToRender.draw(in: renderRect, withAttributes: textAttributes)
                
            // Draw icons
            if let iconImage = sector.icon {
                let iconCenter = center.projected(by: radius * (textPositionOffset.toCGFloat + iconPositionOffset), angle: halfAngle)
                let imgView = UIImageView(frame: CGRect(centeredOn: iconCenter, size: iconImage.size))
                imgView.contentMode = .scaleAspectFill
                imgView.image = iconImage
                self.addSubview(imgView)
            }
        }
    }
    
    /// draws the description text in the center of the pie chart makes most sense when center-hole is enabled
    func drawCenterText(context: CGContext) {
        
        guard let centerAttributedText = self.centerAttributedTextTop else { return }

        if drawCenterTextEnabled && centerAttributedText.length > 0 {
            
            let center = bounds.center
            let textBounds = centerAttributedText.boundingRect(with: innerRect().size,
                                                               options: [.usesLineFragmentOrigin,
                                                                         .usesFontLeading,
                                                                         .truncatesLastVisibleLine],
                                                               context: nil)
            let label = UILabel(frame: textBounds)
            label.numberOfLines = 2
            label.textAlignment = .center
            label.center = center
            label.attributedText = centerAttributedText
            label.accessibilityIdentifier = accessibilityIdentifierString
            addSubview(label)
        }
    }
    
    func innerRect() -> CGRect {
        let side = ((innerRadius*innerRadius)/2).squareRoot()*2
        return CGRect(x: center.x, y: center.y, width: side, height: side)
    }
    
    func getIndexFor(sector: ChartSectorData) -> Int {
        let index = sectors.firstIndex { sectorData in
            sector.iconName == sectorData.iconName
        }
        return index ?? -1
    }
    
    func forEachSector(_ body: (ChartSectorData, _ startAngle: CGFloat, _ endAngle: CGFloat) -> Void) {
        let valueCount = sectors.lazy.map { $0.value }.reduce(0, +)
        
        // Starting angle is -90 degrees (top of the circle, as the context is
        // flipped).
        //https://koenig-media.raywenderlich.com/uploads/2014/12/1-FloUnitCircle.png
        var startAngle: CGFloat = -.pi * graphScale
        
        // Loop through the values array.
        for sector in sectors {
            
            // Get the end angle of this segment.
            let endAngle = startAngle + .pi * 2 * (CGFloat(sector.value) / CGFloat(valueCount))
            defer {
                // starting angle = ending angle of this sector.
                startAngle = endAngle
            }
            
            body(sector, startAngle, endAngle)
        }
    }
}
