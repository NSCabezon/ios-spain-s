//
//  InteractiveSectoredGraphView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 27/1/22.
//

import Foundation
import UIKit
import UI
import UIOneComponents
import CoreMIDI
import OpenCombine
import CoreFoundationLib

public protocol InteractiveSectoredGraphViewDelegate: AnyObject {
    func didSelect(sector: ChartSectorData?)
}

public enum SelectedChartSectorStatus: Comparable {
    case notSet
    case none
    case selected
}

typealias SectoredGraphSectorAngles = (sector: ChartSectorData, startAngle: CGFloat, endAngle: CGFloat)
typealias SectoredGraphSectorPaths = (sector: ChartSectorData, path: UIBezierPath)

enum InteractiveSectoredGraphViewState: State {
    case sectorSelected(sector: ChartSectorData?)
    case tooltipTapped
}

class InteractiveSectoredGraphView: UIView {
    public var centerAttributedTextBottom: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    public var centerAttributedTextTop: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    
    var graphRadius: CGFloat = 0.0
    var arcWidth: CGFloat = 24.0
    var paths = [SectoredGraphSectorPaths]()
    var viewCenter: CGPoint = .zero
    
    
    lazy var textAttributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: self.paragraphStyle, .font: self.sectorLabelFont
    ]
    public var sectorLabelFont: UIFont = .systemFont(ofSize: 14.0, weight: .light) {
        didSet {
            textAttributes[.font] = sectorLabelFont
            setNeedsDisplay()
        }
    }
    private var paragraphStyle: NSParagraphStyle {
        var paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return paragraph
    }
    
    public var sectors = [ChartSectorData]() {
        didSet {
            getAnglesInfo(for: sectors)
            setNeedsDisplay() }
    }
    lazy var sectorsAnglesInfo: [SectoredGraphSectorAngles] = {
        return self.getAnglesInfo(for: sectors)
    }()
    
    private var subject = PassthroughSubject<InteractiveSectoredGraphViewState, Never>()
    public var publisher: AnyPublisher<InteractiveSectoredGraphViewState, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    var topMargin: CGFloat {
        return (Config.iconSize)+(Config.archWith/2)+graphRadius
    }
    var bottomMargin: CGFloat {
        return Config.iconSize+(Config.archWith/2)+graphRadius
    }
    var tooltipAndLabel: (UIImageView, UILabel)?
    override var backgroundColor: UIColor? {
        willSet {
            super.backgroundColor = newValue
        }
    }
    var graphScale: CGFloat { Config.graphScale }
    private var sectorViews = [UIView]()
    private var centerView: UIView?
    private var selectedSector: (index: Int, status: SelectedChartSectorStatus) = (Config.unsetIndex, .notSet)
    public weak var delegate: InteractiveSectoredChartViewDelegate?
    public var categoriesAttributtedTexts: [NSAttributedString] = [NSAttributedString]()
    public var chartType: ExpensesIncomeCategoriesChartType = .expenses {
        didSet { setNeedsDisplay() }
    }
    /// The font to be used on the icon labels
    public var iconLabelFont: UIFont = .systemFont(ofSize: 11.0, weight: .heavy) {
        didSet {
            textAttributes[.font] = UIFont.typography(fontName: .oneB100Bold)
            setNeedsDisplay()
        }
    }
    public var centerIcon: UIImage? {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGesture()
    }
    
    public func reset() {
        selectedSector = (Config.unsetIndex, .notSet)
        sectorViews.forEach { view in view.removeFromSuperview() }
        sectorViews.removeAll()
        tooltipAndLabel?.0.removeFromSuperview()
        tooltipAndLabel?.1.removeFromSuperview()
        tooltipAndLabel = nil
        centerView?.removeFromSuperview()
    }
    
    override func draw(_ rect: CGRect) {
        let radius = Config.graphDiameter / 2
        graphRadius = radius
        arcWidth = Config.archWith
        var calculatedY = topMargin
        viewCenter = CGPoint(x: bounds.midX,
                             y: calculatedY)
        paths.removeAll()
        storePaths(for: sectorsAnglesInfo)
        drawPaths()
        drawInnerCircle()
        drawCenterText()
        guard selectedSector.status == .notSet else { return }
        drawSectorLabels()
        drawSectorIcons()
        setLabelWithTooltip()
      //  setAccessibilityIdentifiers()
    }
}

