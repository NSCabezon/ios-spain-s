//
//  PieChartView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 18/2/22.
//

import Foundation
import UIKit
import CoreDomain

typealias PieChartPaths = (sector: CategoryRepresentable, path: UIBezierPath)
typealias PieChartSector = (sector: CategoryRepresentable, startAngle: CGFloat, endAngle: CGFloat)

protocol PieChartViewRepresentable {
    var categories: [CategoryRepresentable] { get }
    var graphDiameter: CGFloat { get }
    var innerCircleDiameter: CGFloat { get }
}

class PieChartView: UIView {
    private var categories: [CategoryRepresentable] = []
    var graphDiameter: CGFloat = 212
    var innerCircleDiameter: CGFloat = 156.0
    var graphRadius: CGFloat { graphDiameter / 2 }
    var paths = [PieChartPaths]()
    var sectors = [PieChartSector]()
    var viewCenter: CGPoint { CGPoint(x: bounds.midX, y: bounds.midY) }
    var drawSteps: [(() -> Void)] = []
    var innerRadius: CGFloat {
        return innerCircleDiameter/2
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            paths.removeAll()
            drawSteps.forEach { step in step() }
        }
    }
    
    func build() {
        self.drawSteps = [
            setSectors,
            drawPaths,
            drawInnerCircle
        ]
    }
    
    func drawPaths() {
        paths.forEach {
            getPathColor(for: $0.sector).setFill()
            $0.path.addLine(to: viewCenter)
            $0.path.fill()
        }
    }
    
    func setChartInfo(_ representable: PieChartViewRepresentable) {
        self.categories = representable.categories
        self.graphDiameter = representable.graphDiameter
        self.innerCircleDiameter = representable.innerCircleDiameter
    }
    
    func getPathColor(for category: CategoryRepresentable) -> UIColor {
        category.type.color
    }
}

private extension PieChartView {
    
    func setSectors() {
        self.getAnglesInfo(for: categories)
    }
    
    func drawInnerCircle() {
        let innerCircle = UIBezierPath(arcCenter: viewCenter,
                                       radius: innerCircleDiameter/2,
                                       startAngle: -.pi * 0.3,
                                       endAngle: 2 * .pi, clockwise: true)
        backgroundColor?.setFill()
        innerCircle.fill()
    }
    
    func getAnglesInfo(for sectors: [CategoryRepresentable]) {
        var anglesInfo: [PieChartSector] = []
        var startAngle: CGFloat = (.pi * 3) / 2
        for sector in sectors {
            let endAngle = startAngle + (CGFloat(sector.percentage) * CGFloat.circle / 100.0)
            defer {
                startAngle = endAngle
            }
            let pieSector = (sector: sector, startAngle: startAngle, endAngle: endAngle)
            anglesInfo.append(pieSector)
            appendArcPath(for: pieSector)
        }
        self.sectors = anglesInfo
    }
    
    func getRepresentedPercentageInCircle(of value: CGFloat, in totalValue: CGFloat) -> CGFloat {
        return (.circle * value) / totalValue
    }
    
    func appendArcPath(for sector: PieChartSector) {
        let path = UIBezierPath(arcCenter: viewCenter, radius: graphRadius, startAngle: sector.startAngle, endAngle: sector.endAngle, clockwise: true)
        paths.append((sector: sector.sector, path: path))
    }
}
