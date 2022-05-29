//
//  DateSectionHeaderView.swift
//  Account
//
//  Created by Jose Camallonga on 24/2/22.
//
import CoreFoundationLib
import CoreGraphics
import UI

final class DateSectionHeaderView: UITableViewHeaderFooterView {
    private var dateLabel: UILabel
    private enum Constants {
        static let backgroundAlphaValue: CGFloat = 0.9
        static let dateLabelFontSize: CGFloat = 14.0
        enum Constraints {
            static let labelLeadingSpace: CGFloat = 16.0
            static let horizontalLineHeight: CGFloat = 1.0
        }
    }
    override init(reuseIdentifier: String?) {
        dateLabel = UILabel(frame: .zero)
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        dateLabel = UILabel(frame: .zero)
        super.init(coder: coder)
        commonInit()
    }
    
    func configure(withDate date: Date) {
        dateLabel.scaledFont = .santander(family: .text, type: .bold, size: Constants.dateLabelFontSize)
        dateLabel.textColor = .bostonRed
        dateLabel.configureText(withLocalizedString: DateDecorator(date).setDateFormatter(false))
        dateLabel.accessibilityLabel = DateDecorator(date).setDateFormatterComplete(true).text
        setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        accessibilityIdentifier = "dateSectionView"
        dateLabel.accessibilityIdentifier = "productHomeTransactionListLabelDate"
    }
}

private extension DateSectionHeaderView {
    func commonInit() {
        setupDateLabel()
        setupView()
    }
    
    func setupView() {
        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue)
            backgroundConfiguration = backgroundConfig
        } else {
            layer.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue).cgColor
        }
    }
    
    func setupDateLabel() {
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: Constants.Constraints.labelLeadingSpace),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
