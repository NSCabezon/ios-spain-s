import UI
import CoreFoundationLib

class WithholdingEmptyView: XibView {
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var emptyDescriptionLabel: UILabel!
    @IBOutlet weak var separatorView: DottedLineView!
    
    convenience init(_ viewModel: WithholdingEmptyViewModel) {
        self.init(frame: .zero)
        setAppearance()
        setModel(viewModel)
    }
    
    private func setAppearance() {
        emptyLabel.textColor = .lisboaGray
        emptyDescriptionLabel.textColor = .lisboaGray
        separatorView?.strokeColor = .darkSky   
    }
    
    private func setModel(_ viewModel: WithholdingEmptyViewModel) {
        emptyLabel.configureText(withLocalizedString: viewModel.title,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 18.0)))
        emptyDescriptionLabel.configureText(withLocalizedString: viewModel.descriptionTitle,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12.0)))
        emptyImageView.image = Assets.image(named: viewModel.imageName)
    }
    
    public func setAccessibilityIdentifiers(imgAccessibilityID: String, labelAccessibilityID: String, descriptionLabelAccessibilityID: String? = nil) {
        self.emptyImageView.accessibilityIdentifier = imgAccessibilityID
        self.emptyLabel.accessibilityIdentifier = labelAccessibilityID
        self.emptyDescriptionLabel.accessibilityIdentifier = descriptionLabelAccessibilityID
    }
}
