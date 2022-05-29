//
//  OtherSpendsView.swift
//  Pods
//
//  Created by Jose Javier Montes Romero on 20/1/22.
//  

import UI
import Foundation
import UIOneComponents
import OpenCombine
import CoreFoundationLib
import UIKit
import CoreDomain

protocol OtherExpensesViewRepresentable: CategoryViewRepresentable {
    var categories: [CategoryRepresentable] { get }
    var expandedImageKey: String { get }
}

enum OtherSpendsViewState: State {
    case didTapExpanded
    case didSelectCategory(CategoryRepresentable)
}
final class OtherSpendsView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var icnTypeImage: UIImageView!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountContentView: UIView!
    @IBOutlet private weak var separatorTopView: UIView!
    @IBOutlet private weak var categoriesContainerStackView: UIStackView!
    @IBOutlet private weak var spaceToTopSeparatorConstraint: NSLayoutConstraint!
    @IBOutlet private weak var totalTransactionsLabelTopConstraint: NSLayoutConstraint!
    private var subject = PassthroughSubject<OtherSpendsViewState, Never>()
    public lazy var publisher: AnyPublisher<OtherSpendsViewState, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private var categories: [CategoryRepresentable] = []
    private var isExpanded: Bool = false
    private lazy var arrangedCategoryViews: [CategoryView] = {
        return categoriesContainerStackView.arrangedSubviews.compactMap { $0 as? CategoryView }
    }()
    private var typeOfCategories: AnalysisAreaCategorization = .expenses
    private var representable: OtherExpensesViewRepresentable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setInfo(_ info: [CategoryRepresentable], isExpanded: Bool) {
        self.representable = OtherExpensesViewRepresented(otherCategories: info)
        self.typeOfCategories = representable?.categorization ?? .expenses
        categories = info
        self.isExpanded = isExpanded
        configureView()
        setVisibilityCategoriesView()
        setAccessibilityIdentifiers()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setExpanedCategories(isExpanded: Bool) {
        self.isExpanded = isExpanded
        setVisibilityCategoriesView()
        configureArrowImage()
        amountLabel.attributedText = setAmount(representable?.amount.value ?? 0.0)
    }
    
    @IBAction func isExpandedTapped(_ sender: Any) {
        subject.send(.didTapExpanded)
    }
}

private extension OtherSpendsView {
    
    func setupUI() {
        titleLabel.font = .typography(fontName: .oneH100Bold)
        subtitleLabel.font = .typography(fontName: .oneB300Regular)
    }

    func configureView() {
        titleLabel.text = localized(representable?.titleKey ?? "")
        subtitleLabel.text = representable?.movementsText
        amountLabel.attributedText = setAmount(representable?.amount.value ?? 0.0)
        separatorTopView.backgroundColor = .oneMediumSkyGray
        configureArrowImage()
        self.amountContentView.setOneCornerRadius(type: .oneShRadius4)
        self.amountContentView.backgroundColor = self.typeOfCategories == .incomes ? UIColor.greenIce : UIColor.clear
    }
    
    func setAmount(_ amount: Decimal) -> NSAttributedString {
        let amount = AmountEntity(value: amount, currency: .eur)
        let amountFont: UIFont =  self.isExpanded ?
            .typography(fontName: .oneH300Bold) :
            .typography(fontName: .oneH300Regular)
        let moneyDecorator = MoneyDecorator(amount, font: amountFont, decimalFontSize: 16)
        return moneyDecorator.getFormatedCurrency() ?? NSAttributedString(string: "")
    }
    
    func configureArrowImage() {
        if isExpanded {
            icnTypeImage.image = Assets.image(named: "oneIcnArrowRoundedUp")?.withRenderingMode(.alwaysTemplate)
            icnTypeImage.tintColor = .oneLisboaGray
            self.icnTypeImage.accessibilityIdentifier = "\(AnalysisAreaAccessibility.oneIcnArrowRoundedUp)"
        } else {
            icnTypeImage.image = Assets.image(named: "oneIcnArrowRoundedDown")?.withRenderingMode(.alwaysTemplate)
            icnTypeImage.tintColor = .oneLisboaGray
            self.icnTypeImage.accessibilityIdentifier = "\(AnalysisAreaAccessibility.oneIcnArrowRoundedDown)"
        }
    }
    
