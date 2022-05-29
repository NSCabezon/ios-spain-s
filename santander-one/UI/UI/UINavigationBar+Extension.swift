//
//  UINavigationBar+Extension.swift
//  UI
//
//  Created by Juan Carlos López Robles on 10/23/19.
//

import Foundation

public extension UINavigationBar {
    
    func setClearBackground(flag: Bool) {
        if #available(iOS 11, *) {
            let image: UIImage? = flag ? UIImage() : nil
            setBackgroundImage(image, for: .default)
            shadowImage = image
            isTranslucent = flag
            backgroundColor = .clear
            barStyle = flag ? .blackOpaque: .default
        }
    }
    
    func setGradientBackground(colors: [UIColor], vector: (start: CGPoint, end: CGPoint)) {
        
        func installGradient(gradient: CAGradientLayer) {
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height + 20.0)
            setBackgroundImage(gradient.photo?.resizableImage(withCapInsets: UIEdgeInsets(), resizingMode: .stretch), for: .default)
        }
        
        let gradient = CAGradientLayer()
        gradient.startPoint = vector.start
        gradient.endPoint = vector.end
        
        gradient.colors = colors.map { $0.cgColor }
        
        if #available(iOS 11, *) {
            // because of autolayout
            DispatchQueue.main.async {
                installGradient(gradient: gradient)
            }
        } else {
            installGradient(gradient: gradient)
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
