//
//  CategoryDetailHeaderXibView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 30/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIOneComponents

public enum CategoryDetailHeaderViewState: State {
    case didTappedPdf
    case didTappedFilter
    case didChangeHeaderHeight
    case didSelectGraphBar(_ index: Int)
    case didSelectSubcategories(_ subcategoriesSelected: [FinancialHealthSubcategoryType])
    case showMinimunBottomSheet
    case didTappedExpectedTooltip
    case removeAllFilter(Bool)
    case removeFilter(filterActives: [TagMetaData])
}

protocol CategoryDetailHeaderRepresentable {
    var graphRepresentable: BarsGraphViewRepresentable { get }
}

final class CategoryDetailHeaderView: XibView {
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var movemensTitleLabel: UILabel!
    @IBOutlet private weak var pdfButton: OneAppLink!
    @IBOutlet private weak var filterButton: OneAppLink!
    @IBOutlet private weak var barsGraphView: BarsGraphView!
    @IBOutlet private weak var totalizatorAndSubcategoriesFilterView: TotalizatorAndSubcategoriesFilterView!
    @IBOutlet private weak var messageNotificationView: OneAlertView!
    @IBOutlet private weak var messageContainerView: UIStackView!
    private var subscriptions = Set<AnyCancellable>()
    private var subject = PassthroughSubject<CategoryDetailHeaderViewState, Never>()
    private var movementsNumber = 0
    private var categorization: AnalysisAreaCategorization = .expenses
    private var selectedAmounts: (mainAmount: Decimal, expectedAmount: Decimal?)? {
        didSet {
            guard let amount = selectedAmounts?.mainAmount else { return }
            totalizatorAndSubcategoriesFilterView.updateLabels(amount: amount, expected: selectedAmounts?.expectedAmount)
        }
    }
    public lazy var publisher: AnyPublisher<CategoryDetailHeaderViewState, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private var tagsContainerView: OneTagsContainerView? = OneTagsContainerView()
    private var filters: AnalysisAreaFilterModelRepresentable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
        setAccesibilityIdentifiers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
        setAccesibilityIdentifiers()
    }
    
    @IBAction func pdfDidTapped(_ sender: Any) {
        subject.send(.didTappedPdf)
    }

    @IBAction func filterDidTapped(_ sender: Any) {
        subject.send(.didTappedFilter)
    }
    
    func setGraphInfo(_ representable: BarsGraphViewRepresentable) {
        barsGraphView.setInfo(representable: representable)
    }
    
    func setTotalizatorAndSubcategoriesFilterInfo(_ representable: FHCategoryDetailTotalizatorRepresentable) {
        totalizatorAndSubcategoriesFilterView.configureWith(representable)
        categorization = representable.categorization
    }
    
    func updateNumberOfMovements(_ numberOfMovements: Int) {
        movemensTitleLabel.text = localized("analysis_label_movements", [StringPlaceholder(.number, "\(numberOfMovements)")]).text
        movementsNumber = numberOfMovements
        setupMessageNotificationView()
    }
    
    func addTagContainer(withTags tags: [TagMetaData]) {
        guard let tagsContainerView = self.tagsContainerView else { return }
        tagsContainerView.addTags(from: tags)
        tagsContainerView.backgroundColor = .white
        containerStackView.addArrangedSubview(tagsContainerView)
        self.tagsContainerView?.layoutIfNeeded()
        subject.send(.didChangeHeaderHeight)
    }
    
    func getTagsContainerView() -> OneTagsContainerView? {
        return self.tagsContainerView
    }
    
    func filterIsApplied(_ isFilterApplied: Bool) {
        self.barsGraphView.isHidden = isFilterApplied
        isFilterApplied ? totalizatorAndSubcategoriesFilterView.showSubcategoriesSelected() : totalizatorAndSubcategoriesFilterView.hiddenSubcategoriesSelected()
    }
}