//MARK: - Draw Arc {
extension InteractiveSectoredGraphView {
    
    func drawPaths() {
        paths.forEach { sector, path in
            resolveColorFor(sectorData: sector).setFill()
            path.addLine(to: viewCenter)
            path.fill()
        }
    }
    
    func getMidAngle(between startAngle: CGFloat, and endAngle: CGFloat) -> CGFloat {
        return (startAngle + endAngle) / 2
    }
    
    func storePaths(for sectors: [SectoredGraphSectorAngles]) {
        var calculatedPaths = [SectoredGraphSectorPaths]()
        sectors.forEach {
            // let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
            let arcPath = UIBezierPath(arcCenter: viewCenter,
                                       radius: graphRadius,
                                       startAngle: $0.startAngle,
                                       endAngle: $0.endAngle,
                                       clockwise: true)
            calculatedPaths.append((sector: $0.sector, path: arcPath))
        }
        self.paths = calculatedPaths
    }
    
    func getAnglesInfo(for sectors: [ChartSectorData]) -> [SectoredGraphSectorAngles] {
        var anglesInfo: [SectoredGraphSectorAngles] = []
        let valueCount = sectors.lazy.map { $0.value }.reduce(0, +)
        var startAngle: CGFloat = (.pi * 3) / 2
        for sector in sectors {
            let endAngle = startAngle + getRepresentedPercentageInCircle(of: sector.value, in: valueCount)
            defer {
                startAngle = endAngle
            }
            anglesInfo.append((sector: sector, startAngle: startAngle, endAngle: endAngle))
        }
        sectorsAnglesInfo = anglesInfo
        return anglesInfo
    }
}

// MARK: - External appearance
extension InteractiveSectoredGraphView {
    func drawSectorLabels() {
        sectorViews.forEach { $0.removeFromSuperview() }
        sectorViews.removeAll()
        sectorsAnglesInfo.forEach { _, startAngle, endAngle in
            let midAngle = getMidAngle(between: startAngle, and: endAngle)
            var segmentCenter = viewCenter
            segmentCenter = segmentCenter.projected(by: getDistanceFromCenter(for: midAngle), angle: midAngle)
        }
    }
    
    func drawSectorIcons() {
        self.sectorsAnglesInfo.forEach { sector, startAngle, endAngle in
            let midAngle = getMidAngle(between: startAngle, and: endAngle)
            setIcon(in: sector, angle: midAngle)
        }
    }
    
