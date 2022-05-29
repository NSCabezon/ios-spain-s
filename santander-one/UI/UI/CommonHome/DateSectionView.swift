import UIKit
import CoreFoundationLib

private struct StaticValuesForConfiguration {
    var heightTableFooter: CGFloat = 1.0
    var withAlphaComponent: CGFloat = 0.9
    var fontSize: CGFloat = 14.0
}

public final class DateSectionView: UITableViewHeaderFooterView {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var horizontalLine: UIView!
    private var staticValues = StaticValuesForConfiguration()

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = UIColor.white.withAlphaComponent(staticValues.withAlphaComponent)
            backgroundConfiguration = backgroundConfig
        } else {
            self.layer.backgroundColor = UIColor.white.withAlphaComponent(staticValues.withAlphaComponent).cgColor
        }
    }
    
    public func configure(withDate date: LocalizedStylableText) {
        dateLabel.font = .santander(family: .text, type: .bold, size: staticValues.fontSize)
        dateLabel.textColor = .bostonRed
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

extension DateSectionView {
    public func toggleHorizontalLine(toVisible visible: Bool) {
        horizontalLine.isHidden = !visible
    }
    
    public func addTableViewFooter(toVisible visible: Bool) {
          dateLabel.isHidden = visible
          horizontalLine.isHidden = !visible
          horizontalLine.frame.size = CGSize(width: self.frame.width, height: staticValues.heightTableFooter)
          self.frame.size = CGSize(width: self.frame.width, height: staticValues.heightTableFooter)
      }
}
