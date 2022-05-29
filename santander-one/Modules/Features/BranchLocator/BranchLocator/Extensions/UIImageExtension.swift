import UIKit

extension UIImage {
	
	convenience init?(with color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
	
	convenience init?(resourceName: String) {
        let podBundle = Bundle(for: MapViewController.self).branchLocatorBundle
		self.init(named: resourceName, in: podBundle, compatibleWith: nil)
	}
}
