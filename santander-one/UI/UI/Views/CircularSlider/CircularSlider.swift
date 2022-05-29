//
//  CircularSlider.swift
//  UI
//
// based on: https://github.com/ThunderStruct/MSCircularSlider (v1.3.0)

import UIKit
import QuartzCore

public protocol CircularSliderProtocol: AnyObject {
    func circularSlider(_ slider: CircularSlider, valueChangedTo value: Double, fromUser: Bool)   // fromUser indicates whether the value changed by sliding the handle (fromUser == true) or through other means (fromUser == false)
    func circularSlider(_ slider: CircularSlider, startedTrackingWith value: Double)
    func circularSlider(_ slider: CircularSlider, endedTrackingWith value: Double)
    func circularSlider(_ slider: CircularSlider, directionChangedTo value: CircularSliderDirection)
    func circularSlider(_ slider: CircularSlider, revolutionsChangedTo value: Int)
}

extension CircularSliderProtocol {
    // Optional Methods
    func circularSlider(_ slider: CircularSlider, startedTrackingWith value: Double) {}
    func circularSlider(_ slider: CircularSlider, endedTrackingWith value: Double) {}
    func circularSlider(_ slider: CircularSlider, directionChangedTo value: CircularSliderDirection) {}
    func circularSlider(_ slider: CircularSlider, revolutionsChangedTo value: Int) {}
}

public enum CircularSliderDirection {
    case clockwise, counterclockwise, none
}

public class CircularSlider: UIControl {
    /** The slider's main delegate */
    weak public var delegate: CircularSliderProtocol?
    // MARK: VALUE/ANGLE MEMBERS
    
    /** The slider's least possible value - *default: 0.0* */
    public var minimumValue: Double = 0.0 { didSet { setNeedsDisplay() } }
    
    /** The slider's value at maximumAngle - *default: 100.0* */
    public var maximumValue: Double = 100.0 { didSet { setNeedsDisplay() } }
    
    /** The handle's current value - *default: minimumValue* */
    public var currentValue: Double {
        get {
            return valueFrom(angle: handle.angle)
        }
        set {
            let val = min(max(minimumValue, newValue), maximumValue)
            handle.currentValue = val
            angle = angleFrom(value: val)
            delegate?.circularSlider(self, valueChangedTo: val, fromUser: false)
            sendActions(for: UIControl.Event.valueChanged)
            setNeedsDisplay()
        }
    }
    
    /** The slider's circular angle - *default: 360.0 (full circle)* */
    public var maximumAngle: CGFloat = 360.0 {     // Full circle by default
        didSet {
            if maximumAngle > 360.0 {
                maximumAngle = 360.0
            } else if maximumAngle < 0 {
                maximumAngle = 360.0
            }
            currentValue = valueFrom(angle: angle)
            setNeedsDisplay()
        }
    }
    
