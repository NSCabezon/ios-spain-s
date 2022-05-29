//
//  FundHeaderTableViewCell.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 30/3/22.
//

import UI
import CoreFoundationLib

private enum FundHeaderConstants {
    static let filterHeight: CGFloat = 60
    static let tagHeight: CGFloat = 27
    static let closeImageWidth: CGFloat = 22
    static let tagLeadingSpacing: CGFloat = 8
    static let tagTrailingSpacing: CGFloat = 1
    static let closeImageTrailingSpacing: CGFloat = 1
}

final class FundHeaderTableViewCell: UITableViewCell {
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var movementsLabel: UILabel!
    @IBOutlet private weak var filterImageView: UIImageView!
    @IBOutlet private weak var filterLabel: UILabel!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var filterTagView: UIView!
    @IBOutlet private weak var filterTagsStackView: UIStackView!
    @IBOutlet private weak var clearFiltersLabel: UILabel!
    @IBOutlet private weak var clearFiltersButton: UIButton!
    @IBOutlet private weak var filterTagsViewHeightContraint: NSLayoutConstraint!
    private var filters: FundsFilterRepresentable?
    var didSelectFilterButton: (() -> Void)?
    var updatedFilters: ((FundsFilterRepresentable?) -> Void)?
    var clearFilters: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }

    func configure(withViewModel viewModel: FundMovements, andFilters filters: FundsFilterRepresentable?) {
        self.filters = filters
        self.aliasLabel.text = viewModel.fund.alias
        self.aliasLabel.accessibilityIdentifier = AccessibilityIdFundsTransactions.fundsLabelCarrouselAlias.rawValue
        self.movementsLabel.accessibilityIdentifier = AccessibilityIdFundsTransactions.fundsLabelMovements.rawValue
        self.filterButton.accessibilityIdentifier = AccessibilityIdFundsTransactions.btnFilters.rawValue
        self.filterLabel.accessibilityIdentifier = AccessibilityIdFundsTransactions.genericButtonFilters.rawValue
        self.clearFiltersButton.accessibilityIdentifier = AccessibilityIdFundsTransactions.filterItemClear.rawValue
        self.configureFilters()
        self.setAccessibility { [weak self] in
            self?.aliasLabel.accessibilityLabel = localized("voiceover_fundName", [StringPlaceholder(.value, viewModel.fund.alias ?? "")]).text
            self?.filterButton.accessibilityLabel = localized("generic_button_filters")
            self?.clearFiltersButton.accessibilityLabel = localized("generic_button_deleteFilters")
            self?.selectionStyle = .none
            self?.isAccessibilityElement = false
            self?.accessibilityElements = [self?.aliasLabel, self?.movementsLabel, self?.filterButton, self?.filterTagView]
        }
    }

    @IBAction func filterButtonDidPressed(_ sender: UIButton) {
        self.didSelectFilterButton?()
    }

    @IBAction func clearFilterButtonDidPressed(_ sender: Any) {
        self.filters = nil
        self.clearFilters?()
    }
}

private extension FundHeaderTableViewCell {
    func setAppearance() {
        selectionStyle = .none
        aliasLabel.textColor = .oneLisboaGray
        aliasLabel.textFont = .santander(family: .headline, type: .bold, size: 18)
        movementsLabel.textColor = .oneLisboaGray
        movementsLabel.textFont = .santander(family: .headline, type: .bold, size: 18)
        movementsLabel.text = localized("funds_label_Movements")
        filterImageView.image = Assets.image(named: "icnFilter")?.withRenderingMode(.alwaysTemplate)
        filterImageView.tintColor = .darkTorquoise
        filterLabel.textColor = .darkTorquoise
        filterLabel.font = .santander(family: .text, type: .regular, size: 12)
        filterLabel.text = localized("generic_button_filters")
        self.topView.applyGradientBackground(colors: [UIColor.oneWhite, UIColor.skyGray])
        self.layoutIfNeeded()
        let clearFilterText = NSAttributedString(string: localized("generic_button_deleteFilters"), attributes: [NSAttributedString.Key.font : UIFont.santander(family: .micro, type: .bold, size: 14)])
        self.clearFiltersLabel.attributedText = clearFilterText
    }

    func configureFilters() {
        let isFilterActive = self.filters?.dateInterval != nil
        self.filterTagsViewHeightContraint.constant = isFilterActive ? FundHeaderConstants.filterHeight : 0
        self.filterTagView.isHidden = !isFilterActive
        guard let dateInterval = self.filters?.dateInterval else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let fromDatePlaceholder = StringPlaceholder(.date, formatter.string(from: dateInterval.start))
        let toDatePlaceholder = StringPlaceholder(.date, formatter.string(from: dateInterval.end))
        let dateLocalizedTag = localized("generic_label_dateFilter", [fromDatePlaceholder, toDatePlaceholder]).text
        let dateRangeFilterTag = self.getFilterTag(dateLocalizedTag, withType: .dateRange, buttonIdentifier: AccessibilityIdFundsTransactions.filterItemDates.rawValue, labelIdentifier: AccessibilityIdFundsTransactions.filterItemDatesValue.rawValue)
        self.filterTagsStackView.removeAllArrangedSubviews()
        self.filterTagsStackView.addArrangedSubview(dateRangeFilterTag)
    }

    func getFilterTag(_ text: String, withType type: FilterTagType, buttonIdentifier: String? = nil, labelIdentifier: String? = nil) -> FilterTagView {
        let textWidth = text.widthOfString(usingFont: UIFont.santander(family: .micro, type: .bold, size: 13.5))
        let filterTagViewWidth = FundHeaderConstants.tagLeadingSpacing + textWidth + FundHeaderConstants.tagTrailingSpacing + FundHeaderConstants.closeImageWidth + FundHeaderConstants.closeImageTrailingSpacing
        let filterTagView = FilterTagView(frame: CGRect(x: 0, y: 0, width: filterTagViewWidth, height: FundHeaderConstants.tagHeight))
        filterTagView.setupView(description: text, type: type, buttonIdentifier: buttonIdentifier, labelIdentifier: labelIdentifier)
        filterTagView.didSelectTag = { [weak self] type in
            self?.updatedFilters?(nil)
        }
        return filterTagView
    }
}

extension FundHeaderTableViewCell: AccessibilityCapable {}
