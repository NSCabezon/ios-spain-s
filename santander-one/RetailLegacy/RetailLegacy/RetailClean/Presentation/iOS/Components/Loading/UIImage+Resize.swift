import UIKit

extension UIImage {
    public func resize(factor: CGFloat) -> UIImage? {
        return resize(to: CGSize(width: size.width  * factor, height: size.height * factor))
    }
    
    public func resize(to size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        
        draw(in: CGRect(origin: CGPoint(), size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resized
    }
    
    public func resizeTopAlignedToFill(newWidth: CGFloat) -> UIImage? {

        let newSize = CGSize(width: newWidth, height: newWidth * (size.height / size.width))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
