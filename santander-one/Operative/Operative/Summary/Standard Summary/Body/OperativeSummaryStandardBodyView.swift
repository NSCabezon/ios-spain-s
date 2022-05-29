//
//  OperativeSummaryStandardBodyView.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 22/05/2020.
//

import CoreFoundationLib
import UIKit
import UI

public enum SummaryCollapsable {
    case noCollapsable
    case defaultCollapsable(visibleSections: Int = 2)
}

public struct OperativeSummaryStandardBodyActionViewModel: ActionButtonFillViewModelProtocol {
    public let action: () -> Void
    public let viewType: ActionButtonFillViewType
    
    public init(image: String,
                title: String,
                titleAccessibilityIdentifier: String = "",
                action: @escaping () -> Void) {
        self.viewType = .defaultButton(
            DefaultActionButtonViewModel(
                title: title,
                imageKey: image,
                titleAccessibilityIdentifier: titleAccessibilityIdentifier,
                imageAccessibilityIdentifier: image
            )
        )
        self.action = action
    }
}

public struct OperativeSummaryStandardBodyItemViewModel {
    
    public enum Position {
        case unknown
        case last
    }
    
    public let title: String
    public let subTitle: NSAttributedString
    public let info: NSAttributedString?
    public let accessibilityIdentifier: String?
    public let titleImageUrl: String?

    public init(title: String,
                subTitle: NSAttributedString,
                info: String? = nil,
                accessibilityIdentifier: String? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.info = NSAttributedString(string: info ?? "")
        self.accessibilityIdentifier = accessibilityIdentifier
        self.titleImageUrl = nil
    }
    
    public init(title: String,
                subTitle: String,
                info: String? = nil,
                accessibilityIdentifier: String? = nil,
                titleImageURLString: String? = nil) {
        self.title = title
        self.subTitle = NSAttributedString(string: subTitle)
        self.info = NSAttributedString(string: info ?? "")
        self.accessibilityIdentifier = accessibilityIdentifier
        self.titleImageUrl = titleImageURLString
    }
    
    public init(title: String,
                subTitle: String,
                info: NSAttributedString,
                accessibilityIdentifier: String? = nil,
                titleImageURLString: String? = nil) {
        self.title = title
        self.subTitle = NSAttributedString(string: subTitle)
        self.info = info
        self.accessibilityIdentifier = accessibilityIdentifier
        self.titleImageUrl = titleImageURLString
    }
}

public protocol OperativeSummaryStandardBodyViewDelegate: AnyObject {
    func didCollapseBody()
}

public final class OperativeSummaryStandardBodyView: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tornImageView: UIImageView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var locationsStackView: UIStackView!
    @IBOutlet private weak var actionStackView: UIStackView!
    @IBOutlet private weak var actionsHeight: NSLayoutConstraint!
    @IBOutlet private weak var openCloseButton: UIButton!
    @IBOutlet private weak var contentView: UIView!
    
    // MARK: - Private attributes
    
    private var defaultCollapsedSections: Int = 2
    private lazy var openCloseButtonBottomMarginToImage: NSLayoutConstraint = {
        self.openCloseButton.bottomAnchor.constraint(equalTo: self.tornImageView.bottomAnchor)
    }()
    private lazy var openCloseButtonBottomMarginToContent: NSLayoutConstraint = {
        self.openCloseButton.centerYAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    }()
    private var items: [OperativeSummaryStandardBodyItemViewModel] = []
    
    // MARK: - Public methods
    
    public weak var delegate: OperativeSummaryStandardBodyViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setupWithItems(_ items: [OperativeSummaryStandardBodyItemViewModel],
                               locations: [OperativeSummaryStandardLocationViewModel] = [],
                               actions: [OperativeSummaryStandardBodyActionViewModel],
                               collapsableSections: SummaryCollapsable) {
        setupItems(items, collapsableSections: collapsableSections)
        setupLocations(locations)
        setupActions(actions)
    }
    
    public func setupItems(_ items: [OperativeSummaryStandardBodyItemViewModel], collapsableSections: SummaryCollapsable?) {
        let showingLastSeparator: Bool
        switch collapsableSections {
        case .noCollapsable:
            self.defaultCollapsedSections = items.count
            self.disableExpansionBehaviour()
            showingLastSeparator = false
        case .defaultCollapsable(let defaultCollapsedSections):
            self.defaultCollapsedSections = defaultCollapsedSections
            showingLastSeparator = false
        case nil:
            showingLastSeparator = true
        }
        self.items = items
        self.add(items: self.items.prefix(self.defaultCollapsedSections), showingLastSeparator: showingLastSeparator)
    }
    
    public func setupLocations(_ locations: [OperativeSummaryStandardLocationViewModel]) {
        for model in locations {
            let view = OperativeSummaryStandardLocationView(model)
            locationsStackView.addArrangedSubview(view)
        }
    }
    
    public func setupActions(_ actions: [OperativeSummaryStandardBodyActionViewModel]) {
        guard !actions.isEmpty else {
            actionsHeight.constant = 0
            return
        }
        actions.forEach {
            let action = ActionButton()
            action.addSelectorAction(target: self, #selector(didTapOnAction))
            action.setViewModel($0)
            let constraint = action.widthAnchor.constraint(equalToConstant: 164)
            constraint.priority = UILayoutPriority(rawValue: 749)
            constraint.isActive = true
            self.actionStackView.addArrangedSubview(action)
        }
    }
}

