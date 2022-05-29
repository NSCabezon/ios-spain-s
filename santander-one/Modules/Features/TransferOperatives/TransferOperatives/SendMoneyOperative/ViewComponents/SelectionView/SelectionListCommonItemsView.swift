//
//  SelectionListCommonItemsView.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 11/1/22.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SelectionListCommonItemsViewDelegate: AnyObject {
    func didSelectCommonItem(_ item: OneSmallSelectorListViewModel)
}

final class SelectionListCommonItemsView: XibView {
    private enum Constants {
        enum Countries {
            static let titleKey: String = "chooseCountry_label_commonCountries"
        }
        enum Currencies {
            static let titleKey: String = "chooseCurrency_label_commonCurrencies"
        }
        static let numberOfSections: Int = 1
        static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: .zero, left: 16.0, bottom: .zero, right: 16.0)
        enum Item {
            static let width: CGFloat = 120
            static let height: CGFloat = 108.0
            static let size: CGSize = CGSize(width: Constants.Item.width, height: Constants.Item.height)
            static let spacing: OneSpacingType = .oneSizeSpacing16
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var commonItemsCollectionView: UICollectionView!
    
    public weak var delegate: SelectionListCommonItemsViewDelegate?
    private var selectionType: SelectionListView.SelectionType = .countries
    private var items: [OneSmallSelectorListViewModel] = [] {
        didSet {
            self.commonItemsCollectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func fillView(with items: [OneSmallSelectorListViewModel], and type: SelectionListView.SelectionType) {
        self.items = items
        self.selectionType = type
        self.setLabelTexts()
        self.setAccessibilityIdentifiers()
    }
}

private extension SelectionListCommonItemsView {
    func setupView() {
        self.configureLabels()
        self.configureCollectionView()
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneB300Regular)
        self.titleLabel.textColor = .oneBrownishGray
    }
    
    func configureCollectionView() {
        self.configureCollectionViewLayout()
        self.registerCells()
        self.commonItemsCollectionView.delegate = self
        self.commonItemsCollectionView.dataSource = self
        self.commonItemsCollectionView.allowsSelection = true
        self.commonItemsCollectionView.allowsMultipleSelection = false
        self.commonItemsCollectionView.showsVerticalScrollIndicator = false
        self.commonItemsCollectionView.showsHorizontalScrollIndicator = false
        self.commonItemsCollectionView.decelerationRate = .fast
    }
    
    func registerCells() {
        self.commonItemsCollectionView.register(type: SelectionListCommonItemCell.self, bundle: Bundle.module)
    }
    
    func configureCollectionViewLayout() {
        guard let flowlayout = self.commonItemsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowlayout.itemSize = Constants.Item.size
        flowlayout.minimumLineSpacing = oneSpacing(type: Constants.Item.spacing)
        flowlayout.scrollDirection = .horizontal
    }
    
    func setLabelTexts() {
        let titleText: String = {
            switch self.selectionType {
            case .countries:
                return localized(Constants.Countries.titleKey)
            case .currencies:
                return localized(Constants.Currencies.titleKey)
            }
        }()
        self.titleLabel.text = localized(titleText)
    }
    
    func setAccessibilityIdentifiers() {
        switch self.selectionType {
        case .countries:
            self.titleLabel.accessibilityIdentifier = Constants.Countries.titleKey
            self.commonItemsCollectionView.accessibilityIdentifier = AccessibilitySendMoneyDestination.ChangeCountryView.chooseCountryCarouselCountries
        case .currencies:
            self.titleLabel.accessibilityIdentifier = Constants.Currencies.titleKey
            self.commonItemsCollectionView.accessibilityIdentifier = AccessibilitySendMoneyAmount.ChangeCurrencyView.chooseCurrencyCarouselCurrencies
        }
    }
}

extension SelectionListCommonItemsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: SelectionListCommonItemCell.self),
                for: indexPath) as? SelectionListCommonItemCell
        else { return SelectionListCommonItemCell() }
        cell.setViewModel(self.items[indexPath.row], type: self.selectionType)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = self.items[indexPath.row]
        guard selectedItem.status != .activated else {
            return
        }
        self.delegate?.didSelectCommonItem(selectedItem)
    }
}

extension SelectionListCommonItemsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
}
