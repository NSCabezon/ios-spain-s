//

import UIKit

protocol PersonalManagerOpinatorViewDelegate: class {
    func opinatorButtonDidTouched()
}

class PersonalManagerOpinatorViewCell: BaseViewCell {
    @IBOutlet weak var opinatorButton: OpinatorButton!
    weak var delegate: PersonalManagerOpinatorViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .uiBackground
        
        opinatorButton.setup(buttonStylist: ButtonStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 16), borderColor: nil, borderWidth: nil, backgroundColor: .uiWhite))
        opinatorButton.onTouchAction = { [weak self] button in
            self?.delegate?.opinatorButtonDidTouched()
        }        
    }
}
