import UIKit
import CoreFoundationLib
import UI

public final class FHTransactionSectionView: UITableViewHeaderFooterView {
    @IBOutlet private weak var dateLabel: UILabel!

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        contentView.applyOneGradient(.oneGrayGradient(direction: .bottomToTop))
    }
    
    public func configure(withDate date: LocalizedStylableText) {
        dateLabel.font = .typography(fontName: .oneH100Regular)
        dateLabel.textColor = .oneBrownishGray
        dateLabel.configureText(withLocalizedString: date)
        setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "dateSectionView"
        dateLabel.accessibilityIdentifier = "dateSectionLabel"
    }
    
    public func setLabelIdentifier(_ identifier: String) {
        dateLabel.accessibilityIdentifier = identifier
    }
}