    /** The slider layer's rotation - *default: nil / pointing north* */
    public var rotationAngle: CGFloat? {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The slider's radius - *default: computed* */
    var radius: CGFloat = -1.0 {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** Uniform padding */
    public var sliderPadding: CGFloat = 0.0 { didSet { setNeedsDisplay() } }
    
    // MARK: REVOLUTIONS AND DIRECTION MEMBERS
    /** Specifies the current handle sliding direction - *default: .none* */
    public var slidingDirection: CircularSliderDirection = .none
    
    /** Indicates whether the user is sliding the handle or not - *default: false* */
    internal var isSliding: Bool = false
    
    /** Counts how many revolutions have been made (works only when `maximumAngle` = 360.0 and `boundedMaxAngle` = false) - *default: 0* */
    var revolutionsCount: Int = 0
    
    /** Sets the maximum number of revolutions before the slider gets bounded at angle 360.0 (setting a -ve value will let the slider endlessly revolve; valid only for fully circular sliders) - *default: -1* */
    public var maximumRevolutions: Int = 0
    
    // MARK: LINE MEMBERS
    /** The slider's line width - *default: 5*  */
    public var lineWidth: Int = 5 {
        didSet {
            setNeedsUpdateConstraints()
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** The color of the filled part of the slider - *default: .darkGray* */
    public var filledColor: UIColor = .darkGray { didSet { setNeedsDisplay() } }
    
    /** The color of the unfilled part of the slider - *default: .lightGray* */
    public var unfilledColor: UIColor = .lightGray { didSet { setNeedsDisplay() } }
    
    /** The slider's ending line cap - *default: .round* */
    public var unfilledLineCap: CGLineCap = .round { didSet { setNeedsDisplay() } }
    
    /** The slider's beginning line cap - *default: .round* */
    public var filledLineCap: CGLineCap = .round { didSet { setNeedsDisplay() } }
    
    // MARK: HANDLE MEMBERS
    /** The slider's handle layer */
    let handle = CircularSliderHandle()
    
    /** The handle's current angle from north - *default: 0.0 * */
    public var angle: CGFloat {
        get {
            return handle.angle
        }
        set {
            handle.angle = max(0, newValue).truncatingRemainder(dividingBy: maximumAngle + 1)
        }
    }
    
    /** The handle's color - *default: .darkGray* */
    public var handleColor: UIColor {
        get {
            return handle.color
        }
        set {
            handle.color = newValue
            setNeedsDisplay()
        }
    }
    
    /** The handle's type - *default: .largeCircle* */
    public var handleType: CircularSliderHandleType {
        get {
            return handle.handleType
        }
        set {
            handle.handleType = newValue
            setNeedsDisplay()
        }
    }
    
    /** The handle's enlargement point from default size - *default: 10* */
    public var handleEnlargementPoints: Int {
        get {
            return handle.enlargementPoints
        }
        set {
            handle.enlargementPoints = newValue
        }
    }
    
    /** Specifies whether the handle should highlight upon touchdown or not - *default: true* */
    public var handleHighlightable: Bool {
        get {
            return handle.isHighlightable
        }
        set {
            handle.isHighlightable = newValue
        }
    }
    
    /** The handle's image (overrides the handle color and type) - *default: nil* */
    public var handleImage: UIImage? {
        get {
            return handle.image
        }
        set {
            handle.image = newValue
        }
    }
    
    /** Specifies whether or not the handle should rotate to always point outwards - *default: false* */
    public var handleRotatable: Bool {
        get {
            return handle.isRotatable
        }
        set {
            handle.isRotatable = newValue
        }
    }
    
    /** The calculated handle's diameter based on its type */
    public var handleDiameter: CGFloat { return handle.diameter }
    
    // MARK: LABEL MEMBERS
    
    /** The slider's labels array (laid down counter-clockwise) */
    public var labels: [String] = [] {         // All labels are evenly spaced
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** Specifies whether or not the handle should snap to the nearest label upon touch release - *default: false* */
    public var snapToLabels: Bool = false {        // The 'snap' occurs on touchUp
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The labels' font - *default: .systemFont(ofSize: 12.0)* */
    public var labelFont: UIFont = .systemFont(ofSize: 12.0) { didSet { setNeedsDisplay() } }
    
    /** The labels' color - *default: .black* */
    public var labelColor: UIColor = .black { didSet { setNeedsDisplay() } }
    
    /** The labels' offset from center (negative values push inwards) - *default: 0* */
    public var labelOffset: CGFloat = 0 {    // Negative values move the labels closer to the center
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    // MARK: MARKER MEMBERS
    /** The number of markers to be displayed - *default: 0* */
    public var markerCount: Int = 0 {      // All markers are evenly spaced
        didSet {
            markerCount = max(markerCount, 0)
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The markers' color - *default: .darkGray* */
    public var markerColor: UIColor = .darkGray { didSet { setNeedsDisplay() } }
    
    /** The markers' bezier path (takes precendence over `markerImage`)- *default: nil / circle shape will be drawn* */
    public var markerPath: UIBezierPath? {   // Takes precedence over markerImage
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The markers' image - *default: nil* */
    public var markerImage: UIImage? {       // Mutually-exclusive with markerPath
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** Specifies whether or not the handle should snap to the nearest marker upon touch release - *default: false* */
    public var snapToMarkers: Bool = false {        // The 'snap' occurs on touchUp
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The markers' size - *default: nil* */
    public var markerSize: CGSize? {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    // CALCULATED MEMBERS
    /** The slider's calculated radius based on the components' sizes */
    public var calculatedRadius: CGFloat {
        let minimumSize = min(bounds.size.height - sliderPadding, bounds.size.width - sliderPadding)
        let halfLineWidth = ceilf(Float(lineWidth) / 2.0)
        let halfHandleWidth = ceilf(Float(handleDiameter) / 2.0)
        radius = minimumSize * 0.5 - CGFloat(max(halfHandleWidth, halfLineWidth))
        return radius
    }
    
    // MARK: SETTER METHODS
    /** Appends a new label to the `labels` array */
    public func addLabel(_ string: String) {
        labels.append(string)
        update()
    }
    
    /** Replaces the label at a certain index with the given string */
    public func changeLabel(at index: Int, string: String) {
        assert(labels.count > index && index >= 0, "label index out of bounds")
        labels[index] = string
        update()
    }
    
    /** Removes a label at a given index */
    public func removeLabel(at index: Int) {
        assert(labels.count > index && index >= 0, "label index out of bounds")
        labels.remove(at: index)
        update()
    }
    
    // MARK: INIT AND VIRTUAL METHODS
    func initHandle() {
        handle.delegate = self
        handle.center = { return self.pointOnCircleAt(angle: self.angle) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initHandle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        initHandle()
    }
    
    override public var intrinsicContentSize: CGSize {
        let diameter = calculatedRadius * 2
        return CGSize(width: diameter, height: diameter)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        drawLabels(ctx: ctx!)
        // Draw filled and unfilled lines
        drawLine(ctx: ctx!)
        drawMarkings(ctx: ctx!)
        handle.draw(in: ctx!)
        // Rotate slider
        let rotationalTransform = getRotationalTransform()
        self.transform = rotationalTransform
        subviews.forEach { $0.transform = rotationalTransform.inverted() }
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard event != nil else { return false }
        return handle.contains(point)
    }
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        guard handle.contains(location) else { return false }
        handle.isPressed = true
        delegate?.circularSlider(self, startedTrackingWith: currentValue)
        setNeedsDisplay()
        return true
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        continueTracking(touch)
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        delegate?.circularSlider(self, endedTrackingWith: currentValue)
        snapHandle()
        
        handle.isPressed = false
        isSliding = false
        
        if slidingDirection != .none {
            slidingDirection = .none
            delegate?.circularSlider(self, directionChangedTo: slidingDirection)
        }
        setNeedsDisplay()
    }
    
    /** Converts degrees to radians */
    func toRad(_ degrees: Double) -> Double {
        return ((Double.pi * degrees) / 180.0)
    }
    
    /** Calculates the entire layer's rotation (used to cancel out any rotation affecting custom subviews) */
    public func getRotationalTransform() -> CGAffineTransform {
        if fullCircle {
            // No rotation required
            let transform = CGAffineTransform.identity.rotated(by: CGFloat(0))
            return transform
        } else {
            if let rotation = self.rotationAngle {
                return CGAffineTransform.identity.rotated(by: CGFloat(toRad(Double(rotation))))
            }
            
            let radians = Double(-(maximumAngle / 2)) / 180.0 * Double.pi
            let transform = CGAffineTransform.identity.rotated(by: CGFloat(radians))
            return transform
        }
    }
}

internal extension CircularSlider {
    
    /** A read-only property that indicates whether or not the slider is a full circle */
    public var fullCircle: Bool {
        return maximumAngle == 360.0
    }
    
    /** A constant threshold used to detect how many revolutions have passed - *default: 180.0* */
    var revolutionsDetectionThreshold: CGFloat { 180.0 }
    
    /** The slider's center point */
    var centerPoint: CGPoint {
        return CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    }
    
    /** Converts compass radians to cartesian radians */
     func toCartesian(_ compassRad: Double) -> Double {
        return compassRad - (Double.pi / 2)
    }
    
    func square(_ value: Double) -> Double {
        return value * value
    }
    
    /** Draws a filled circle in context */
    @discardableResult
    func drawFilledCircle(ctx: CGContext, center: CGPoint, radius: CGFloat) -> CGRect {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        ctx.fillEllipse(in: frame)
        return frame
    }
}

private extension CircularSlider {
    
    /** Draws a circular line in the given context */
    func drawLine(ctx: CGContext) {
        unfilledColor.set()
        // Draw unfilled circle
        let config = ArcConfiguration(ctx: ctx,
                                      center: centerPoint,
                                      radius: calculatedRadius,
                                      lineWidth: CGFloat(lineWidth))
        drawUnfilledCircle(configuration: config, maximumAngle: maximumAngle, lineCap: unfilledLineCap)
        
        filledColor.set()
        // Draw filled circle
        drawArc(configuration: config, fromAngle: 0, toAngle: CGFloat(angle), lineCap: filledLineCap)
    }
    
    /** Draws the slider's labels (if any exist) in the given context */
    func drawLabels(ctx: CGContext) {
        if labels.count > 0 {
            let attributes = [NSAttributedString.Key.font: labelFont,
                              NSAttributedString.Key.foregroundColor: labelColor] as [NSAttributedString.Key: Any]
            
            for index in 0 ..< labels.count {
                let label = labels[index] as NSString
                let labelFrame = frameForLabelAt(index)
                
                ctx.saveGState()
                
                // Invert transform to cancel rotation on labels
                ctx.concatenate(CGAffineTransform(translationX: labelFrame.origin.x + (labelFrame.width / 2),
                                                  y: labelFrame.origin.y + (labelFrame.height / 2)))
                ctx.concatenate(getRotationalTransform().inverted())
                ctx.concatenate(CGAffineTransform(translationX: -(labelFrame.origin.x + (labelFrame.width / 2)),
                                                  y: -(labelFrame.origin.y + (labelFrame.height / 2))))
                
                // Draw label
                label.draw(in: labelFrame, withAttributes: attributes)
                
                ctx.restoreGState()
            }
        }
    }
    
    /** Draws the slider's markers (if any exist) in the given context */
    func drawMarkings(ctx: CGContext) {
        for index in 0 ..< markerCount {
            let markFrame = frameForMarkingAt(index)
            
            ctx.saveGState()
            
            ctx.concatenate(CGAffineTransform(translationX: markFrame.origin.x + (markFrame.width / 2),
                                              y: markFrame.origin.y + (markFrame.height / 2)))
            ctx.concatenate(getRotationalTransform().inverted())
            ctx.concatenate(CGAffineTransform(translationX: -(markFrame.origin.x + (markFrame.width / 2)),
                                              y: -(markFrame.origin.y + (markFrame.height / 2))))
            
            if self.markerPath != nil {
                markerColor.setFill()
                markerPath?.fill()
            } else if self.markerImage != nil {
                self.markerImage?.draw(in: markFrame)
            } else {
                let markPath = UIBezierPath(ovalIn: markFrame)
                markerColor.setFill()
                markPath.fill()
            }
            
            ctx.restoreGState()
        }
    }
    
    /** Draws an unfilled circle in context */
    func drawUnfilledCircle(configuration: ArcConfiguration, maximumAngle: CGFloat, lineCap: CGLineCap) {
        drawArc(configuration: configuration,
                fromAngle: 0,
                toAngle: maximumAngle,
                lineCap: lineCap)
    }
    
    /** Draws an arc in context */
    func drawArc(configuration: ArcConfiguration, fromAngle: CGFloat, toAngle: CGFloat, lineCap: CGLineCap) {
        let cartesianFromAngle = toCartesian(toRad(Double(fromAngle)))
        let cartesianToAngle = toCartesian(toRad(Double(toAngle)))
        
        configuration.ctx.addArc(center: configuration.center,
                                 radius: configuration.radius,
                                 startAngle: CGFloat(cartesianFromAngle),
                                 endAngle: CGFloat(cartesianToAngle), clockwise: false)
        
        configuration.ctx.setLineWidth(configuration.lineWidth)
        configuration.ctx.setLineCap(lineCap)
        configuration.ctx.drawPath(using: CGPathDrawingMode.stroke)
    }
    
    /** Snaps the handle to the nearest label/marker depending on the settings */
    func snapHandle() {
        // Snapping calculation
        var fixedAngle = 0.0 as CGFloat
        
        if angle < 0 {
            fixedAngle = -angle
        } else {
            fixedAngle = maximumAngle - angle
        }
        
        var minDist = maximumAngle
        var newAngle: CGFloat = 0.0
        
        if snapToLabels {
            for index in 0 ..< labels.count + 1 {
                let percentageAlongCircle = Double(index) / Double(labels.count - (fullCircle ? 0 : 1))
                let degreesToLbl = CGFloat(percentageAlongCircle) * maximumAngle
                if abs(fixedAngle - degreesToLbl) < minDist {
                    newAngle = degreesToLbl != 0 || !fullCircle ? maximumAngle - degreesToLbl : 0
                    minDist = abs(fixedAngle - degreesToLbl)
                }
            }
            currentValue = valueFrom(angle: newAngle)
        }
        
        if snapToMarkers {
            for index in 0 ..< markerCount + 1 {
                let percentageAlongCircle = Double(index) / Double(markerCount - (fullCircle ? 0 : 1))
                let degreesToMarker = CGFloat(percentageAlongCircle) * maximumAngle
                if abs(fixedAngle - degreesToMarker) < minDist {
                    newAngle = degreesToMarker != 0 || !fullCircle ? maximumAngle - degreesToMarker : 0
                    minDist = abs(fixedAngle - degreesToMarker)
                }
            }
            currentValue = valueFrom(angle: newAngle)
        }
        setNeedsDisplay()
    }
    
    func toCompass(_ cartesianRad: Double) -> Double {
        return cartesianRad + (Double.pi / 2)
    }
    
    func update() {
        setNeedsUpdateConstraints()
        setNeedsDisplay()
        setNeedsLayout()
    }
}

private struct ArcConfiguration {
    let ctx: CGContext
    let center: CGPoint
    let radius: CGFloat
    let lineWidth: CGFloat
}
