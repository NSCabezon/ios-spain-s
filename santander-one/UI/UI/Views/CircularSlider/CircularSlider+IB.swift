//
//  CircularSlider+IB.swift
//  UI
//

import UIKit

extension CircularSlider {
    
    // MARK: CALCULATION METHODS
    /** Calculates the angle between two points on a circle */
    internal func calculateAngle(from: CGPoint, toPoint: CGPoint) -> CGFloat {
        var vector = CGPoint(x: toPoint.x - from.x, y: toPoint.y - from.y)
        let magnitude = CGFloat(sqrt(square(Double(vector.x)) + square(Double(vector.y))))
        vector.x /= magnitude
        vector.y /= magnitude
        let cartesianRad = Double(atan2(vector.y, vector.x))
        
        var compassRad = toCompass(cartesianRad)
        
        if compassRad < 0 {
            compassRad += (2 * Double.pi)
        }
        
        assert(compassRad >= 0 && compassRad <= 2 * Double.pi, "angle must be positive")
        return CGFloat(toDeg(compassRad))
    }
    
    /** Returns a `CGPoint` on a circle given its radius and an angle */
    private func pointOn(radius: CGFloat, angle: CGFloat) -> CGPoint {
        var result = CGPoint()
        
        let cartesianAngle = CGFloat(toCartesian(toRad(Double(angle))))
        result.y = round(radius * sin(cartesianAngle))
        result.x = round(radius * cos(cartesianAngle))
        
        return result
    }
    
    /** Returns a `CGPoint` on the slider's circle given an angle */
    internal func pointOnCircleAt(angle: CGFloat) -> CGPoint {
        let offset = pointOn(radius: calculatedRadius, angle: angle)
        return CGPoint(x: centerPoint.x + offset.x, y: centerPoint.y + offset.y)
    }
    
    /** Calculates the bounds of a marker's frame given its index */
    func frameForMarkingAt(_ index: Int) -> CGRect {
        var percentageAlongCircle: CGFloat!
        
        // Calculate degrees for marking
        percentageAlongCircle = fullCircle ? ((100.0 / CGFloat(markerCount)) * CGFloat(index)) / 100.0 : ((100.0 / CGFloat(markerCount - 1)) * CGFloat(index)) / 100.0
        
        let markerDegrees = percentageAlongCircle * maximumAngle
        let pointOnCircle = pointOnCircleAt(angle: markerDegrees)
        
        let markSize = markerSize ?? CGSize(width: ((CGFloat(lineWidth) + handleDiameter) / CGFloat(2)), height: ((CGFloat(lineWidth) + handleDiameter) / CGFloat(2)))
        
        // center along line
        let offsetFromCircle = CGPoint(x: -markSize.width / 2.0,
                                       y: -markSize.height / 2.0)
        
        return CGRect(x: pointOnCircle.x + offsetFromCircle.x,
                      y: pointOnCircle.y + offsetFromCircle.y,
                      width: markSize.width,
                      height: markSize.height)
    }
    
    /** Calculates the bounds of a label's frame given its index */
    func frameForLabelAt(_ index: Int) -> CGRect {
        let label = labels[index]
        var percentageAlongCircle: CGFloat!
        
        // calculate degrees for label
        percentageAlongCircle = fullCircle ? ((100.0 / CGFloat(labels.count)) * CGFloat(index)) / 100.0 : ((100.0 / CGFloat(labels.count - 1)) * CGFloat(index)) / 100.0
        
        let labelDegrees = percentageAlongCircle * maximumAngle
        let pointOnCircle = pointOnCircleAt(angle: labelDegrees)
        
        let labelSize = sizeOf(string: label, withFont: labelFont)
        let offsetFromCircle = offsetForLabelAt(index: index, withSize: labelSize)
        
        return CGRect(x: pointOnCircle.x + offsetFromCircle.x,
                      y: pointOnCircle.y + offsetFromCircle.y,
                      width: labelSize.width,
                      height: labelSize.height)
    }
    
    /** Calculates the labels' offset so it would not intersect with the slider's line */
    private func offsetForLabelAt(index: Int, withSize labelSize: CGSize) -> CGPoint {
        let percentageAlongCircle = fullCircle ? ((100.0 / CGFloat(labels.count)) * CGFloat(index)) / 100.0 : ((100.0 / CGFloat(labels.count - 1)) * CGFloat(index)) / 100.0
        let labelDegrees = percentageAlongCircle * maximumAngle
        
        let radialDistance = labelInwardsDistance + labelOffset
        let inwardOffset = pointOn(radius: radialDistance, angle: CGFloat(labelDegrees))
        
        return CGPoint(x: -labelSize.width * 0.5 + inwardOffset.x, y: -labelSize.height * 0.5 + inwardOffset.y)
    }
    