    func setIcon(in sector: ChartSectorData, angle: CGFloat) {
        guard let sectorIconImage = sector.icon else { return }
        let iconCenter = viewCenter.projected(by: getDistanceFromCenter(for: angle), angle: angle)
        var view = UIView(frame: CGRect(centeredOn: iconCenter,
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
        imgView.image = sectorIconImage
        view.addSubview(imgView)
        setLabel(to: &view, sector: sector)
    }
}

// MARK: - Innner circle
extension InteractiveSectoredGraphView {
    
    var innerRadius: CGFloat { graphRadius - arcWidth/2 }
    var innerRect: CGRect {
        let side = ((innerRadius*innerRadius) / 2).squareRoot() * 2
        return CGRect(x: viewCenter.x, y: viewCenter.y, width: side + Config.innerFrameOverflow, height: 76)
    }
    
    func drawCenterText() {
        guard let centerAttributedText = self.centerAttributedTextTop,
              let centerAttributedTextBottom = self.centerAttributedTextBottom,
              centerAttributedText.length > 0 else { return }
        centerView?.removeFromSuperview()
        var view = setStackView()
        var centerLabel = getLabel()
        if selectedSector.status == .selected {
            setCategoryNameInCenter(&view, &centerLabel, centerAttributedTextBottom)
        } else {
            setImageAndTextInCenter(&view, &centerLabel, centerAttributedText, centerAttributedTextBottom)
        }
        centerView = view
    }
    
    func drawInnerCircle() {
        let innerCircle = UIBezierPath(arcCenter: viewCenter,
                                       radius: 150/2 - 24/2,
                                       startAngle: -.pi * graphScale,
                                       endAngle: 2 * .pi, clockwise: true)
        backgroundColor?.setFill()
        innerCircle.fill()
    }
    
    func setStackView() -> UIStackView {
        let view = UIStackView(frame: innerRect)
        view.spacing = 0
        view.alignment = .center
        view.axis = .vertical
        addSubview(view)
        view.center = viewCenter
        view.distribution = .fillProportionally
        return view
    }
    
    func setCategoryNameInCenter(_ stackView: inout UIStackView, _ centerLabel: inout UILabel, _ bottomText: NSAttributedString) {
        stackView.addArrangedSubview(centerLabel)
        centerLabel.attributedText = sectors[selectedSector.index].categoryAtttributtedText
        let bottomLabel = getLabel()
        bottomLabel.textColor = .oneLisboaGray
        bottomLabel.attributedText = sectors[selectedSector.index].categoryAtttributtedTextValue
        stackView.addArrangedSubview(bottomLabel)
    }
    
    func setImageAndTextInCenter(_ stackView: inout UIStackView, _ centerLabel: inout UILabel, _ topText: NSAttributedString, _ bottomText: NSAttributedString) {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: Config.centerIconSize, height: Config.centerIconSize))
        image.contentMode = .scaleAspectFit
        image.image = selectedSector.status == .selected ? nil : centerIcon
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(centerLabel)
        centerLabel.attributedText = topText
        image.image = centerIcon
        let bottomLabel = getLabel()
        bottomLabel.attributedText = bottomText
        bottomLabel.layer.cornerRadius = 4
        bottomLabel.clipsToBounds = true
        stackView.addArrangedSubview(bottomLabel)
        NSLayoutConstraint.activate([centerLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
                                     (centerLabel.heightAnchor.constraint(equalToConstant: 20)),
                                     (bottomLabel.heightAnchor.constraint(equalToConstant: 28.0))
                                    ])
    }
}

// MARK: - Auxiliary methods
private extension InteractiveSectoredGraphView {
    
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
        subject.send(.sectorSelected(sector: sectors[safe: index]))
        for (index, view) in sectorViews.enumerated() {
            view.alpha = selectedSector.index != index ? Config.unselectedAlpha : 1.0
            
        }
        setNeedsDisplay()
    }
    
    func getIndexFor(sector: ChartSectorData) -> Int {
        let index = sectors.firstIndex { sectorData in
            sector.iconName == sectorData.iconName
        }
        return index ?? -1
    }
    
    func getLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.center = center
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    func getDistanceFromCenter(for angle: CGFloat) -> CGFloat {
        let minimumDistance = graphRadius + (arcWidth/2) + (Config.iconSize/2)
        return minimumDistance
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
    
    func getRepresentedPercentageInCircle(of value: CGFloat, in totalValue: CGFloat) -> CGFloat {
        return (.circle * value) / totalValue
    }
    
    func setLabel(to iconView: inout UIView, sector: ChartSectorData) {
        let iconLabel = UILabel(frame: CGRect(x: 0, y: iconView.frame.height-Config.labelHeight,
                                              width: iconView.frame.width, height: Config.labelHeight))
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
        iconLabel.accessibilityIdentifier = "\(chartType.suffix)\(AnalysisAreaAccessibility.chartSectorLabel)_\(sector.category)"
        iconView.addSubview(iconLabel)
    }
}