    func createCategoriesView() {
        for (index, category) in categories.enumerated() {
            let categoryView = CategoryView()
            categoryView.setInfo(category, positiveAmounHighlighted: true)
            categoryView.tag = index
            let tapCategoryGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCategory(gesture:)))
            categoryView.addGestureRecognizer(tapCategoryGesture)
            categoriesContainerStackView.addArrangedSubview(categoryView)
            if index == categories.count - 1 {
                categoriesContainerStackView.addArrangedSubview(addLineSeparatorView())
            } else {
                categoriesContainerStackView.addArrangedSubview(addDashedSeparatorView())
            }
        }
    }
    
    func setVisibilityCategoriesView() {
        if self.isExpanded {
            self.spaceToTopSeparatorConstraint.constant = 16
            self.totalTransactionsLabelTopConstraint.constant = 24
            createCategoriesView()
        } else {
            self.spaceToTopSeparatorConstraint.constant = 0
            self.totalTransactionsLabelTopConstraint.constant = 16
            self.categoriesContainerStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        }
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
        layoutIfNeeded()
    }
    
    func addDashedSeparatorView() -> DashedLineView {
        let separatorView = DashedLineView()
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorView.backgroundColor = .clear
        separatorView.strokeColor = .oneMediumSkyGray
        return separatorView
    }
    
    func addLineSeparatorView() -> UIView {
        let separatorView = UIView()
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorView.backgroundColor = .oneMediumSkyGray
        return separatorView
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = "\(AnalysisAreaAccessibility.categorizationLabel)_\(AnalysisAreaAccessibility.otherSpendsKey)"
        self.subtitleLabel.accessibilityIdentifier = "\(AnalysisAreaAccessibility.analysisLabelMovement)_\(AnalysisAreaAccessibility.otherSpendsKey)"
        self.amountLabel.accessibilityIdentifier = "\(AnalysisAreaAccessibility.analysisCardCategoriesListAmount)_\(AnalysisAreaAccessibility.otherSpendsKey)"
        self.icnTypeImage.accessibilityIdentifier = "\(AnalysisAreaAccessibility.icnCategoryCat)_\(AnalysisAreaAccessibility.otherSpendsKey)"
        self.icnTypeImage.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
    }
    
    func setAccessibilityInfo() {
        guard let representable = representable else { return }
        self.titleLabel.isAccessibilityElement = false
        self.topView.isAccessibilityElement = true
        self.topView.accessibilityLabel = titleLabel.text
        self.topView.accessibilityValue = isExpanded ? localized("voiceover_collapseHiddenCategories") : localized("voiceover_viewHiddenCategories")
        self.topView.accessibilityTraits = .button
        self.subtitleLabel.accessibilityLabel = localized("analysis_label_movement", [StringPlaceholder(.number, String(describing: representable.totalMovements))]).text
        self.subtitleLabel.accessibilityValue = localized("voiceover_percentageExpenses", [StringPlaceholder(.number, String(describing: representable.totalPercentage))]).text
        self.amountLabel.accessibilityLabel = setAmount(representable.amount.value ?? 0.0).string
        self.accessibilityElements = [self.topView, self.categoriesContainerStackView.subviews, self.subtitleLabel, self.amountLabel].compactMap {$0}
    }
    
    @objc func didTapCategory(gesture: UITapGestureRecognizer) {
        guard let index = arrangedCategoryViews.find({ $0 === gesture.view }) else { return }
        let categoryInfo = categories[index]
        subject.send(.didSelectCategory(categoryInfo))
    }
}

extension OtherSpendsView: AccessibilityCapable {}
