import Foundation

typealias OperatorInfoIdentifiers = (rightIdentifier: String?, leftIdentifier: String?, bottomIdentifier: String?)

final class OperatorInfoViewModel: TableModelViewItem<OperatorInfoTableViewCell> {
    
    weak var delegate: OperatorInformationProvider?
    let descriptionLeftIdentifier: String?
    let descriptionRightIdentifier: String?
    let bottomLabelIdentifier: String?
    
    init(delegate: OperatorInformationProvider,
         dependencies: PresentationComponent,
         descriptionLeftIdentifier: String? = nil,
         descriptionRightIdentifier: String? = nil,
         bottomLabelIdentifier: String? = nil) {
        self.delegate = delegate
        self.descriptionLeftIdentifier = descriptionLeftIdentifier
        self.descriptionRightIdentifier = descriptionRightIdentifier
        self.bottomLabelIdentifier = bottomLabelIdentifier
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OperatorInfoTableViewCell) {
        guard let delegate = delegate else {
            return
        }
        if let minimumAmount = delegate.minimumAmount {
            viewCell.setDescriptionLeftText(minimumAmount)
        }
        if let maximumAmount = delegate.maximumAmount {
            viewCell.setDescriptionRightText(maximumAmount)
        }
        if let intervalAmount = delegate.intervalAmount {
            viewCell.setBottomText(intervalAmount)
        }
        viewCell.setAccessibilityIdentifiers(identifiers: (descriptionRightIdentifier, descriptionLeftIdentifier, bottomLabelIdentifier))
    }
}
