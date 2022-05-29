import UIKit

private typealias Style = (border: UIColor, background: UIColor)

@IBDesignable
class WidgetWhiteButton: UIButton {
    private let enabledStyle = Style(border: .sanRed, background: .clear)
    private let disabledStyle = Style(border: .uiBlack, background: .sanGrey)
    
    override var isEnabled: Bool {
        didSet {
            colourForState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configureDraw()
    }
    
    func configureDraw () {
        layer.cornerRadius = frame.height / 2.0
    }
    
    func configure() {
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        clipsToBounds = true
        tintColor = .sanRed
        setTitleColor(.sanRed, for: .normal)
        setTitleColor(.uiBlack, for: .disabled)
        layer.borderWidth = 1.0
        layer.masksToBounds = false
        isEnabled = true
    }
    
    internal func colourForState() {
        let style = isEnabled ? enabledStyle : disabledStyle
        layer.borderColor = style.border.cgColor
        backgroundColor = style.background
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureDraw()
    }
}
