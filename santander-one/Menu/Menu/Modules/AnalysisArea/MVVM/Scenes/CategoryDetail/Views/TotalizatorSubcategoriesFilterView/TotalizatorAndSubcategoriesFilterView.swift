//
//  TotalizatorAndSubcategoriesFilterView.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 11/4/22.
//

import UI
import UIKit
import UIOneComponents
import CoreFoundationLib
import OpenCombine
import CoreDomain

enum TotalizatorAndSubcategoriesFilterViewState: State {
    case idle
    case sendSelectedSubcategory(_ subcategoriesSelected: [FinancialHealthSubcategoryType])
    case showMinimunBottomSheet
    case showExpectedTooltipBottomSheet
    case changeHeight
}

final class TotalizatorAndSubcategoriesFilterView: XibView {
    private let identifier = "FHFilterCollectionViewCell"
    @IBOutlet private weak var subcategoriesCollectionConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var categoryIcn: UIImageView!
    @IBOutlet private weak var topTitle: UILabel!
    @IBOutlet private weak var topAmount: UILabel!
    @IBOutlet private weak var bottomStackVIew: UIStackView!
    @IBOutlet private weak var bottomTitle: UILabel!
    @IBOutlet private weak var bottomAmount: UILabel!
    @IBOutlet private weak var bottomTooltip: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var expandCollapseButton: OneOvalButton!
    @IBOutlet private weak var subcategoriesCollection: UICollectionView!
    @IBOutlet private weak var subcategorySelectedLabel: UILabel!
    private var representable: FHCategoryDetailTotalizatorRepresentable?
    private var subscriptions = Set<AnyCancellable>()
    private var isExpanded: Bool = false
    private var subcategoriesSelected: Set<FinancialHealthSubcategoryType> = [] {
        didSet {
            updateSubcategorySelectedLabel()
        }
    }
    private var filterIsShown = false
    private var lastExpected: Decimal?
    private let stateSubject = CurrentValueSubject<TotalizatorAndSubcategoriesFilterViewState, Never>(.idle)
    public var publisher: AnyPublisher<TotalizatorAndSubcategoriesFilterViewState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
    
    func configureWith(_ representable: FHCategoryDetailTotalizatorRepresentable) {
        self.representable = representable
        if subcategoriesSelected.isEmpty {
            representable.subcategories.forEach {
                if let subcategory = $0.subcategory {
                    subcategoriesSelected.insert(subcategory)
                }
            }
        }
        configureViews()
        updateFiltersCollectionView()
    }
    
    func updateLabels(amount: Decimal, expected: Decimal?) {
        configureLabels(amount: amount, expected: expected)
    }
    
    func hiddenExpected() {
        bottomStackVIew.isHidden = true
        layoutIfNeeded()
    }
    
    func showSubcategoriesSelected() {
        filterIsShown = true
        bottomStackVIew.isHidden = true
        subcategorySelectedLabel.isHidden = false
        layoutIfNeeded()
    }
    
    func hiddenSubcategoriesSelected() {
        filterIsShown = false
        subcategorySelectedLabel.isHidden = true
        bottomStackVIew.isHidden = lastExpected.isNil
        layoutIfNeeded()
    }
}

private extension TotalizatorAndSubcategoriesFilterView {
    func bind() {}
    
    func setupView() {
        setAppearance()
        configureViews()
        registerCell()
    }
    
    func registerCell() {
        let cellNib = UINib(nibName: identifier, bundle: Bundle.module)
        subcategoriesCollection.register(cellNib, forCellWithReuseIdentifier: identifier)
    }
    
    func setAppearance() {
        setLabelsAppearance()
        setContainerViewAppearance()
        configureExpandCollapseButton()
        expandCollapseSubcategoriesAppearence()
    }
    
    func configureViews() {
        configureImage()
        configureFiltersCollectionView()
        configureExpectedTooltip()
    }
    
    func setLabelsAppearance() {
        topTitle.font = .typography(fontName: .oneH100Bold)
        topAmount.font = .typography(fontName: .oneH200Bold)
        bottomTitle.font = .typography(fontName: .oneB200Regular)
        bottomAmount.font = .typography(fontName: .oneB200Regular)
        subcategorySelectedLabel.font = .typography(fontName: .oneB200Regular)
        bottomTitle.textColor = .oneBrownishGray
        bottomAmount.textColor = .oneBrownishGray
        subcategorySelectedLabel.textColor = .oneBrownishGray
    }
    
    func setContainerViewAppearance() {
        containerView.setOneCornerRadius(type: .oneShRadius8)
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.oneMediumSkyGray.cgColor
    }
    
