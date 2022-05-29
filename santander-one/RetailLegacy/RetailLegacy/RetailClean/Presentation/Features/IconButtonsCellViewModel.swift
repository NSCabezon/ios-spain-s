import UIKit
import UI

class IconButtonsCellViewModel: TableModelViewItem<IconButtonsTableViewCell> {
    typealias option = (IconButtonsTableViewCell.Icon, (() -> Void))

    var options: [option]
    
    init(options: [option], dependencies: PresentationComponent) {
        self.options = options
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: IconButtonsTableViewCell) {        
        for (index, option) in options.enumerated() {
            viewCell.setOption(number: index, icon: option.0.image, action: option.1)
        }        
    }
    
}

extension IconButtonsTableViewCell {
    enum Icon {
        case facebook
        case twitter
        case googlePlus
        
        var image: UIImage? {
            switch self {
            case .facebook:
                return Assets.image(named: "icnFacebook")
            case .twitter:
                return Assets.image(named: "icnTwitter")
            case .googlePlus:
                return Assets.image(named: "icnGoogleplu")
            }
        }
    }
}