// MARK: - Tooltip
extension InteractiveSectoredGraphView {
    
    func setLabelWithTooltip() {
        guard chartType == .expenses || chartType == .payments else { return }
        let distanceFromNearestIcon: CGFloat = 50
        let tootltipImageView = UIImageView(frame: CGRect(x: 16,
                                                          y: topMargin + graphRadius + (arcWidth/2) + distanceFromNearestIcon,
                                                          width: 24,
                                                          height: 24))
        let label = UILabel(frame: CGRect(x: 48, y: topMargin + graphRadius + (arcWidth/2) + distanceFromNearestIcon,
                                          width: 264,
                                          height: 40))
        label.text = localized(chartType == .expenses ? "analysis_label_infoExpenses" : "analysis_label_infoPurchases")
        label.font = .typography(fontName: .oneB300Regular)
        label.numberOfLines = 2
        label.accessibilityIdentifier = "\(chartType.suffix)\(AnalysisAreaAccessibility.chartTooltipLabel)"
        addSubview(tootltipImageView)
        tootltipImageView.isUserInteractionEnabled = true
        tootltipImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTooltip)))
        tootltipImageView.image = Assets.image(named: "oneIcnHelp")
        tootltipImageView.contentMode = .scaleAspectFit
        tootltipImageView.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        tootltipImageView.accessibilityIdentifier = "\(chartType.suffix)\(AnalysisAreaAccessibility.chartTooltipImage)"
        addSubview(label)
        NSLayoutConstraint.activate([
            tootltipImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tootltipImageView.heightAnchor.constraint(equalToConstant: 24),
            tootltipImageView.widthAnchor.constraint(equalToConstant: 24),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 16),
            label.heightAnchor.constraint(equalToConstant: 40.0),
            label.leadingAnchor.constraint(equalTo: tootltipImageView.trailingAnchor, constant: 8.0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15.0)
        ])
        tooltipAndLabel = (tootltipImageView, label)
    }
    
    @objc func didTapTooltip() {
        subject.send(.tooltipTapped)
    }
}

extension CGRect {
    init(centeredOn center: CGPoint, size: CGSize) {
        self.init( origin: CGPoint(
            x: center.x - size.width/2,
            y: center.y - size.height/2), size: size
        )
    }
    
    var center: CGPoint {
        return CGPoint(
            x: origin.x + size.width/2,
            y: origin.y + size.height/2
        )
    }
}

extension CGFloat {
    /// Total radians of a circle (2pi radians)
    static var circle: CGFloat {
        return .pi*2.0
    }
}

extension CGPoint {
    /// displace a point by value, taking into account the angle of the arc
    /// - Parameters:
    ///   - value: this value represent how much the point must be moved away
    ///   - angle: used to correct the trayectory of the displaced point
    func projected(by value: CGFloat, angle: CGFloat) -> CGPoint {
        return CGPoint(
            x: x + value * cos(angle),
            y: y + value * sin(angle)
        )
    }
}
private enum Config {
    // Height for each sector label
    static let labelHeight: CGFloat = 19
    // Size for each sector icon, width/height
    static let iconSize: CGFloat = 50
    // Space bewteen icon and label for each sector
    static let iconMargin: CGFloat = 2
    // Size for the big center icon, width/height
    static let centerIconSize: CGFloat = 34
    // Alpha when sectors are not selected
    static let unselectedAlpha: CGFloat = 0.3
    // Main chart size, max is 0.5
    static let graphScale: CGFloat = 0.3
    // Inner radius for the center white hole
    static let innerRadioDelta: Double = 1.38
    // Offset of each category icon from center
    static let iconPositionOffset: CGFloat = 1.35
    // Allow inner label to overflow the center hole, to use all the available space for text
    static let innerFrameOverflow: CGFloat = 10
    // Index when no sector is selected
    static let unsetIndex: Int = -1
    static let graphDiameter: CGFloat = 180
    static let archWith: CGFloat = 24
}
