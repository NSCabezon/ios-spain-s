//

import UIKit

struct GraphPfmModelView {
    let name: String
    let value: Double
    let amount: String
}

class GraphPfmView: UIView {
    
    @IBOutlet weak var lefthGraphConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightGraphConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightLeyendConstraint: NSLayoutConstraint!
    @IBOutlet weak var lefthLeyendConstraint: NSLayoutConstraint!
    typealias AnimationClosure = () -> Void
    typealias CompletionClosure = ( () -> Void )?
    private var maxValue: Double?
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var leyendView: UIStackView!
    @IBOutlet weak var separator: UIView!
    private var lineLayers = [CAShapeLayer]()
    var inclinationValue: CGFloat = 3
    var spacing: CGFloat = 2
    var withInclination = true
    var withAmountValue = false
    var showAnimation: Bool = true
    private var paintWidth: CGFloat?
    var lateralSpacing: CGFloat = 0 {
        didSet {
            lefthGraphConstraint.constant = lateralSpacing
            rightGraphConstraint.constant = lateralSpacing
            rightLeyendConstraint.constant = lateralSpacing
            lefthLeyendConstraint.constant = lateralSpacing
        }
    }
    var showSeparator = false {
        didSet {
            separator.isHidden = !showSeparator
        }
    }
    var gestureRecognizer: UIGestureRecognizer! {
        didSet {
            gestureRecognizer.isEnabled = false
            addGestureRecognizer(gestureRecognizer)
        }
    }
    var months: [GraphPfmModelView] = [] {
        didSet {
            var maxValue: Double?
            for month in months where month.value > maxValue ?? -Double.greatestFiniteMagnitude {
                maxValue = month.value
            }
            self.maxValue = maxValue
            paintWidth = nil
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if rect.width != paintWidth {
            drawElements()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    // MARK: - Private methods
    
    private func drawElements() {
        if months.count > 0 {
            paintWidth = frame.size.width
            clearView()
            createRows()
        }
    }
    
    private func didLoad() {
        if let header = Bundle.module?.loadNibNamed("GraphPfmView", owner: self, options: nil)?.first as? UIView {
            header.frame = bounds
            header.embedInto(container: self)
        }
        prepareView()
    }
    
    private func prepareView() {
        backgroundColor = UIColor.clear
        separator.isHidden = !showSeparator
    }
    
    private func clearView() {
        removeLabels()
        removelayers()
    }
    
    private func removeLabels() {
        leyendView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func removelayers() {
        lineLayers.forEach { $0.removeFromSuperlayer() }
        lineLayers.removeAll()
    }
    
    private func animate(line: CAShapeLayer, month: GraphPfmModelView) {
        let animations = {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.5
            animation.fromValue = 0
            animation.toValue = self.endForCurrentValue(value: month.value)
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = false
            line.animation(forKey: "strokeEnd")
            line.add(animation, forKey: "strokeEnd")
        }
        startTransaction(animated: true, updates: animations, needsDisplay: true)
    }
    
    private func createRows() {
        let rows = CGFloat(months.count)
        let spaceWidth: CGFloat = graphView.frame.size.width / rows
        let lineWidth = spaceWidth
        for i in 0..<months.count {
            let month = months[i]
            let index = CGFloat(i)
            let originPoint = CGPoint(x: graphView.frame.size.width * (index / rows), y: graphView.frame.size.height)
            let isLastMonth = i == months.count - 1
            createMonthLabel(month: month, isLastMonth: isLastMonth)
            createRow(month: month, origin: originPoint, lineWidth: lineWidth, isLastMonth: isLastMonth)
        }
    }
    
    private func createMonthLabel(month: GraphPfmModelView, isLastMonth: Bool) {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = month.name
        label.textColor = isLastMonth ? .sanRed : .sanGreyDark
        let size: CGFloat = withAmountValue ? 13: 11
        label.font = isLastMonth ? .latoSemibold(size: size) : .latoLight(size: size)
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        if withAmountValue {
            stackView.spacing = 5
            stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
            stackView.isLayoutMarginsRelativeArrangement = true
        }
        stackView.addArrangedSubview(label)
        if withAmountValue {
            createAmountLabel(month: month, isLastMonth: isLastMonth, stackView: stackView)
        }
        leyendView.addArrangedSubview(stackView)
        
    }
    
    private func createAmountLabel(month: GraphPfmModelView, isLastMonth: Bool, stackView: UIStackView) {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = month.amount
        label.textColor = isLastMonth ? .sanRed : .sanGreyDark
        label.font = .latoBold(size: 20)
        stackView.addArrangedSubview(label)
        label.scaleDecimals()
    }
    
    private func createRow (month: GraphPfmModelView, origin: CGPoint, lineWidth: CGFloat, isLastMonth: Bool) {
        let separatorPath = UIBezierPath()
        let width = lineWidth - spacing
        let initialX = origin.x + spacing
        let line = CAShapeLayer()
        let endPoint: CGFloat = origin.y - (origin.y * self.endForCurrentValue(value: month.value))
        separatorPath.move(to: CGPoint(x: initialX, y: origin.y))
        separatorPath.addLine(to: CGPoint(x: initialX + width, y: origin.y))
        if withInclination {
            let inclination = endPoint + inclinationValue
            if inclination > origin.y {
                separatorPath.addLine(to: CGPoint(x: initialX + width, y: origin.y - inclinationValue ))
                separatorPath.addLine(to: CGPoint(x: initialX, y: origin.y))
            } else {
                separatorPath.addLine(to: CGPoint(x: initialX + width, y: endPoint))
                separatorPath.addLine(to: CGPoint(x: initialX, y: inclination))
            }
        } else {
            separatorPath.addLine(to: CGPoint(x: initialX + width, y: endPoint))
            separatorPath.addLine(to: CGPoint(x: initialX, y: endPoint))
        }
        separatorPath.close()
        line.fillColor = isLastMonth ? UIColor.sanRed.cgColor : UIColor.lisboaGray.cgColor
        line.strokeEnd = 0
        line.lineWidth = width
//        line.lineCap = kCALineJoinBevel
        line.lineCap = .butt
        lineLayers.append(line)
        graphView.layer.addSublayer(line)
        if showAnimation {
            let initialPath = UIBezierPath()
            initialPath.move(to: CGPoint(x: initialX, y: origin.y))
            initialPath.addLine(to: CGPoint(x: initialX + width, y: origin.y))
            let inclination = origin.y - inclinationValue > endPoint ? origin.y - inclinationValue: endPoint
            initialPath.addLine(to: CGPoint(x: initialX + width, y: inclination))
            initialPath.addLine(to: CGPoint(x: initialX, y: inclination))
            initialPath.close()
            line.path = initialPath.cgPath
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = 0.5
            animation.fromValue = initialPath.cgPath
            animation.toValue = separatorPath.cgPath
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            line.add(animation, forKey: animation.keyPath)
        } else {
            line.path = separatorPath.cgPath
        }
    }
    
    private func endForCurrentValue(value: Double) -> CGFloat {
        guard let maxValue = maxValue  else {
            return 0
        }
        let result = value / maxValue
        if result.isNaN || result.isInfinite {
            return 0
        } else {
            return CGFloat(min(result, 1))
        }
    }
    
    private func startTransaction(animated: Bool, updates: AnimationClosure, needsDisplay: Bool = false, completion: CompletionClosure = nil) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        CATransaction.setCompletionBlock(completion)
        updates()
        if needsDisplay && !animated { setNeedsDisplay() }
        CATransaction.commit()
    }
}
