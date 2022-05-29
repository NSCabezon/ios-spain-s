import UIKit
import UI
import CoreFoundationLib

struct DigitalProfileItemTooltipViewConfiguration {
    let percentages: String
    let name: LocalizedStylableText
    let description: LocalizedStylableText
    let image: UIImage?
    let percentage: CGFloat
    let percentagesLabelAccessibilityID: String
    let nameLabelAccessibilityID: String
    let descriptionLabelAccessibilityID: String
}

class DigitalProfileItemTooltipView: XibView {
    @IBOutlet weak var percentagesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var medalImageview: UIImageView!
    @IBOutlet weak var internalCircleView: UIView!
    @IBOutlet weak var externalCircleView: UIView!
    private var circleLayer: CAShapeLayer?
    private var circleShadowLayer: CAShapeLayer?

    convenience init(configuration: DigitalProfileItemTooltipViewConfiguration) {
        self.init(frame: CGRect.zero)
        self.setupView(configuration: configuration)
    }
}

private extension DigitalProfileItemTooltipView {
    func setupView(configuration: DigitalProfileItemTooltipViewConfiguration) {
        self.internalCircleView.layer.cornerRadius = self.internalCircleView.bounds.height / 2.0
        self.internalCircleView.layer.borderColor = UIColor.white.cgColor
        self.internalCircleView.layer.borderWidth = 5.5
        self.internalCircleView.backgroundColor = UIColor.bg
        self.internalCircleView.clipsToBounds = true
        self.externalCircleView.backgroundColor = UIColor.white
        self.percentagesLabel.font = UIFont.santander(family: FontFamily.headline, type: FontType.bold, size: 12)
        self.percentagesLabel.textColor = UIColor.darkTorquoise
        self.nameLabel.textColor = UIColor.lisboaGray
        self.descriptionLabel.textColor = UIColor.lisboaGray
        self.percentagesLabel.text = configuration.percentages
        self.nameLabel.configureText(withLocalizedString: configuration.name,
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: FontFamily.headline, type: FontType.bold, size: 15)))
        self.descriptionLabel.configureText(withLocalizedString: configuration.description,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: FontFamily.text, type: FontType.light, size: 12)))
        self.medalImageview.image = configuration.image
        self.drawCircleShadow(configuration.percentage)
        self.medalImageview.isAccessibilityElement = true
        self.percentagesLabel.accessibilityIdentifier = configuration.percentagesLabelAccessibilityID
        self.nameLabel.accessibilityIdentifier = configuration.nameLabelAccessibilityID
        self.descriptionLabel.accessibilityIdentifier = configuration.descriptionLabelAccessibilityID
    }
    
    func drawCircleShadow(_ percentage: CGFloat) {
        self.circleLayer?.removeFromSuperlayer()
        let start: CGFloat = 3.0 * .pi / 2.0
        let end = start + (percentage * 2.0 * .pi / 100.0)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: externalCircleView.frame.size.width / 2.0, y: externalCircleView.frame.size.height / 2.0),
                                      radius: (externalCircleView.frame.size.width + 11) / 2.0,
                                      startAngle: start,
                                      endAngle: end,
                                      clockwise: true)
        
        let circleLayer = CAShapeLayer()
        self.circleLayer = circleLayer
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.darkTorquoise.cgColor
        circleLayer.lineWidth = 5.5
        circleLayer.strokeEnd = 1.0
        addCircleShadow()
        externalCircleView.layer.addSublayer(circleLayer)
    }
    
    func addCircleShadow() {
        self.circleShadowLayer?.removeFromSuperlayer()
        let circleShadowLayer = CAShapeLayer()
        self.circleShadowLayer = circleShadowLayer
        circleShadowLayer.path = UIBezierPath(arcCenter: CGPoint(x: externalCircleView.frame.size.width / 2.0, y: externalCircleView.frame.size.height / 2.0),
                                              radius: (externalCircleView.frame.size.width + 11) / 2.0,
                                              startAngle: 0.0,
                                              endAngle: 2 * .pi,
                                              clockwise: true).cgPath
        circleShadowLayer.fillColor = UIColor.clear.cgColor
        circleShadowLayer.strokeColor = UIColor.lightSanGray.cgColor
        circleShadowLayer.lineWidth = 5.5
        circleShadowLayer.strokeEnd = 1.0
        externalCircleView.layer.addSublayer(circleShadowLayer)
    }
}
