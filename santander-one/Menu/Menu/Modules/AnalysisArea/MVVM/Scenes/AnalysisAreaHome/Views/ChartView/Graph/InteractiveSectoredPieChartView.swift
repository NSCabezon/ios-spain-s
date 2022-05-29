//
//  InteractiveSectoredPieChartView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 21/2/22.
//

import UIKit
import CoreFoundationLib
import UI
import UIOneComponents
import Foundation
import OpenCombine

enum InteractiveSectoredPieChartViewState: State {
    case sectorSelected(sector: CategoryRepresentable)
}

protocol InteractiveSectoredPieChartViewRepresentable: CentertextPieViewRepresentable {
    var iconSize: CGFloat { get }
}

final class InteractiveSectoredPieChartView: CenterTextPieView {
    private var iconSize: CGFloat = 32.0
    private var selectedSector: (index: Int, status: PieChartViewSectorStatus) = (-1, .notSet)
    private var sectorViews = [UIView]()
    private var subject = PassthroughSubject<InteractiveSectoredPieChartViewState, Never>()
    public var publisher: AnyPublisher<InteractiveSectoredPieChartViewState, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGesture()
    }
    
    override func reset() {
        super.reset()
        selectedSector = (-1, .notSet)
        sectorViews.forEach { view in view.removeFromSuperview() }
        sectorViews.removeAll()
    }
    
    override func build() {
        super.build()
        drawSteps.append(drawSelectionArc)
        drawSteps.append(addSectors)
        setNeedsDisplay()
    }
    
    func sets() {
        let rect = innerRect
    }
    
    override func getPathColor(for category: CategoryRepresentable) -> UIColor {
        self.resolveColorFor(category: category)
    }
    
    func setChartInfo(_ representable: InteractiveSectoredPieChartViewRepresentable) {
        super.setChartInfo(representable)
        self.iconSize = representable.iconSize
    }
}

private extension InteractiveSectoredPieChartView {
    var distanceToIcon: CGFloat {
        let distanceFromArcToNonRotatedIconCenter: CGFloat = 12
        let iconDiagonal = sqrt((iconSize*iconSize) + (iconSize*iconSize))
        let normalDistance = distanceFromArcToNonRotatedIconCenter + iconSize/2
        let rotatedDistance = normalDistance - iconDiagonal/2
        let distanceFromArcToIcon = rotatedDistance + iconDiagonal/2
        let minimumDistance = graphRadius + distanceFromArcToIcon
        return minimumDistance
    }
    
    func addSectors() {
        guard selectedSector.status == .notSet else { return }
        drawSectorIcons()
    }
    
    func addGesture() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc func didTapView(_ gesture: UITapGestureRecognizer) {
        let point: CGPoint = gesture.location(in: self)
        for sectorPath in paths where sectorPath.path.contains(point) {
            selectSectorFor(index: getIndexFor(category: sectorPath.sector))
            return
        }
        selectSectorFor(index: selectedSector.index)
    }
    
    func drawSectorIcons() {
        self.sectors.forEach { sector, startAngle, endAngle in
            let midAngle = getMidAngle(between: startAngle, and: endAngle)
            setIcon(in: sector, angle: midAngle)
        }
    }
    
    func setIcon(in category: CategoryRepresentable, angle: CGFloat) {
        guard let sectorIconImage = Assets.image(named: category.type.iconKey) else { return }
        let iconCenter = viewCenter.projected(by: distanceToIcon, angle: angle)
        var view = UIView(frame: CGRect(centeredOn: iconCenter, size: CGSize(width: iconSize, height: iconSize)))
        view.tag = getIndexFor(category: category)
        view.isUserInteractionEnabled = true
        view.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelectSector(_:)))]
        self.addSubview(view)
        self.sectorViews.append(view)
        let imgHeight = view.frame.height
        let imgView = UIImageView(frame: view.frame)
        imgView.contentMode = .scaleAspectFit
        imgView.image = sectorIconImage
        imgView.accessibilityIdentifier = "\(category.categorization.prefixKey)\(AnalysisAreaAccessibility.chartSectorImage)_\(category.type.rawValue)"
        imgView.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        view.addSubview(imgView)
        imgView.fullFit()
    }
    
    func getMidAngle(between startAngle: CGFloat, and endAngle: CGFloat) -> CGFloat {
        return (startAngle + endAngle) / 2
    }
    
    func getIndexFor(category: CategoryRepresentable) -> Int {
        let index = sectors.firstIndex { sectorData in
            category.type.iconKey == sectorData.sector.type.iconKey
        }
        return index ?? -1
    }
    
    @objc func didSelectSector(_ gesture: UITapGestureRecognizer) {
        guard let index = (gesture.view)?.tag else { return }
        selectSectorFor(index: index)
    }
    
    func selectSectorFor(index: Int) {
        guard selectedSector.status == .none || selectedSector.status == .notSet else {
            currentCenterTitleText = nil
            currentSubTitleText = nil
            selectedSector = (-1, .none)
            setNeedsDisplay()
            return
        }
        selectedSector = (index, index != -1 ? .selected : .none)
        guard selectedSector.status == .selected else { return }
        if let sector = sectors[safe: index]?.sector {
            let selectedCategory = sector
            currentCenterTitleText = selectedCategory.amount.getFormattedValueOrEmptyUI(withDecimals: 2, truncateDecimalIfZero: true)
            currentSubTitleText = localized(selectedCategory.type.literalKey)
            subject.send(.sectorSelected(sector: sector))
        }
        setNeedsDisplay()
    }
    
    func resolveColorFor(category: CategoryRepresentable) -> UIColor {
        let index = getIndexFor(category: category)
        let categoryType = category.type
        switch selectedSector.status {
        case .notSet, .none:
            return categoryType.color
        case .selected:
            return selectedSector.index == index ? categoryType.color : categoryType.lightColor
        }
    }
    
    func getSelectionArcColor(for category: CategoryRepresentable) -> UIColor {
        let index = getIndexFor(category: category)
        let categoryType = category.type
        switch selectedSector.status {
        case .notSet, .none:
            return categoryType.color
        case .selected:
            return selectedSector.index == index ? categoryType.darkColor : categoryType.lightColor
        }
    }
    
    func drawSelectionArc() {
        let selectionArcWidth: CGFloat = 4
        sectors.forEach {
            let path = UIBezierPath(arcCenter: viewCenter, radius: graphRadius - selectionArcWidth/2, startAngle: $0.startAngle, endAngle: $0.endAngle, clockwise: true)
            path.lineWidth = selectionArcWidth
            getSelectionArcColor(for: $0.sector).setStroke()
            path.stroke()
        }
        
    }
}

private enum PieChartViewSectorStatus: Comparable {
    case notSet
    case none
    case selected
}
