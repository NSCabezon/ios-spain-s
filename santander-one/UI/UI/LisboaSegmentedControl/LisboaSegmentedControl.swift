import UIKit
import CoreFoundationLib

@IBDesignable public class LisboaSegmentedControl: UISegmentedControl {
    private var sortedSegments: [UIView] = []
    private var style: LisboaSegmentedControlStyle = .defaultSegmentedControlStyle
    private var isMultilineEnabled: Bool = false
    public override var selectedSegmentIndex: Int {
        didSet {
            self.segmentsLayout()
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setup(with localizedKeys: [String], accessibilityIdentifiers: [String]? = nil, withStyle style: LisboaSegmentedControlStyle? = nil) {
        if let style = style { self.style = style }
        self.setSegments(localizedKeys, accessibilityIdentifiers: accessibilityIdentifiers)
        self.setupView()
        self.selectedSegmentIndex = 0
        if #available(iOS 13, *) {
            self.bgImageForSelected()
        }
    }

    public func setupMultiLineWithStylableText(with localizedKeys: [String], accessibilityIdentifiers: [String]? = nil, withStyle style: LisboaSegmentedControlStyle? = nil) {
        if let style = style { self.style = style }
        self.setSegments(localizedKeys, accessibilityIdentifiers: accessibilityIdentifiers)
        self.isMultilineEnabled = true
        self.setupView()
        self.selectedSegmentIndex = 0
    }

    private func setupView() {
        self.configureTextAttributes()
        self.configureDesignAccordingVersion()
        self.clipsToBounds = true
    }

    private func setSegments(_ values: [String], accessibilityIdentifiers: [String]? = nil) {
        self.removeAllSegments()
        values.enumerated().forEach({ (index, item) in
            self.insertSegment(withTitle: localized(item), at: index, animated: false)
        })
        self.sortedSegments = self.subviews
        guard let accessibilityIdentifiers = accessibilityIdentifiers,
            sortedSegments.count == accessibilityIdentifiers.count
            else { return }
        self.sortedSegments.enumerated().forEach {
            $0.element.accessibilityIdentifier = accessibilityIdentifiers[$0.offset]
            $0.element.accessibilityLabel = localized(values[$0.offset])
        }
    }

    private func configureTextAttributes() {
        self.setTitleTextAttributes(style.unselectedLabelAttributes, for: .normal)
        self.setTitleTextAttributes(style.selectedLabelAttributes, for: .selected)
    }

    private func configureDesignAccordingVersion() {
        self.backgroundColor = style.backgroundColor
        let borderStyle = style.border
        self.drawBorder(cornerRadius: borderStyle.cornerRadius, color: borderStyle.color, width: borderStyle.width)
        self.applyDesign()
        self.addTarget(self, action: #selector(segmentsLayout), for: .allEvents)
        self.addTarget(self, action: #selector(segmentsLayout), for: .valueChanged)
    }

    private func applyDesign() {
        if #available(iOS 13.0, *) {
            let image = UIImage().withTintColor(.clear)
            self.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            self.selectedSegmentTintColor = style.selectedColor
        } else {
            self.tintColor = .clear
        }
    }

    @objc private func segmentsLayout() {
        self.sortedSegments.enumerated().forEach { index, item in
            item.layer.cornerRadius = style.optionCornerRadius
            item.backgroundColor = index == self.selectedSegmentIndex ? style.selectedColor : style.unselectedColor
            item.layer.shadowColor = index == self.selectedSegmentIndex ? style.shadowColor : style.defaultShadowColor
            item.layer.shadowRadius = index == self.selectedSegmentIndex ? style.shadowRadius : style.defaultShadowRadius
            item.layer.shadowOffset = index == self.selectedSegmentIndex ? style.shadowOffSet : style.defaultShadowOffSet
            item.layer.shadowOpacity = index == self.selectedSegmentIndex ? style.shadowOpacity : style.defaultShadowOpacity
            if isMultilineEnabled {
                self.makeMultiline()
            } else {
                item.subviews.first(where: { $0 is UILabel })?.frame.size = item.frame.size
            }
        }
    }

    private func makeMultiline() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.sortedSegments.forEach { item in
            item.subviews.forEach({ (itemView) in
                guard let label = itemView as? UILabel else { return }
                label.numberOfLines = 0
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                label.set(lineHeightMultiple: 0.8)
                itemView.frame.size = item.frame.size
            })
        }
    }

    private func bgImageForSelected() {
        setBackgroundImage(selectedItemImage(), for: .normal, barMetrics: .default)
        setBackgroundImage(selectedItemImage(), for: .selected, barMetrics: .default)
        setDividerImage(selectedItemImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    private func selectedItemImage() -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }
}
