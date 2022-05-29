import UIKit

class DetailTitleHeader: BaseViewHeader {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setTitle(_ title: LocalizedStylableText?) {
        guard let title = title else { return }
        titleLabel.set(localizedStylableText: title)
    }
    
    func setColor(_ color: BackgroundColorCell?) {
        guard let color = color else { return }
        switch color {
        case .clear:
            backView.backgroundColor = .clear
        case .opaque:
            backView.backgroundColor = .uiBackground
        }
    }
    
    func setAccessibilityIdentifiers(_ titleAccessibilityIdentifier: String? = nil) {
        titleLabel.accessibilityIdentifier = titleAccessibilityIdentifier
    }
    
    override func awakeFromNib() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 14.0)))
    }
    
    override func getContainerView() -> UIView? {
        return nil
    }
    
    override func draw() {
    }

}
