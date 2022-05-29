import UIKit
import UI

protocol NavigationBarPGCustomizer: class {
    var stringLoader: StringLoader! { get }
    var styledTitle: LocalizedStylableText? { get set }
}

extension NavigationBarPGCustomizer where Self: UIViewController {
    func setCustomizeToolbar(isPB: Bool, name: String?) {
        var colors: [UIColor]
        var vector: (start: CGPoint, end: CGPoint)
        if isPB {
            setupImageTitle()
            colors = [.white]
            vector = (start: CGPoint(x: 0.0, y: 0.4), end: CGPoint(x: 1.0, y: 0.6))
        } else {
            if let name = name, name != "" {
                styledTitle = stringLoader.getString("pg_title_welcome", [StringPlaceholder(StringPlaceholder.Placeholder.name, name.camelCasedString)])
            }
            colors = [.white]
            vector = (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        }
        navigationController?.navigationBar.setGradientBackground(colors: colors, vector: vector)
        
        let image = Assets.image(named: "icnMailbox")?.withRenderingMode(.alwaysTemplate)
        let sociusButton: UIBarButtonItem
        
        sociusButton = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
        
        navigationItem.leftBarButtonItem = sociusButton
    }
    
    func setupImageTitle() {
        navigationItem.setImageInTitle(Assets.image(named: "logoLoginPb") ?? UIImage(), padding: 1, resize: 0.85)
    }
}