    /** The labels' distance from center */
    private var labelInwardsDistance: CGFloat {
        return 0.1 * -(radius) - 0.5 * CGFloat(lineWidth) - 0.5 * labelFont.pointSize
    }
    
    /** Calculates the angle of a certain arc */
    private func degreesFor(arcLength: CGFloat, onCircleWithRadius radius: CGFloat, withMaximumAngle degrees: CGFloat) -> CGFloat {
        let totalCircumference = CGFloat(2 * Double.pi) * radius
        
        let arcRatioToCircumference = arcLength / totalCircumference
        
        return degrees * arcRatioToCircumference
    }
    
    /** Checks whether or not a point lies within the slider's circle */
    func pointInsideCircle(_ point: CGPoint) -> Bool {
        let point1 = centerPoint
        let point2 = point
        let xDist = point2.x - point1.x
        let yDist = point2.y - point1.y
        let distance = sqrt((xDist * xDist) + (yDist * yDist))
        return distance < calculatedRadius + CGFloat(lineWidth) * 1.8
    }
    
    /** Converts cartesian radians to compass radians */
    private func toCompass(_ cartesianRad: Double) -> Double {
        return cartesianRad + (Double.pi / 2)
    }
    
    /** Calculates the size of a label given the string and its font */
    private func sizeOf(string: String, withFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return NSAttributedString(string: string, attributes: attributes).size()
    }
    
    // MARK: SUPPORT METHODS
    /** Calculates the angle from north given a value */
    func angleFrom(value: Double) -> CGFloat {
        guard value != minimumValue else { return 0.0 }
        return (CGFloat(value - minimumValue) * maximumAngle) / CGFloat(maximumValue - minimumValue)
    }
    
    /** Calculates the value given an angle from north */
    func valueFrom(angle: CGFloat) -> Double {
        return ((maximumValue - minimumValue) * Double(angle) / Double(maximumAngle)) + minimumValue
    }
    
    func continueTracking(_ touch: UITouch) {
        let newPoint = touch.location(in: self)
        var newAngle = floor(calculateAngle(from: centerPoint, toPoint: newPoint))
        
        // Sliding direction and revolutions' count detection
        func changeSlidingDirection(_ direction: CircularSliderDirection) {
            // Change direction (without multiplicity)
            if self.slidingDirection != direction {
                self.slidingDirection = direction
                self.delegate?.circularSlider(self, directionChangedTo: slidingDirection)
            }
        }
        
        if newAngle > angle {
            // Check if crossing the critical point (north/angle=0.0)
            if isSliding && maximumRevolutions != -1 && (newAngle - angle > revolutionsDetectionThreshold) {
                // Check if should be bound (maximumRevolutions reached or less than 0)
                if revolutionsCount - 1 < 0 {
                    newAngle = 0.0
                } else {
                    revolutionsCount -= 1
                    delegate?.circularSlider(self, revolutionsChangedTo: revolutionsCount)
                    changeSlidingDirection(.counterclockwise)
                }
            } else if isSliding && (newAngle - angle > revolutionsDetectionThreshold) {
                changeSlidingDirection(.counterclockwise)
            } else {
                changeSlidingDirection(.clockwise)
            }
        } else if newAngle < angle {
            // Check if crossing the critical point (north/angle=0.0)
            if isSliding && maximumRevolutions != -1 && (angle - newAngle > revolutionsDetectionThreshold) {
                // Check if should be bound (maximumRevolutions reached or less than 0)
                if revolutionsCount + 1 > maximumRevolutions {
                    newAngle = 360.0
                } else {
                    revolutionsCount += 1
                    delegate?.circularSlider(self, revolutionsChangedTo: revolutionsCount)
                    changeSlidingDirection(.clockwise)
                }
            } else if isSliding && (angle - newAngle > revolutionsDetectionThreshold) {
                changeSlidingDirection(.clockwise)
            } else {
                changeSlidingDirection(.counterclockwise)
            }
        }
        
        if !isSliding {
            isSliding = true
        }
        
        moveHandle(newAngle: newAngle)
        delegate?.circularSlider(self, valueChangedTo: currentValue, fromUser: true)
        sendActions(for: UIControl.Event.valueChanged)
    }
    
    /** Moves the handle to `newAngle` */
    private func moveHandle(newAngle: CGFloat) {
        if newAngle > maximumAngle {    // for incomplete circles
            if newAngle > maximumAngle + (360 - maximumAngle) / 2.0 {
                angle = 0
                setNeedsDisplay()
            } else {
                angle = maximumAngle
                setNeedsDisplay()
            }
        } else {
            angle = newAngle
        }
        setNeedsDisplay()
    }
    
    /** Converts radians to degrees */
    func toDeg(_ radians: Double) -> Double {
        return ((180.0 * radians) / Double.pi)
    }
}
