import UIKit

protocol LinkWebViewTableViewDelegate: class {
    func linkDidSelect()
}

class LinkWebViewTableViewCell: BaseViewCell {
    @IBOutlet weak var linkButton: UIButton!
    
    // MARK: - Public attributes
    
    weak var delegate: LinkWebViewTableViewDelegate?
    
    // MARK: - Public methods
    
    func setTitle(_ title: LocalizedStylableText) {
        linkButton.set(localizedStylableText: title, state: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        linkButton.applyStyle(ButtonStylist(textColor: .sanRed, font: .latoLight(size: 14)))
    }
    
    @IBAction func touchLinkButton(_ sender: Any) {
        delegate?.linkDidSelect()
    }
}
