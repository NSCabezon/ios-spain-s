import UIKit

protocol ViewProxy: class {
    var sourceView: UIView { get }
}

extension UIView: ViewProxy {
    var sourceView: UIView {
        return self
    }
}

extension UIView {
    
    func clean() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func drawRoundedAndShadowed() {
        drawShadow(offset: 3.0, color: UIColor.uiBlack.withAlphaComponent(0.05))
        drawBorder(cornerRadius: 5.0, color: .lisboaGray)
    }
    
    func drawRoundedAndShadowedNew(radius: CGFloat = 5.0, borderColor: UIColor = .mediumSky) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.lightSanGrey.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 3.0
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        drawBorder(cornerRadius: radius, color: borderColor)
    }
    
    func drawShadow(offset: CGSize, opaticity: Float = 1.0, color: UIColor, radius: CGFloat = 0.0) {
        layer.shadowOffset = offset
        layer.shadowOpacity = opaticity
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
    }
    
    func drawShadow(offset: CGFloat = 3.0, opaticity: Float = 1.0, color: UIColor, radius: CGFloat = 0.0) {
        layer.shadowOffset = CGSize(width: offset, height: offset)
        layer.shadowOpacity = opaticity
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
    }
    
    func drawBorder(cornerRadius: CGFloat = 5.0, color: UIColor, width: CGFloat = 1.0) {
        layer.cornerRadius = cornerRadius
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func capture() -> UIImage? {
        return layer.photo
    }
    
    func embedInAView(withPadding padding: CGFloat) -> UIView {
        return embedInAView(withInsets: paddingToInsets(padding: padding))
    }
    
    func embedInAView(withInsets insets: UIEdgeInsets = UIEdgeInsets()) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        embedInto(container: container, insets: insets)
        
        return superview!
    }
    
    func embedInto(container: UIView, padding: CGFloat) {
        embedInto(container: container, insets: paddingToInsets(padding: padding))
    }
    
    func embedInto(container: UIView, insets: UIEdgeInsets = UIEdgeInsets()) {
        let builder = NSLayoutConstraint.Builder()
            .add(topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top))
            .add(leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left))
            .add(trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: insets.right))
            .add(bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: insets.bottom))
        
        container.addSubview(self)
        
        builder.activate()
    }
    
    private func paddingToInsets(padding: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding)
    }
    
    public func addShadow(offset: CGSize, radius: CGFloat, color: UIColor, opacity: Float, cornerRadius: CGFloat? = nil) {
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
        if let r = cornerRadius {
            self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: r).cgPath
        }
    }
    
    public func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    
    public func addBorderTopWithPadding(size: CGFloat, color: UIColor, padding: CGFloat) {
        addBorderUtility(x: padding, y: 0, width: frame.width - padding*2, height: size, color: color)
    }
    
    public func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    
    public func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    
    public func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    
    func getAbsolutePosition() -> CGRect {
        let currentRect = self.frame
        if let superview = self.superview {
            var superViewRect: CGRect = CGRect.zero
            //WORKAROUND TO AVOID COLLECTIONVIEW CONTENT SIZE (CELL FRAME ORIGIN WOULD BE OUT OF SCREEN BOUNDS)
            
            //TODO: REVISAR
            if superview.superview is UICollectionView {
                superViewRect = superview.superview!.getAbsolutePosition()
            } else {
                superViewRect = superview.getAbsolutePosition()
            }
            return CGRect(x: currentRect.origin.x + superViewRect.origin.x, y: currentRect.origin.y + superViewRect.origin.y, width: currentRect.width, height: currentRect.height)
        } else {
            return currentRect
        }
    }
    
    func findView<T>(prot: T.Type) -> [T] {
        var output = [T]()
        if let valid = self as? T {
            output.append(valid)
        }
        
        if subviews.count > 0 {
            for subV in subviews {
                let validSubviews = subV.findView(prot: prot)
                output.append(contentsOf: validSubviews)
            }
        }
        
        return output
    }
    
    fileprivate func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
}

// MARK: UIKit Private Types Detection
extension UIView {
    static func isTextRangeView(_ view: UIView) -> Bool {
        // UITextRangeView is inside of a hierarchy of views consisting in:
        //      UITextSelectionView
        //      _UITextFieldContentView
        //      UIFieldEditor
        //      UITextField
        return UIView.isAnySuperview(sameTypeAs: UITextField.self, maxDepth: 4, in: view)
    }
    
    static func isAnySuperview<T: UIView>(sameTypeAs otherView: T.Type, maxDepth: Int = 1, in view: UIView) -> Bool {
        guard maxDepth > 0, let superview = view.superview else {
            return false
        }
        if superview is T {
            return true
        }
        return isAnySuperview(sameTypeAs: otherView, maxDepth: maxDepth - 1, in: superview)
    }
}

extension NSLayoutConstraint {
    class Builder {
        private var constraints: [NSLayoutConstraint]
        
        init() {
            constraints = []
        }
        
        func add(_ constraint: NSLayoutConstraint) -> Self {
            constraints += [constraint]
            return self
        }
        
        func activate() {
            NSLayoutConstraint.activate(constraints)
            constraints = []
        }
        
        static func += (builder: Builder, constraint: NSLayoutConstraint) {
            _ = builder.add(constraint)
        }
    }
}

extension CALayer {
    var photo: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
