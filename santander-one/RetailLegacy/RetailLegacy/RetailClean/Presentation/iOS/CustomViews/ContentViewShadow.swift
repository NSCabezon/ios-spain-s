//

import UIKit

class ContentViewShadow: UIView {
    
     func setup() {
        addShadow(offset: CGSize(width: 3, height: 3),
                           radius: 3.0,
                           color: .uiBlack,
                           opacity: 0.17)
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lisboaGray.cgColor
        layer.cornerRadius = 5.0
    }
}
