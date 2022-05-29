import CoreFoundationLib
import UIKit
import UI

final class GPCustomizationHeaderView: UICollectionReusableView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(family: .text, type: .light, size: 16)
        label.textColor = UIColor.lisboaGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.configureText(withKey: "pgCustomize_text_productsOrder")
        label.accessibilityIdentifier = "gpCustomization_subtitle"
        self.addSubview(label)
        return label
    }()
    enum Margin {
        static let top: CGFloat = 22
        static let bottom: CGFloat = 24
        static let left: CGFloat = 15
        static let right: CGFloat = 15
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
     }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
     }
}

extension GPCustomizationHeaderView {
    static func calculateSize(withWidth width: CGFloat) -> CGSize {
        let usableWidth = width - Margin.left - Margin.right
        let usableHeight = localized("pgCustomize_text_productsOrder").height(
            withConstrainedWidth: usableWidth,
            font: UIFont.santander(family: .text, type: .light, size: 16)
        ) + Margin.top + Margin.bottom
        return CGSize(width: usableWidth, height: usableHeight)
    }
}

private extension GPCustomizationHeaderView {
    func configure() {
        self.label.fullFit(topMargin: Margin.top, bottomMargin: Margin.bottom, leftMargin: Margin.left, rightMargin: Margin.right)
    }
}
