import UIKit

class StylizerPGViewCells {
    
    static let shadowColor = UIColor.lisboaGray.cgColor
    static let shadowOpacity: Float = 1.0
    static let cellColor =  UIColor.uiWhite.cgColor
    static let cellColorSelected =  UIColor.sanGreyNew.cgColor
    static let shadowOffset = CGSize(width: 4, height: 4)
    static let shadowHeaderOffset = CGSize(width: 4, height: 0)
    static let shadowRadius: CGFloat = 0.0
    static let lineWidth = CGFloat(2.0)
    static let radius = CGFloat(6)
    
    private static func deleteOldLayers(view: UIView, names: Set<String>) {
        guard let layers = view.layer.sublayers else {
            return
        }
        for layer in layers {
            if let name = layer.name, names.contains(name) {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    class func restoreStyle(view: UIView) {
        deleteAllLayers(view: view)
    }
    
    class func applyMiddleViewCellStyle(view: UIView, selected: Bool = false) {
        deleteAllLayers(view: view)
        // Add rounded corners
        let background = CAShapeLayer()
        background.name = selected ? "midLayerSelected" : "midLayer"
        background.zPosition = -2
        background.frame = view.bounds
        background.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height + 4)).cgPath
        background.fillColor = selected ? cellColorSelected : cellColor
        
        // Add shadow
        let bounds = CGRect(x: 0, y: -radius, width: view.bounds.width, height: view.bounds.height + radius+10)
        background.shadowPath = UIBezierPath(rect: bounds).cgPath
        background.shadowColor = shadowColor
        background.shadowOpacity = shadowOpacity
        background.shadowOffset = shadowOffset
        background.shadowRadius = shadowRadius
        
        // Add borders
        background.strokeColor = UIColor.lisboaGray.cgColor
        background.lineWidth = lineWidth
        
        let removeTopBorder = CAShapeLayer()
        removeTopBorder.name = selected ? "midLayerSelected" : "midLayer"
        removeTopBorder.zPosition = -1
        removeTopBorder.frame = view.bounds
        removeTopBorder.path = UIBezierPath(rect: CGRect(x: (lineWidth / 2), y: -1, width: view.bounds.width - (lineWidth+1), height: 2+lineWidth)).cgPath
        removeTopBorder.fillColor = selected ? cellColorSelected : cellColor
        
        let removeBottomBorder = CAShapeLayer()
        removeBottomBorder.name = selected ? "midLayerSelected" : "midLayer"
        removeBottomBorder.zPosition = -1
        removeBottomBorder.frame = view.bounds
        removeBottomBorder.path = UIBezierPath(rect: CGRect(x: (lineWidth / 2)+1, y: view.bounds.height-(lineWidth*2), width: view.bounds.width - (lineWidth+1), height: 5+(lineWidth*2))).cgPath
        removeBottomBorder.fillColor = selected ? cellColorSelected : cellColor
        
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(CGRect(x: -2, y: 0, width: view.bounds.width+shadowOffset.width+2, height: view.bounds.height))
        path.addRect(CGRect(x: -2, y: 0, width: lineWidth+2, height: view.bounds.height+4))
        path.addRect(CGRect(x: view.bounds.width-2, y: view.bounds.height, width: shadowOffset.width+2, height: 4))
        
        maskLayer.backgroundColor = UIColor.uiBlack.cgColor
        maskLayer.path = path
        background.mask = maskLayer
        
        view.layer.addSublayer(removeTopBorder)
        view.layer.addSublayer(removeBottomBorder)
        view.layer.addSublayer(background)
    }
    
    class func applyBottomViewCellStyle(view: UIView, selected: Bool = false) {
        
        deleteAllLayers(view: view)
        
        let corners: UIRectCorner = [UIRectCorner.bottomRight, UIRectCorner.bottomLeft]
        view.backgroundColor = .clear
        
        // Add rounded corners
        let background = CAShapeLayer()
        background.name = selected ? "bottomLayerSelected" : "bottomLayer"
        background.zPosition = -2
        background.frame = view.bounds
        background.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        background.fillColor = selected ? cellColorSelected : cellColor
        
        // Add shadow
        let bounds = CGRect(x: 0, y: -radius, width: view.bounds.width, height: view.bounds.height + radius)
        background.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        background.shadowColor = shadowColor
        background.shadowOpacity = shadowOpacity
        background.shadowOffset = shadowOffset
        background.shadowRadius = shadowRadius
        
        // Add border
        background.strokeColor = UIColor.lisboaGray.cgColor
        background.lineWidth = lineWidth
        
        // Remove Top Border
        let removeTopBorder = CAShapeLayer()
        removeTopBorder.name = selected ? "bottomLayerSelected" : "bottomLayer"
        removeTopBorder.zPosition = -1
        removeTopBorder.frame = view.bounds
        removeTopBorder.path = UIBezierPath(rect: CGRect(x: lineWidth / 2, y: 0, width: view.bounds.width - (lineWidth), height: lineWidth)).cgPath
        removeTopBorder.fillColor = selected ? cellColorSelected : cellColor
        
        // Remove Top and Bottom
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(CGRect(x: -view.bounds.width / 2, y: 0, width: view.bounds.width * 2, height: view.bounds.height * 2))
        maskLayer.backgroundColor = UIColor.uiBlack.cgColor
        maskLayer.path = path
        background.mask = maskLayer
        
        view.layer.addSublayer(removeTopBorder)
        view.layer.addSublayer(background)
    }
    
    class func applyAllCornersViewCellStyle(view: UIView, selected: Bool = false) {
        deleteAllLayers(view: view)
        
        let corners: UIRectCorner = .allCorners
        view.backgroundColor = .clear
        
        // Add rounded corners
        let background = CAShapeLayer()
        background.name = selected ? "bottomLayerSelected" : "bottomLayer"
        background.zPosition = -2
        background.frame = view.bounds
        background.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        background.fillColor = selected ? cellColorSelected : cellColor
        
        // Add shadow
        let bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        background.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        background.shadowColor = shadowColor
        background.shadowOpacity = shadowOpacity
        background.shadowOffset = shadowOffset
        background.shadowRadius = shadowRadius
        
        // Add border
        background.strokeColor = UIColor.lisboaGray.cgColor
        background.lineWidth = lineWidth
                
        // Remove Top and Bottom
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(CGRect(x: -view.bounds.width / 2, y: 0, width: view.bounds.width * 2, height: view.bounds.height * 2))
        maskLayer.backgroundColor = UIColor.uiBlack.cgColor
        maskLayer.path = path
        background.mask = maskLayer
        
        view.layer.addSublayer(background)
    }
    
    class func applyHeaderOpenViewCellStyle(view: UIView, selected: Bool = false) {        
        deleteAllLayers(view: view)
        let corners: UIRectCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]
        
        let extraCellSpace: CGFloat = lineWidth * 2.0 + 1.0
        
        // Add rounded corners
        let background = CAShapeLayer()
        background.name = "openLayer"
        background.zPosition = -2
        background.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height + extraCellSpace)
        background.path = UIBezierPath(roundedRect: background.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        background.fillColor = selected ? cellColorSelected : cellColor
        
        // Add first shadow
        var bounds = CGRect(x: 0, y: radius, width: view.bounds.width, height: view.bounds.height+radius)
        background.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        background.shadowColor = shadowColor
        background.shadowOpacity = shadowOpacity
        background.shadowOffset = shadowHeaderOffset
        background.shadowRadius = shadowRadius
        
        // Remove Bottom Shadow
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        maskLayer.zPosition = 0
        path.addRect(CGRect(x: -lineWidth, y: -radius, width: view.bounds.width + lineWidth, height: view.bounds.height + radius + extraCellSpace))
        path.addRect(CGRect(x: view.bounds.width, y: -radius, width: radius, height: view.bounds.height+radius + 4.0))
        maskLayer.backgroundColor = UIColor.orange.cgColor
        maskLayer.path = path
        background.mask = maskLayer
        
        let backgroundGrey = CAShapeLayer()
        backgroundGrey.name = "openLayer"
        backgroundGrey.zPosition = -4
        bounds = CGRect(x: shadowHeaderOffset.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        backgroundGrey.frame = bounds
        backgroundGrey.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        backgroundGrey.fillColor =  UIColor.uiBackground.cgColor
        
        // Add border
        background.strokeColor = UIColor.lisboaGray.cgColor
        background.lineWidth = lineWidth
        
        // Remove Botom Border
        
        let removeBottomBorder = CAShapeLayer()
        removeBottomBorder.name = "openLayer"
        removeBottomBorder.zPosition = -1
        removeBottomBorder.frame = view.bounds
        removeBottomBorder.path = UIBezierPath(rect: CGRect(x: lineWidth / 2, y: view.bounds.height-(lineWidth*2), width: view.bounds.width - (lineWidth), height: extraCellSpace + padding())).cgPath
        removeBottomBorder.fillColor = selected ? cellColorSelected : cellColor
        
        view.layer.addSublayer(removeBottomBorder)
        view.layer.addSublayer(background)
        view.layer.addSublayer(backgroundGrey)
        
    }
    
    class func applyHeaderCloseViewCellStyle(view: UIView) {
        
        deleteAllLayers(view: view)
        
        let corners: UIRectCorner = [UIRectCorner.topLeft, UIRectCorner.topRight, UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
        
        // Add rounded corners
        let background = CAShapeLayer()
        background.name = "closeLayer"
        background.zPosition = -2
        background.frame = view.bounds
        background.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        background.fillColor = cellColor
        
        // Add first shadow
        background.shadowPath = background.path
        background.shadowColor = shadowColor
        background.shadowOpacity = shadowOpacity
        background.shadowOffset = shadowOffset
        background.shadowRadius = shadowRadius
        
        // Add border
        background.strokeColor = UIColor.lisboaGray.cgColor
        background.lineWidth = lineWidth
        
        view.layer.addSublayer(background)
    }
    
    fileprivate static func deleteAllLayers(view: UIView) {
        deleteOldLayers(view: view, names: ["openLayer", "closeLayer", "midLayer", "midLayerSelected", "bottomLayer", "bottomLayerSelected"])
    }
    
    class func padding() -> CGFloat {
        return 0.0
    }
}

class StylizerNonCollapsibleViewCells: StylizerPGViewCells {
    
    override class func padding() -> CGFloat {
        return 4.0
    }
        
}
