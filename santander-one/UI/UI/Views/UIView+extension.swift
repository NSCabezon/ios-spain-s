//
//  UIView+extension.swift
//  UI
//
//  Created by alvola on 26/11/2019.
//

import UIKit
import CoreFoundationLib

public enum VerticalShadowLocation: String {
    case bottom
    case top
}

extension UIView {
    
    public static func isTextRangeView(_ view: UIView) -> Bool {
        return UIView.isAnySuperview(sameTypeAs: UITextField.self, maxDepth: 4, in: view)
    }
    
    public static func isAnySuperview<T: UIView>(sameTypeAs otherView: T.Type, maxDepth: Int = 1, in view: UIView) -> Bool {
        guard maxDepth > 0, let superview = view.superview else {
            return false
        }
        if superview is T {
            return true
        }
        return isAnySuperview(sameTypeAs: otherView, maxDepth: maxDepth - 1, in: superview)
    }
    
    public func getAllSubviews<T: UIView>() -> [T] {
        return UIView.getAllSubviews(from: self) as [T]
    }
    
    public func get<T: UIView>(all type: T.Type) -> [T] {
        return UIView.getAllSubviews(from: self) as [T]
    }
    
    public func get(all types: [UIView.Type]) -> [UIView] {
        return UIView.getAllSubviews(from: self, types: types)
    }
    
    class func getAllSubviews<T: UIView>(from parenView: UIView) -> [T] {
        return parenView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T, view.isHidden == false { result.append(view) }
            return result
        }
    }
    
    class func getAllSubviews(from parenView: UIView, types: [UIView.Type]) -> [UIView] {
        return parenView.subviews.flatMap { subView -> [UIView] in
            var result = getAllSubviews(from: subView) as [UIView]
            for type in types where subView.classForCoder == type && subView.isHidden == false {
                result.append(subView)
                return result
            }
            return result
        }
    }
    
    @available(*, deprecated, message: "Use applyGradientBackground(colors:)")
    public func applyGradientBackground(colorStart: UIColor, colorFinish: UIColor) {
        self.applyGradientBackground(
            colors: [colorStart, colorFinish],
            locations: nil,
            startPoint: CGPoint(x: 0.5, y: 0.2),
            endPoint: CGPoint(x: 0.5, y: 1.0)
        )
    }
    
    @discardableResult
    public func applyGradientBackground(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.5, y: 0.2), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) -> CALayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.colors = colors.map({ $0.cgColor })
        gradientLayer.locations = locations
        self.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
    
    public func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: UIColor, fillColor: UIColor? = nil, lineWidth: CGFloat? = nil) {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineDashPattern = pattern
        borderLayer.lineWidth = lineWidth ?? 1.0
        borderLayer.frame = bounds
        borderLayer.fillColor = fillColor?.cgColor
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        borderLayer.path = path.cgPath
        layer.addSublayer(borderLayer)
    }
    
    public func fullFit(topMargin: CGFloat = 0, bottomMargin: CGFloat = 0, leftMargin: CGFloat = 0, rightMargin: CGFloat = 0) {
        guard let container = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: container.leftAnchor, constant: leftMargin),
            self.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -rightMargin),
            self.topAnchor.constraint(equalTo: container.topAnchor, constant: topMargin),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -bottomMargin)
        ])
    }
    
    public func embedIntoView(topMargin: CGFloat = 0, bottomMargin: CGFloat = 0, leftMargin: CGFloat = 0, rightMargin: CGFloat = 0) -> UIView {
        let container = UIView()
        container.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: container.leftAnchor, constant: leftMargin),
            self.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -rightMargin),
            self.topAnchor.constraint(equalTo: container.topAnchor, constant: topMargin),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -bottomMargin)
        ])
        return container
    }
    
    public func centerWithSize(_ size: CGSize) {
        guard let container = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            self.heightAnchor.constraint(equalToConstant: size.height),
            self.widthAnchor.constraint(equalToConstant: size.width)
        ])
    }
    
    public func findViewController() -> UIViewController? {
        if let controller = self.next as? UIViewController {
            return controller
        } else if let subview = self.next as? UIView {
            return subview.findViewController()
        } else {
            return nil
        }
    }
    
    public func removeShadow() {
        self.layer.masksToBounds = true
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.0
        self.layer.shadowRadius = 0.0
    }
    
    public func addShadow(location: VerticalShadowLocation,
                          color: UIColor = .black,
                          opacity: Float = 0.5,
                          radius: CGFloat = 5.0,
                          height: CGFloat = 10.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: height), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -height), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    public func fitBelowView(_ view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let container = self.superview else { return }
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            self.topAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    public func fitOnTopWithHeight(_ heidht: CGFloat, andTopSpace: CGFloat) {
        guard let container = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: heidht),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor, constant: andTopSpace)
        ])
    }
    
    public func fitOnBottomWithHeight(_ heidht: CGFloat, andBottomSpace: CGFloat) {
        guard let container = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: heidht),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        if #available(iOS 11.0, *) {
            self.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: andBottomSpace).isActive = true
        } else {
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: andBottomSpace).isActive = true
        }
    }
    
    /// This function allows to perform a completion within a view, preventing multiple executions.
    /// It is designed for being used on places related to UI actions, i.e. button actions, didSelectRow...
    public func blockingAction(restoreInteractionOn seconds: Double = 1, completion: () -> Void) {
        guard isUserInteractionEnabled else { return }
        isUserInteractionEnabled = false
        completion()
        Async.after(seconds: seconds) { [weak self] in
            self?.isUserInteractionEnabled = true
        }
    }
    
    public class func flipView(viewToShow: UIView,
                               viewToHide: UIView,
                               duration: TimeInterval? = 0.4,
                               flipBackIn: TimeInterval? = 2.0, completion: (() -> Void)? = nil) {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        guard let duration = duration else { return }
        UIView.transition(from: viewToHide,
                          to: viewToShow,
                          duration: duration,
                          options: transitionOptions) { (_) in
                            viewToHide.isHidden = true
                            viewToShow.isHidden = false
                            guard let flipbackDuration = flipBackIn else { completion?(); return }
                            Async.after(seconds: flipbackDuration) {
                                UIView.transition(from: viewToShow,
                                                  to: viewToHide,
                                                  duration: duration,
                                                  options: transitionOptions) { (_) in
                                                    viewToHide.isHidden = false
                                                    viewToShow.isHidden = true
                                                    completion?()
                                }
                            }
        }
    }
}

