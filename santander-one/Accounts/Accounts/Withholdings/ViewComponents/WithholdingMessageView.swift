import UI
import UIKit

class WithholdingMessageView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    
    convenience init(_ viewModel: WithholdingMessageViewModel) {
        self.init(frame: .zero)
        self.setAppearance()
        setViewModel(viewModel)
    }
    
    private func setAppearance() {
        titleLabel.textColor = .black
    }
    
    private func setViewModel(_ viewModel: WithholdingMessageViewModel) {
        titleLabel.configureText(withLocalizedString: viewModel.title,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 12.0)))
    }
    
    public func setAccessibilityIdentifiers(labelAccessibilityID: String) {
        self.titleLabel.accessibilityIdentifier = labelAccessibilityID
    }
}
