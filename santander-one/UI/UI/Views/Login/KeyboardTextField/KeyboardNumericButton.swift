import UIKit

open class KeyboardNumericButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStyle()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setupForLayout()
    }
    
    override public var isHighlighted: Bool {
        didSet {
            backgroundColor = self.isHighlighted ? UIColor.Legacy.keyboardPress.withAlphaComponent(0.2): UIColor.Legacy.keyboardWhite
        }
    }
    
    private func setupStyle() {
        setTitleColor(UIColor.black, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 23)
        backgroundColor = UIColor.Legacy.keyboardWhite
    }
    
    private func setupForLayout() {
        drawShadow(offset: 1, opaticity: 0.36, color: UIColor.Legacy.keyboardPress, radius: 1)
        layer.cornerRadius = 5
    }
}
