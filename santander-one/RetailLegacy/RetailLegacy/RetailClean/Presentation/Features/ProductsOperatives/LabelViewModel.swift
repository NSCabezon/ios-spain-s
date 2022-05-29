//

import UIKit

class LabelViewModel: TableModelViewItem<BaseViewCell> {
    
    // MARK: - Public attributes
    
    let item: TitleDescriptionRepresentable
    let isSelected: Bool
    
    // MARK: - Public methods
    
    init(dependencies: PresentationComponent, item: TitleDescriptionRepresentable, isSelected: Bool = false, accessibilityIdentifier: String? = nil) {
        self.item = item
        self.isSelected = isSelected
        super.init(dependencies: dependencies)
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    override var height: CGFloat? {
        return 50
    }
    
    override func bind(viewCell: BaseViewCell) {
        viewCell.selectionStyle = .none
        let title: String = {
            if let description = item.representableDescription {
                return item.representableTitle + " " + "(" + description + ")"
            }
            return item.representableTitle
        }()
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font(.latoSemibold(size: 14)))
        if let description = item.representableDescription {
            attributedString.addAttribute(.font(.latoLight(size: 14)), to: "(" + description + ")")
        }
        if isSelected {
            attributedString.addAttribute(.color(.sanRed))
        } else {
            attributedString.addAttribute(.color(.sanGreyDark))
        }
        viewCell.textLabel?.attributedText = attributedString
        addSeparatorIfNeeded(viewCell: viewCell)
        viewCell.accessibilityIdentifier = self.accessibilityIdentifier
    }
    
    private func addSeparatorIfNeeded(viewCell: BaseViewCell) {
        let separatorIdentifier = "Separator".hashValue
        if !viewCell.subviews.contains(where: { $0.tag == separatorIdentifier }) {
            let separator = UIView()
            separator.backgroundColor = .lisboaGray
            separator.alpha = 0.48
            separator.tag = separatorIdentifier
            viewCell.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            let builder = NSLayoutConstraint.Builder()
                .add(separator.heightAnchor.constraint(equalToConstant: 1))
                .add(separator.leadingAnchor.constraint(equalTo: viewCell.leadingAnchor, constant: 20))
                .add(separator.trailingAnchor.constraint(equalTo: viewCell.trailingAnchor, constant: -20))
                .add(separator.bottomAnchor.constraint(equalTo: viewCell.bottomAnchor))
            builder.activate()
        }
    }
}