private extension OperativeSummaryStandardBodyView {
    func setupView() {
        self.tornImageView.image = Assets.image(named: "imgTornSummary")
        self.openCloseButton.setBackgroundImage(Assets.image(named: "icnOvalArrowDown"), for: .normal)
        self.openCloseButton.setBackgroundImage(Assets.image(named: "icnOvalArrowUp"), for: .selected)
        self.openCloseButton.addTarget(self, action: #selector(didTapOnOpenCloseButton), for: .touchUpInside)
        self.openCloseButtonBottomMarginToImage.isActive = true
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        setAccessibility()
    }
    
    func expand() {
        self.addSeparator()
        self.add(items: self.items.suffix(from: self.defaultCollapsedSections))
        self.tornImageView.image = nil
        self.openCloseButtonBottomMarginToImage.isActive = false
        self.openCloseButtonBottomMarginToContent.isActive = true
    }
    
    func collapse() {
        self.contentStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        self.add(items: self.items.prefix(self.defaultCollapsedSections))
        self.tornImageView.image = Assets.image(named: "imgTornSummary")
        self.openCloseButtonBottomMarginToImage.isActive = true
        self.openCloseButtonBottomMarginToContent.isActive = false
        self.delegate?.didCollapseBody()
    }
    
    func add(items: ArraySlice<OperativeSummaryStandardBodyItemViewModel>, showingLastSeparator showLastSeparator: Bool) {
        let itemsLastIndex = items.count - 1
        items.enumerated().forEach { index, viewModel in
            let item = OperativeSummaryStandardBodyItemView(viewModel)
            self.contentStackView.addArrangedSubview(item)
            if showLastSeparator {
                self.addSeparator()
            } else if index != itemsLastIndex {
                self.addSeparator()
            }
        }
    }
    
    func add(items: ArraySlice<OperativeSummaryStandardBodyItemViewModel>) {
        let itemsLastIndex = items.count - 1
        items.enumerated().forEach { index, viewModel in
            let item = OperativeSummaryStandardBodyItemView(viewModel)
            self.contentStackView.addArrangedSubview(item)
            if index != itemsLastIndex {
                self.addSeparator()
            }
        }
    }
    
    func addSeparator() {
        let separator = PointLine(frame: .zero)
        separator.pointColor = UIColor.mediumSkyGray
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.contentStackView.addArrangedSubview(separator)
    }
    
    func disableExpansionBehaviour() {
        self.tornImageView.image = nil
        self.openCloseButton.isHidden = true
    }
    
    @objc func didTapOnAction(_ gesture: UIGestureRecognizer) {
        guard
            let actionButton = gesture.view as? ActionButton,
            let summaryAction = actionButton.getViewModel() as? OperativeSummaryStandardBodyActionViewModel
            else { return }
        summaryAction.action()
    }
    
    @objc func didTapOnOpenCloseButton() {
        if self.openCloseButton.isSelected {
            self.collapse()
        } else {
            self.expand()
        }
        self.openCloseButton.isSelected = !self.openCloseButton.isSelected
    }
    
    func setAccessibility() {
        openCloseButton.accessibilityLabel = localized("pg_label_moreInfo")
    }
}
