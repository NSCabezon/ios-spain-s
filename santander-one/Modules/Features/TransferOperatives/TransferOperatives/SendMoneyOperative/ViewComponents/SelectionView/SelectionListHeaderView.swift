//
//  SelectionListHeaderView.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 14/1/22.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SelectionListHeaderViewDelegate: AnyObject {
    func didSelectItem(_ item: OneSmallSelectorListViewModel)
}

final class SelectionListHeaderView: XibView {
    private enum Constants {
        static let selectedSuffix: String = "_listSelected"
        enum Countries {
            static let selectedItemKey: String = "chooseCountry_label_selectedCountry"
            static let allItemsKey: String = "chooseCountry_label_allCountries"
        }
        enum Currencies {
            static let selectedItemKey: String = "chooseCurrency_label_selectedCurrency"
            static let allItemsKey: String = "chooseCurrency_label_allCurrencies"
        }
    }
    
    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var selectedItemLabelView: UIView!
    @IBOutlet private weak var selectedItemLabel: UILabel!
    @IBOutlet private weak var selectedItemCardView: UIView!
    @IBOutlet private weak var selectedItemCard: OneSmallSelectorListView!
    @IBOutlet private weak var bottomSelectedItemView: UIView!
    @IBOutlet private weak var itemsCarousel: SelectionListCommonItemsView!
    @IBOutlet private weak var allItemsLabel: UILabel!
    
    weak var delegate: SelectionListHeaderViewDelegate?
    private var selectionType: SelectionListView.SelectionType = .countries
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func fillView(carouselItems: [OneSmallSelectorListViewModel],
                  selectedItem: OneSmallSelectorListViewModel?,
                  type: SelectionListView.SelectionType) {
        self.selectionType = type
        self.itemsCarousel.fillView(with: carouselItems, and: type)
        self.setLabelTexts()
        self.configureSelectedItem(selectedItem: selectedItem)
        self.setAccessibilityIdentifiers()
    }
}

private extension SelectionListHeaderView {
    func setupView() {
        self.configureLabels()
        self.configureItemsCarousel()
    }
    
    func configureLabels() {
        self.selectedItemLabel.font = .typography(fontName: .oneB300Regular)
        self.selectedItemLabel.textColor = .oneBrownishGray
        self.allItemsLabel.font = .typography(fontName: .oneB300Regular)
        self.allItemsLabel.textColor = .oneBrownishGray
    }
    
    func configureItemsCarousel() {
        self.itemsCarousel.delegate = self
    }
    
    func setAccessibilityIdentifiers() {
        self.selectedItemLabel.accessibilityIdentifier = self.selectionType == .countries ? Constants.Countries.selectedItemKey : Constants.Currencies.selectedItemKey
        self.allItemsLabel.accessibilityIdentifier = self.selectionType == .countries ? Constants.Countries.allItemsKey : Constants.Currencies.allItemsKey
    }
    
    func setLabelTexts() {
        let selectedItemTitle: String = {
            switch self.selectionType {
            case .countries:
                return Constants.Countries.selectedItemKey
            case .currencies:
                return Constants.Currencies.selectedItemKey
            }
        }()
        let allItemsTitle: String = {
            switch self.selectionType {
            case .countries:
                return Constants.Countries.allItemsKey
            case .currencies:
                return Constants.Currencies.allItemsKey
            }
        }()
        self.selectedItemLabel.text = localized(selectedItemTitle)
        self.allItemsLabel.text = localized(allItemsTitle)
    }
    
    func hideSelectedItem() {
        self.selectedItemLabelView.isHidden = true
        self.selectedItemCardView.isHidden = true
        self.bottomSelectedItemView.isHidden = true
    }
    
    func configureSelectedItem(selectedItem: OneSmallSelectorListViewModel?) {
        guard var selectedItem = selectedItem
        else {
            self.hideSelectedItem()
            return
        }
        selectedItem.accessibilitySuffix = Constants.selectedSuffix
        self.selectedItemCard.setViewModel(selectedItem)
    }
}

extension SelectionListHeaderView: SelectionListCommonItemsViewDelegate {
    func didSelectCommonItem(_ item: OneSmallSelectorListViewModel) {
        self.delegate?.didSelectItem(item)
    }
}
