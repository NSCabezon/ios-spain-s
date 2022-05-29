import UIKit

class BasePgViewCell: BaseViewCell {
    
    @IBOutlet private var lateralSpaces: [NSLayoutConstraint]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard lateralSpaces != nil else {
            fatalError("Global Position cells must set lateralSpaces property")
        }
        
        if UIScreen.main.isIphone4or5 {
            for space in lateralSpaces {
                space.constant = 10
            }
        }
    }
    
}
