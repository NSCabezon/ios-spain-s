import UIKit

class ResponsiveButton: UIButton {
    var onTouchAction: ((_ sender: ResponsiveButton) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
    func build() {
        addTarget(self, action: #selector(didTouch(sender:)), for: .touchUpInside)
    }
    
    @objc
    func didTouch(sender: ResponsiveButton) {
        onTouchAction?(self)
    }
}
