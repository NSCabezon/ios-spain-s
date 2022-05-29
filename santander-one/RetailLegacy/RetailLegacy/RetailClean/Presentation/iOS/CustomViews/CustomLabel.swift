import UIKit

class CustomLabel: UILabel {
    
    var padding = defaultPadding

    override func drawText(in rect: CGRect) {
//        super.drawText(in: UIEdgeInsetsInsetRect(bounds, padding))
        super.drawText(in: bounds.inset(by: padding))
    }
}
