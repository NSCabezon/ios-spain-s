//
//  DrawingBoardView.swift
//  Grafica
//
//  Created by Boris Chirino Fernandez on 19/12/2019.
//  Copyright © 2019 Boris Chirino Fernandez. All rights reserved.
//

import UIKit

/// Attributes of the drawing elements
struct BoardAttributes {
    /// margin inside
    static let gap: CGFloat = 0.0
    /// Color of the circle
    static let pointsColor = UIColor.white
    /// Width for the line, also apply to circle line width
    static let lineWidth: CGFloat = 2.0
    /// Radius of the circles
    static let pointRadius: CGFloat = 8.0
    /// width of the line from points to monthsBar
    static let verticalLineWidth: CGFloat = 1.3
}

protocol DrawingBoardViewDelegate: AnyObject {
    func addTapCircleViews(points: [CGPoint])
}

/// The last 3 moonth expenses will be drawn here, outside curves are draw in the parent view ( ExpensesGraphViewPort )
class DrawingBoardView: UIView {
    
    weak var delegate: DrawingBoardViewDelegate?
    
    /// Data to be represented
    private var model: ExpensesGraphViewModel? {
        willSet {
            guard let optionalGraphData = newValue?.parsedResults else {
                return
            }
            graphData = optionalGraphData.expenses
        }
    }
    
    private var graphData: [MonthlyBalanceSmartPG]?
    
    /// Max value within elements
    private var maxMoneyValue: CGFloat {
        let maxAmount =  self.graphData?.compactMap {$0.amount}.max()
        return maxAmount?.toCGFLOAT ?? 0
    }
    
    /// reference to the parent view
    weak var viewPort: ExpensesGraphViewPort?
    /// The point where the first month is located inside this view
    private var firstMonthPoint: CGPoint = CGPoint.zero
    /// The point where the second month is located inside this view
    private var middleMonthPoint: CGPoint = CGPoint.zero
    /// The point where the third month is located inside this view
    private var lastMonthPoint: CGPoint = CGPoint.zero
    
    override func draw(_ rect: CGRect) {
        guard self.graphData != nil else { return }
        layer.sublayers?.removeAll()
        let path = quadCurvedPath()
        BoardAttributes.pointsColor.setStroke()
        path.lineWidth = BoardAttributes.lineWidth
        path.stroke()
        guard let superview = self.viewPort else { return }
        let translatedInitialPoint =  self.convert(firstMonthPoint, to: superview)
        let translatedMiddlePoint =  self.convert(middleMonthPoint, to: superview)
        let translatedFinalPoint =  self.convert(lastMonthPoint, to: superview)
        
        let pointsForInterpolating = DataForLeadingTrailingCurves(leftPoint: translatedInitialPoint,
                                                                  middlePoint: translatedMiddlePoint,
                                                                  rightPoint: translatedFinalPoint)
        superview.addOutsideLines(points: pointsForInterpolating)
        superview.setNeedsDisplay()
    }
    
    public func setModel(_ model: ExpensesGraphViewModel) {
        self.model = model
    }
    
    deinit {
        self.viewPort = nil
        self.model = nil
    }
}

extension DrawingBoardView {
    
    /// Find the coordinate for the Y position, givin a gap to allow the curve be visible if touch top or lower border
    /// - Parameter index: the index of the collection of months, each month will represent a point in the viewport.
    func coordYFor(index: Int) -> CGFloat {
        guard maxMoneyValue != 0 else { return bounds.height - 4 }
        var yCoordinate  = (bounds.height) - (bounds.height) * (graphData?[index].amount.toCGFLOAT ?? 1.0) / (maxMoneyValue)
        if yCoordinate == 0 {
            yCoordinate += BoardAttributes.gap
        } else if yCoordinate >= (bounds.maxY - BoardAttributes.gap) {
            yCoordinate -= BoardAttributes.gap
        }
        return yCoordinate
    }
    
    /**
     A quadratic curve is a Bezier parametric curve in the XY plane which is a curve of degree 2. This method appends a cubic Bézier curve from the current point to the end point specified by the endPoint parameter. The two control points define the curvature of the segment
     */
    func quadCurvedPath() -> UIBezierPath {
        guard let graphData = graphData else { return UIBezierPath() }
        let path = UIBezierPath()
        let step = bounds.width / CGFloat(graphData.count - 1)
        
        var startPoint = CGPoint(x: 0, y: coordYFor(index: 0))
        firstMonthPoint = startPoint
        path.move(to: startPoint)
        
        let circlesFillColor: CircleFillColor = self.model?.colorTheme == .black ? CircleFillColor.black : CircleFillColor.red
        var circlesPoints = [startPoint]
        drawCircle(point: startPoint, color: BoardAttributes.pointsColor, radius: BoardAttributes.pointRadius, innerColor: circlesFillColor)
        var oldControlP: CGPoint?
        
        for month in 1..<graphData.count {
            let endPoint = CGPoint(x: step * CGFloat(month), y: coordYFor(index: month))
            lastMonthPoint = endPoint
            if month == 1 {
                middleMonthPoint = endPoint
            }
            
            drawCircle(point: endPoint,
                       color: BoardAttributes.pointsColor,
                       radius: BoardAttributes.pointRadius,
                       innerColor: circlesFillColor)
            circlesPoints.append(endPoint)
            
            var thirdControlPoint: CGPoint?
            if month < graphData.count - 1 {
                thirdControlPoint = CGPoint(x: step * CGFloat(month + 1), y: coordYFor(index: month + 1))
            }
            
            let newControlP = controlPointForPoints(start: startPoint, end: endPoint, next: thirdControlPoint)
            
            path.addCurve(to: endPoint,
                          controlPoint1: oldControlP ?? startPoint,
                          controlPoint2: newControlP ?? endPoint)
            
            startPoint = endPoint
            oldControlP = antipodalFor(point: newControlP, center: endPoint)
        }
        delegate?.addTapCircleViews(points: circlesPoints)
        return path
    }
}

extension CGFloat {
    func between(lhs: CGFloat, rhs: CGFloat) -> Bool {
        return self >= Swift.min(lhs, rhs) && self <= Swift.max(lhs, rhs)
    }
}

extension Decimal {
    var toCGFLOAT: CGFloat? {
        return CGFloat(exactly: self as NSNumber)
    }
}
