import UIKit

protocol LinkPdfStackViewDelegate: class {
    func linkStackViewDidSelect()
}

class LinkPdfStackView: StackItemView {
    @IBOutlet private weak var linkButton: UIButton!
    
    // MARK: - Public attributes
    
    weak var delegate: LinkPdfStackViewDelegate?
    
    // MARK: - Public methods
    
    func setTitle(_ title: LocalizedStylableText) {
        linkButton.set(localizedStylableText: title, state: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        linkButton.applyStyle(ButtonStylist(textColor: .sanRed, font: .latoRegular(size: 14)))
        linkButton.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Private methods
    
    @objc private func linkButtonTapped() {
        delegate?.linkStackViewDidSelect()
    }
}
