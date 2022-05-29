import UIKit
import UI

extension UIImageView {
    func setVariation(variation: String?, compareZero: ComparisonResult) {
        if variation != nil {
            let image: UIImage
            switch compareZero {
            case .orderedDescending:
                image = Assets.image(named: "iconValueArrowDown") ?? UIImage()
            case .orderedAscending:
                image = Assets.image(named: "iconValueArrowUp") ?? UIImage()
            case .orderedSame:
                image = Assets.image(named: "icnEqual") ?? UIImage()
            }
            self.image = image
        } else {
            self.image = nil
        }
        
        self.contentMode = .scaleAspectFit
    }
    
    func setSplashImage() {
        if let splashImage = Assets.image(named: "splash") {
            image = splashImage
        }
    }
}