extension UIView {
    public func drawRoundedAndShadowedNew(radius: CGFloat = 5.0,
                                          borderColor: UIColor = .mediumSkyGray,
                                          widthOffSet: CGFloat = 0.0,
                                          heightOffSet: CGFloat = 3.0) {
        layer.shadowOffset = CGSize(width: widthOffSet, height: heightOffSet)
        layer.shadowOpacity = 1.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        layer.shadowRadius = 0.0
        drawBorder(cornerRadius: radius, color: borderColor)
    }
    
    public func drawRoundedBorderAndShadow(with shadowConfiguration: ShadowConfiguration,
                                           cornerRadius: CGFloat,
                                           borderColor: UIColor,
                                           borderWith: CGFloat) {
        layer.shadowOffset = CGSize(width: shadowConfiguration.widthOffset,
                                    height: shadowConfiguration.heightOffset)
        layer.shadowOpacity = shadowConfiguration.opacity
        layer.shadowColor = shadowConfiguration.color.cgColor
        layer.shadowRadius = shadowConfiguration.radius
        drawBorder(cornerRadius: cornerRadius, color: borderColor, width: borderWith)
    }
    
    public func drawShadow(offset: CGFloat = 3.0,
                           opaticity: Float = 1.0,
                           color: UIColor,
                           radius: CGFloat = 0.0) {
        layer.shadowOffset = CGSize(width: offset, height: offset)
        layer.shadowOpacity = opaticity
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
    }
    