private extension CategoryDetailHeaderView {
    func bind() {
        barsGraphView.publisher
            .case { BarsGraphViewState.didTapBar }
            .sink { [unowned self] info in
                let totalAmount = Decimal(info.amount)
                let expectedAmount: Decimal? = info.secondaryAmount.isNil ? nil : Decimal(info.secondaryAmount ?? 0)
                selectedAmounts = (totalAmount, expectedAmount)
                subject.send(.didSelectGraphBar(info.index))
            }.store(in: &subscriptions)
        
        totalizatorAndSubcategoriesFilterView.publisher
            .case(TotalizatorAndSubcategoriesFilterViewState.sendSelectedSubcategory)
            .sink { [unowned self] subcategoryTapped in
                subject.send(.didSelectSubcategories(subcategoryTapped))
            }.store(in: &subscriptions)
        
        totalizatorAndSubcategoriesFilterView.publisher
            .case(TotalizatorAndSubcategoriesFilterViewState.showMinimunBottomSheet)
            .sink { [unowned self] _ in
                subject.send(.showMinimunBottomSheet)
            }.store(in: &subscriptions)
        
        totalizatorAndSubcategoriesFilterView.publisher
            .case(TotalizatorAndSubcategoriesFilterViewState.changeHeight)
            .sink { [unowned self] _ in
                subject.send(.didChangeHeaderHeight)
            }.store(in: &subscriptions)
        
        totalizatorAndSubcategoriesFilterView.publisher
            .case(TotalizatorAndSubcategoriesFilterViewState.showExpectedTooltipBottomSheet)
            .sink { [unowned self] _ in
                subject.send(.didTappedExpectedTooltip)
            }.store(in: &subscriptions)
        
        tagsContainerView?
            .deleteTagsPublisher
            .sink { [unowned self] tags in
                tagsContainerView?.layoutIfNeeded()
                guard tags.count > 0 else {
                    self.tagsContainerView?.removeFromSuperview()
                    subject.send(.didChangeHeaderHeight)
                    subject.send(.removeAllFilter(true))
                    return
                }
                subject.send(.didChangeHeaderHeight)
                subject.send(.removeFilter(filterActives: tags))
            }.store(in: &subscriptions)
    }
    
    func setupView() {
        messageContainerView.isHidden = true
        movemensTitleLabel.font = .typography(fontName: .oneH200Bold)
        movemensTitleLabel.textColor = .oneLisboaGray
        movemensTitleLabel.text = localized("analysis_label_movements", [StringPlaceholder(.number, "0")]).text
        setPdfAndFilterButtons()
    }

    func setPdfAndFilterButtons() {
        pdfButton.configureButton(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: localized("generic_button_downloadPDF"),
                icons: .top,
                image: "oneIcnPdfGreen")
        )
        filterButton.configureButton(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: localized("generic_button_filters"),
                icons: .top,
                image: "oneIcnFilters")
        )
    }
    
    func setupMessageNotificationView() {
        messageContainerView.isHidden = true
        layoutIfNeeded()
        guard let totalAmount = selectedAmounts?.mainAmount else { return }
        let haveMovements = movementsNumber > 0
        let totalIsEqualZero = totalAmount == 0
        let totalIsPositive = totalAmount > 0
        let totalIsNegative = totalAmount < 0
        var representable: DefaultMessageNotification?
        switch categorization {
        case .incomes:
            if totalIsNegative || (haveMovements && totalIsEqualZero) {
                messageNotificationView.setType(.textOnly(stringKey: "analysis_label_negativeMovements"))
                messageContainerView.isHidden = false
            }
        default:
            if totalIsPositive || (haveMovements && totalIsEqualZero) {
                messageNotificationView.setType(.textOnly(stringKey: "analysis_label_positiveMovements"))
                messageContainerView.isHidden = false
                totalizatorAndSubcategoriesFilterView.hiddenExpected()
            }
        }
        layoutIfNeeded()
    }
    
    func setAccesibilityIdentifiers() {
        self.movemensTitleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionMovementsLabel
        self.pdfButton.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionpdfButton
        self.filterButton.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionFilterButton
    }
}

struct DefaultMessageNotification: OneNotificationRepresentable {
    var type: OneNotificationType
    var defaultColor: UIColor
    var inactiveColor: UIColor?
}
