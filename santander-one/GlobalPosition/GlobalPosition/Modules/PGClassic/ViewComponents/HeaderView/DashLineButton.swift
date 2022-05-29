import UI
import CoreFoundationLib

enum DashLineStyle {
    case classic
    case smart
}

final class DashLineButton: DesignableView {
    
    @IBOutlet weak var upArrowImageView: UIImageView!
    @IBOutlet weak var downArrowImageView: UIImageView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var dotsImageView: UIImageView!
    @IBOutlet weak var tapView: UIView!
    
    @IBOutlet private  weak var labelCenterConstraint: NSLayoutConstraint!
    
    private var dotsColor = UIColor.lisboaGray
    var editButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(style: DashLineStyle) {
        super.init(frame: CGRect.zero)
        
        if style == .classic {
            configureClassicStyle()
        } else {
            configureSmartStyle()
        }
        
        configureLabel()
        configureDots()
        setAccessibilityIdentifiers()
    }
    
    public func moveLabelCenterPosition(_ position: CGFloat) {
        labelCenterConstraint.constant = -position
    }
}

private extension DashLineButton {
    
    func configureSmartStyle() {
        configureImages("icnTriangleUp", downArrowImage: "icnTriangledown")
        buttonLabel.font = UIFont.santander(family: .text, type: .bold, size: 12)
        buttonLabel.textColor = .white
        upArrowImageView.tintColor = .white
        downArrowImageView.tintColor = .white
        dotsColor = .white
    }
    
    func configureClassicStyle() {
        configureImages("icnTriangleUp", downArrowImage: "icnTriangledown")
        buttonLabel.font = UIFont.santander(family: .text, type: .bold, size: 12)
        buttonLabel.textColor = .darkTorquoise
        upArrowImageView.tintColor = .darkTorquoise
        downArrowImageView.tintColor = .darkTorquoise
        dotsColor = .mediumSanGray
    }
    
    func configureLabel() {
        buttonLabel.text = localized("pg_label_objective")
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(executeAction)))
    }
    
    func configureImages(_ upArrowImage: String, downArrowImage: String) {
        upArrowImageView.image = Assets.image(named: upArrowImage)?.withRenderingMode(.alwaysTemplate)
        downArrowImageView.image = Assets.image(named: downArrowImage)?.withRenderingMode(.alwaysTemplate)
    }
    
    @objc func executeAction() {
        self.editButtonAction?()
    }
    
    func configureDots() {
        guard !dotsImageView.bounds.isEmpty else { return }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 2, y: dotsImageView.bounds.height / 2))
        path.addLine(to: CGPoint(x: dotsImageView.bounds.width, y: dotsImageView.bounds.height / 2))
        path.lineWidth = dotsImageView.bounds.height

        let dashes: [CGFloat] = [0.01, path.lineWidth * 3]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.round

        UIGraphicsBeginImageContextWithOptions(CGSize(width: dotsImageView.bounds.width,
                                                      height: dotsImageView.bounds.height), false, 2)

        UIColor.clear.setFill()
        UIGraphicsGetCurrentContext()!.fill(.infinite)
        dotsColor.setStroke()
        path.stroke()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        dotsImageView.image = image
        UIGraphicsEndImageContext()
    }
    
    func setAccessibilityIdentifiers() {
        upArrowImageView.accessibilityIdentifier = "upArrow"
        downArrowImageView.accessibilityIdentifier = "downArrow"
        buttonLabel.accessibilityIdentifier = "objetiveButtonLabel"
        dotsImageView.accessibilityIdentifier = "dotsImageView"
        tapView.accessibilityIdentifier = "objetiveTapView"
    }
}
