import UIKit

extension UINavigationBar {
    
    func setClearBackground(flag: Bool) {
        let image: UIImage? = flag ? UIImage() : nil
        setBackgroundImage(image, for: .default)
        shadowImage = image
        isTranslucent = flag
        backgroundColor = .clear
        barStyle = flag ? .blackOpaque: .default
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
            //because of autolayout
            DispatchQueue.main.async {
                installGradient(gradient: gradient)
            }
        } else {
            installGradient(gradient: gradient)
        }
    }
}