    func configureExpandCollapseButton() {
        expandCollapseButton.size = .small
        expandCollapseButton.style = .whiteWithTurquoiseTint
        expandCollapseButton.direction = isExpanded ? .up : .down
    }
    
    func configureExpectedTooltip() {
        bottomTooltip.setImage(Assets.image(named: "oneIcnHelp"), for: .normal)
    }
    
    func configureImage() {
        categoryIcn.image = Assets.image(named: representable?.categoryIcon ?? "")
    }
    
    func configureLabels(amount: Decimal, expected: Decimal?) {
        topTitle.text = localized(representable?.categoryName ?? "")
        bottomStackVIew.isHidden = true
        layoutIfNeeded()
        guard let currency: String = representable?.currency else { return }
        topAmount.attributedText = setAmount(AmountEntity(value: amount, currencyCode: currency))
        bottomTitle.text = localized("analysis_label_forecastExpense")
        if representable?.categorization != .incomes {
            guard let expectedAmount = expected else { return }
            let amountExpected = AmountEntity(value: expected ?? 0, currencyCode: currency)
            bottomAmount.text = amountExpected.value?.toStringWithCurrency()
        } else {
            bottomStackVIew.isHidden = true
            stateSubject.send(.changeHeight)
            return
        }
        lastExpected = expected
        bottomStackVIew.isHidden = filterIsShown ? true : expected.isNil
        stateSubject.send(.changeHeight)
    }
    
    func configureFiltersCollectionView() {
        subcategoriesCollection.dataSource = self
        subcategoriesCollection.delegate = self
        subcategoriesCollection.allowsMultipleSelection = true
    }
    
    func updateFiltersCollectionView() {
        subcategoriesCollection.reloadData()
    }
    
    func setAmount(_ amount: AmountEntity) -> NSAttributedString {
        let moneyDecorator = MoneyDecorator(amount, font: .typography(fontName: .oneH300Regular), decimalFontSize: 16)
        return moneyDecorator.getFormatedCurrency() ?? NSAttributedString(string: "")
    }
    
    func expandCollapseSubcategoriesAppearence() {
        invalidateIntrinsicContentSize()
        separatorView.isHidden = self.isExpanded.isFalse
        expandCollapseButton.direction = self.isExpanded ? .up : .down
        subcategoriesCollectionConstraint.constant = self.isExpanded ? subcategoriesCollection.contentSize.height + 8 : 0
        stateSubject.send(.changeHeight)
    }
    
    @IBAction func didTapExpandCollapse(_ sender: Any) {
        isExpanded.toggle()
        expandCollapseSubcategoriesAppearence()
    }
    
    @IBAction func didTapTooltip(_ sender: Any) {
        stateSubject.send(.showExpectedTooltipBottomSheet)
    }
    
    func updateSubcategorySelectedLabel() {
        let numberOfSubcategoriesSelected: Int = subcategoriesSelected.count
        let numberOfSubcategories: Int = representable?.subcategories.count ?? 0
        subcategorySelectedLabel.configureText(withLocalizedString: localized("analysis_alert_selectedSubcategoriesDate",
                                                                              [StringPlaceholder(.number, "\(numberOfSubcategoriesSelected)"),
                                                                               StringPlaceholder(.number, "\(numberOfSubcategories)")]))
    }
}

extension TotalizatorAndSubcategoriesFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return representable?.subcategories.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? FHFilterCollectionViewCell,
              let cellInfo = representable?.subcategories[indexPath.item],
              let periodSelected = representable?.periodSelected else { return UICollectionViewCell() }
        cell.configureWith(cellInfo, periodSelected: periodSelected)
        if subcategoriesSelected.contains(where: { $0 == cellInfo.subcategory }) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        }
        return cell
    }
}

extension TotalizatorAndSubcategoriesFilterView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowlayout?.minimumInteritemSpacing ?? 0.0) + (flowlayout?.sectionInset.left ?? 0.0) + (flowlayout?.sectionInset.right ?? 0.0)
        let size: CGFloat = (subcategoriesCollection.frame.size.width - space) / 2.0
        return CGSize(width: size, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let subcategoryType = representable?.subcategories[indexPath.item].subcategory else { return }
        subcategoriesSelected.insert(subcategoryType)
        stateSubject.send(.sendSelectedSubcategory(Array(subcategoriesSelected)))
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let subcategoryType = representable?.subcategories[indexPath.item].subcategory else { return false }
        if subcategoriesSelected.count < 2 {
            stateSubject.send(.showMinimunBottomSheet)
            return false
        }
        subcategoriesSelected.remove(subcategoryType)
        stateSubject.send(.sendSelectedSubcategory(Array(subcategoriesSelected)))
        return true
    }
}