    public func drawBorder(cornerRadius: CGFloat = 5.0,
                           color: UIColor,
                           width: CGFloat = 1.0) {
        layer.cornerRadius = cornerRadius
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    public func drawShadow(offset: (x: Int, y: Int),
                           opacity: Float = 1.0,
                           color: UIColor,
                           radius: CGFloat = 0.0) {
        self.layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
    }

    @discardableResult
    public func roundCorners(corners: UIRectCorner,
                             radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        return mask
    }
    
    public func dotted(with dashPattern: [NSNumber]?, color: CGColor) {
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = color
        caShapeLayer.lineWidth = self.frame.height
        caShapeLayer.lineDashPattern = dashPattern
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
    
    public func anySuperViewIsHidden() -> Bool {
        guard let superview = self.superview else { return isHidden }
        guard superview.isHidden == false else { return superview.isHidden }
        return superview.anySuperViewIsHidden()
    }
    
    public func allSubViewsOf<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }
            let subviews = view.subviews
            guard subviews.count > 0 else { return }
            subviews.forEach { getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
    
    public func borders(for edges: [UIRectEdge], width: CGFloat = 1, color: UIColor = .black) {
        
        if edges.contains(.all) {
            layer.borderWidth = width
            layer.borderColor = color.cgColor
        } else {
            let allSpecificBorders: [UIRectEdge] = [.top, .bottom, .left, .right]
            for edge in allSpecificBorders {
                if let view = viewWithTag(Int(edge.rawValue)) {
                    view.removeFromSuperview()
                }
                if edges.contains(edge) {
                    let view = UIView()
                    view.tag = Int(edge.rawValue)
                    view.backgroundColor = color
                    view.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(view)
                    
                    var horizontalVisualFormat = "H:"
                    var verticalVisualFormat = "V:"
                    
                    switch edge {
                    case UIRectEdge.bottom:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "[v(\(width))]-(0)-|"
                    case UIRectEdge.top:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v(\(width))]"
                    case UIRectEdge.left:
                        horizontalVisualFormat += "|-(0)-[v(\(width))]"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    case UIRectEdge.right:
                        horizontalVisualFormat += "[v(\(width))]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    default:
                        break
                    }
                    
                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": view]))
                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": view]))
                }
            }
        }
    }
}

public struct ShadowConfiguration {
    
    let color: UIColor
    let opacity: Float
    let radius: CGFloat
    let widthOffset: CGFloat
    let heightOffset: CGFloat
    
    public init(color: UIColor,
                opacity: Float,
                radius: CGFloat,
                withOffset: CGFloat,
                heightOffset: CGFloat) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.widthOffset = withOffset
        self.heightOffset = heightOffset
    }
}

extension Array where Element == UIView {
   public func setAccessibilityHidden(_ state: Bool) {
        for view in self {
            if let stackView = view as? UIStackView {
                stackView.arrangedSubviews.forEach({$0.accessibilityElementsHidden = state})
            }
            view.accessibilityElementsHidden = state
        }
    }
}

extension UIView {
    public func groupElements(_ labels: [UILabel],
                              inContainer container: UIView? = nil,
                              traits: UIAccessibilityTraits? = nil) -> [Any]? {
        var elements = [UIAccessibilityElement]()
        let titleElement = UIAccessibilityElement(accessibilityContainer: self)
        titleElement.accessibilityTraits = traits ?? .none
        guard let mainTitle = labels.first, labels.count > 1 else { return nil }
        let groupText = mainTitle.appendSpeechFromElements(labels.suffix(labels.count-1))
        titleElement.accessibilityLabel = groupText
        let containerFrame = container != nil ? container?.bounds : bounds
        guard let accesibilityFrame = containerFrame else { return nil }
        titleElement.accessibilityFrameInContainerSpace = accesibilityFrame
        elements.append(titleElement)
        return elements
    }
}
