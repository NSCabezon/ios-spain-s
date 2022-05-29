//

import Foundation

enum EasyPaySeparatorColor {
    case normal
    case background
    case paleGrey
}

final class EasyPaySeparatorModelView {
    let heightSepartor: Double
    let color: EasyPaySeparatorColor
    
    let identifier = "EasyPaySeparatorTableViewCell"
    
    init(heightSepartor: Double = 1, color: EasyPaySeparatorColor = .normal) {
        self.heightSepartor = heightSepartor
        self.color = color
    }
}

extension EasyPaySeparatorModelView: EasyPayTableViewModelProtocol { }
