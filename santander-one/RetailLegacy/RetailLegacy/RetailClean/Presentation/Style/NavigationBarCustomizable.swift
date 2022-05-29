import UIKit

protocol NavigationBarCustomizable {
    func setupPublicNavigationBar()
}

extension NavigationBarCustomizable where Self: UIViewController {
    
    func setupPublicNavigationBar() {
        let colors: [UIColor] = [.white]
        let vector = (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        navigationController?.navigationBar.setGradientBackground(colors: colors, vector: vector)
    }
}
