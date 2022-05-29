import UIKit
import UI

struct AviosPointsViewModel {
    let descriptionTitleKey: String
    let points: String
    let pointsAccessibilityIdentifier: String
    let background: UIColor
}

final class AviosPointsView: DesignableView {
    @IBOutlet private weak var descriptionTitleLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var aviosLabel: UILabel!
    
    init(viewModel: AviosPointsViewModel) {
        super.init(frame: .zero)
        setModel(viewModel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func commonInit() {
        super.commonInit()
        self.backgroundColor = .clear
        self.contentView?.backgroundColor = .clear
        self.descriptionTitleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.descriptionTitleLabel.textColor = .white
        self.pointsLabel.font = .santander(family: .text, type: .bold, size: 32)
        self.pointsLabel.textColor = .white
        self.aviosLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.aviosLabel.textColor = .white
        self.aviosLabel.configureText(
            withKey: "avios_label_avios",
            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75)
        )
        self.aviosLabel.accessibilityIdentifier = "avios_label_avios"
    }
}

private extension AviosPointsView {
    func setModel(_ viewModel: AviosPointsViewModel) {
        self.backgroundColor = viewModel.background
        self.descriptionTitleLabel.configureText(
            withKey: viewModel.descriptionTitleKey,
            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75)
        )
        self.descriptionTitleLabel.accessibilityIdentifier = viewModel.descriptionTitleKey
        self.pointsLabel.configureText(withKey: viewModel.points, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.9))
        self.pointsLabel.accessibilityIdentifier = viewModel.points
        self.layer.cornerRadius = 8
    }
}
