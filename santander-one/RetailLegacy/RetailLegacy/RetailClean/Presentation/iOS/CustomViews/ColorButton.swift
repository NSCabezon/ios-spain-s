//

import UIKit

class ColorButton: ResponsiveButton {
    
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
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        clipsToBounds = true
    }
}
