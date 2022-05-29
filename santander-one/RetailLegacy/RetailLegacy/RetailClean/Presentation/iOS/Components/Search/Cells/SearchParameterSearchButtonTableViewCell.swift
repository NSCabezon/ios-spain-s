import UIKit

class SearchParameterSearchButtonTableViewCell: BaseViewCell {

    @IBOutlet weak var searchButton: RedButton!
    
    var buttonPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchButton.addTarget(self, action: #selector(searchPressed(_:)), for: .touchUpInside)
        (searchButton as UIButton).applyStyle(ButtonStylist(textColor: .uiWhite, font: UIFont.latoMedium(size: 16.0)))
    }

    @objc func searchPressed(_ sender: UIButton) {
        buttonPressed?()
    }
    
    func setButtonTitle(_ title: LocalizedStylableText) {
        (searchButton as UIButton).set(localizedStylableText: title, state: .normal)
    }
}
