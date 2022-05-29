import UIKit

let defaultPadding = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)

extension UIView {
    func applyDefaultCornerRadius() {
        layer.cornerRadius = 10.0
    }
    
    func applyGradientBackground(colorStart: UIColor, colorFinish: UIColor) {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.colors = [colorStart.cgColor, colorFinish.cgColor]
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
