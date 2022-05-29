import UI
import UIKit
import UIOneComponents
import CoreFoundationLib
import CoreDomain
import OpenCombine

private extension SavingProductsHeaderView {
    struct Appearance {
        let leadingAnchorSV: CGFloat = 16
        let trailingAnchorSV: CGFloat = -16
    }
}

enum SavingProductsFilterState: State {
    case idle
    case loaded(TransactionFiltersRepresentable?)
    case remove(ActiveFilters?)
    case removeAll(Bool)
}

final class SavingProductsHeaderView: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak private var actionButtonsStackView: OneShortcutsView!
    @IBOutlet weak private var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: SavingsHomeCollectionView!
    @IBOutlet private weak var heightSavingsCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var actionsHeaderView: SavingHeaderActionsView?
    @IBOutlet private weak var gradientView: OneGradientView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    private var stackViewBorderConstraints = [NSLayoutConstraint]()
    private var stackViewWidthConstraint: NSLayoutConstraint?
    private var anySubscriptions = Set<AnyCancellable>()
    private var defaultHeight: CGFloat = 180
    private var currentUpdatedHeight: CGFloat = 0
    private let appearance = Appearance()

    let headerShouldShowMoreOptions = CurrentValueSubject<Bool, Never>(false)
    let optionsSubject = CurrentValueSubject<[SavingProductOptionRepresentable], Never>([])
    let transactionsButtonsSubject = CurrentValueSubject<[SavingProductsTransactionsButtonsType], Never>([])
    let didSelectOptionSubject = PassthroughSubject<(SavingProductOptionRepresentable), Never>()
    var tagsContainerView: TagsContainerView? = TagsContainerView()
    let filterStateSubject = PassthroughSubject<SavingProductsFilterState, Never>()
    let didTapMoreOptionsSubject = PassthroughSubject<OneShortcutsViewStates, Never>()
    var savingProduct: Savings?

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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard collectionView.subviews.isNotEmpty else { return }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
            accessibilityElements = [collectionView.leftButton as Any,
                                     collectionView.cellForItem(at: visibleIndexPath) as Any,
                                     collectionView.rightButton as Any,
                                     actionButtonsStackView as Any,
                                     actionsHeaderView as Any]
        }
    }
    
    func updateHeight(_ heightToUpdate: CGFloat) {
        self.currentUpdatedHeight = heightToUpdate
        adaptViewHeight(defaultHeight + currentUpdatedHeight)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        adaptViewHeight(currentUpdatedHeight + defaultHeight)
    }

    func updatePageControlDots() {
        let indicatorColor = UIColor(red: 151.0 / 255.0, green: 151.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
        let backgroundColorForPriorIOS14 = UIColor.clear
        let currentIndicatorColor = UIColor.oneLisboaGray
        pageControl.currentPageIndicatorTintColor = currentIndicatorColor
        if #available(iOS 14.0, *) {
            pageControl.pageIndicatorTintColor = indicatorColor
            let symbolDotConfiguration = UIImage.SymbolConfiguration(pointSize: 8, weight: .regular, scale: .medium)
            let dotFillImage = UIImage(systemName: "circle.fill", withConfiguration: symbolDotConfiguration)
            let dotImage = UIImage(systemName: "circle", withConfiguration: symbolDotConfiguration)
            for index in 0..<pageControl.numberOfPages {
                pageControl.setIndicatorImage(index == pageControl.currentPage ? dotFillImage : dotImage, forPage: index)
            }
        } else {
            pageControl.pageIndicatorTintColor = backgroundColorForPriorIOS14
            pageControl.subviews.enumerated().forEach { index, subview in
                subview.layer.cornerRadius = subview.frame.size.height / 2
                subview.layer.borderWidth = 1
                subview.layer.borderColor = index == pageControl.currentPage ? currentIndicatorColor.cgColor : indicatorColor.cgColor
            }
        }
    }
}

extension SavingProductsHeaderView: SavingsHomeHeaderViewProtocol {}

private extension SavingProductsHeaderView {
    
    func bind() {
        bindOptions()
        bindMoreOptions()
		bindAnimation()
        bindTransactionsButtons()
    }

	func bindAnimation() {
		collectionView.scrollViewDidEndScrollingAnimation
            .sink { [unowned self] _ in
                guard collectionView.subviews.isNotEmpty else { return }
                let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
                    accessibilityElements = [collectionView.leftButton as Any,
                                             collectionView.cellForItem(at: visibleIndexPath) as Any,
                                             collectionView.rightButton as Any,
                                             actionButtonsStackView as Any,
                                             actionsHeaderView as Any]
                    if let chartVisible = collectionView.cellForItem(at: visibleIndexPath) {
                        DispatchQueue.main.async {
                            UIAccessibility.post(notification: .layoutChanged, argument: chartVisible)
                        }
                    }
                }
            }.store(in: &anySubscriptions)

	}
    
    func bindOptions() {
        optionsSubject
            .sink { [unowned self] options in
                self.addActionButtons(with: options)
            }.store(in: &anySubscriptions)

        headerShouldShowMoreOptions
            .filter {$0 == true}
            .sink { [unowned self] _ in
                self.actionButtonsStackView.showMoreOptionsButton()
            }.store(in: &anySubscriptions)

        headerShouldShowMoreOptions
            .filter {$0 == false}
            .sink { [unowned self] _ in
                self.actionButtonsStackView.hideMoreOptionsButton()
            }.store(in: &anySubscriptions)
    }
    
    func bindTransactionsButtons() {
        transactionsButtonsSubject
            .sink { [unowned self] options in
            self.setupActionsHeader(options: options)
        }.store(in: &anySubscriptions)
    }

    func bindMoreOptions() {
        actionButtonsStackView
            .publisher
            .case(OneShortcutsViewStates.didTapMoreOptions)
            .sink { [unowned self] _ in
                self.didTapMoreOptionsSubject.send(.didTapMoreOptions)
            }.store(in: &anySubscriptions)
    }

    func setupView() {
        self.setupPageControl()
        self.setGradient()
        self.backgroundColor = .oneWhite
        self.actionsHeaderView?.clipsToBounds = true
        self.setAccessibility()
    }
    
    func setupPageControl() {
        let pages = collectionView.numberOfItems(inSection: 0)
        self.pageControl.numberOfPages = pages
        self.pageControl.hidesForSinglePage = true
        self.pageControl.isHidden = pages <= 1
        self.pageControl.pageIndicatorTintColor = .mediumSkyGray
        self.pageControl.currentPageIndicatorTintColor = .lisboaGray
        if #available(iOS 14.0, *) {
            self.pageControlHeightConstraint.isActive = false
            self.pageControl.backgroundStyle = .minimal
        }
        self.pageControl.addTarget(self, action: #selector(pageControlSelectionAction(_:)), for: .valueChanged)
    }
    
    func setupActionsHeader(options: [SavingProductsTransactionsButtonsType]) {
        actionsHeaderView?.togglePdfDownload(toHidden: options.contains(.downloadPDF) == false)
        actionsHeaderView?.toggleFilters(toHidden: options.contains(.filter) == false)
    }
    
    func setGradient() {
        gradientView.setupType(.oneGrayGradient(direction: GradientDirection.bottomToTop))
    }
    
    func addTagContainer(withTags tags: [TagMetaData]) {
        guard let tagsContainerView = self.tagsContainerView else { return }
        tagsContainerView.addTags(from: tags)
        tagsContainerView.backgroundColor = .white
        self.stackView.addArrangedSubview(tagsContainerView)
        tagsContainerView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
    }

    @objc func pageControlSelectionAction(_ pageControl: UIPageControl) {
        let index = IndexPath(item: pageControl.currentPage, section: 0)
        self.collectionView.scrollTo(index)
    }
    
    func adaptViewHeight(_ height: CGFloat) {
        let adjustedHeight: CGFloat
        if #available(iOS 11.0, *) {
            adjustedHeight = UIFontMetrics.default.scaledValue(for: height)
        } else {
            adjustedHeight = (UIFont.preferredFont(forTextStyle: .body).pointSize / 17.0) * height
        }
        self.heightSavingsCollectionConstraint.constant = max(height, adjustedHeight)
        self.collectionView.updateCellHeight(self.heightSavingsCollectionConstraint.constant)
        self.collectionView.layoutIfNeeded()
        self.view?.updateConstraints()
    }
    
    func setAccessibility() {
        actionButtonsStackView.setupMoreOptionsAccessibility(key: "oneIconMoreOptions")
        leftButton.accessibilityIdentifier = "savingsCarouselPreviousProduct"
        leftButton.accessibilityLabel = localized("voiceover_changePreviosSaving")
        rightButton.accessibilityIdentifier = "savingsCarouselNextProduct"
        rightButton.accessibilityLabel = localized("voiceover_changeNextSaving")
        pageControl.isAccessibilityElement = false
    }
}

extension SavingProductsHeaderView: SavingsHomeHeaderWithTagsViewProtocol {}

private extension SavingProductsHeaderView {

    func setupActionButtons(enabled: Bool) {
        self.actionButtonsStackView.isUserInteractionEnabled = enabled
        self.actionsHeaderView?.isUserInteractionEnabled = enabled
    }
    
    func addActionButtons(with values: [SavingProductOptionRepresentable]) {
        var shortcutsButtons = [OneShortcutButtonConfiguration]()
        values.forEach { viewModel in
            let shortcutButton = OneShortcutButtonConfiguration(title: viewModel.title,
                                                                icon: viewModel.imageName,
                                                                iconTintColor: viewModel.imageColor,
                                                                backgroundColor: .oneWhite,
                                                                backgroundImage: nil,
                                                                offerImage: nil,
                                                                tagTitle: nil,
                                                                accessibilitySuffix: viewModel.accessibilityIdentifier.capitalizingFirstLetter(),
                                                                isDisabled: false,
                                                                action: {
                self.didSelectOptionSubject.send(viewModel)
            })
            shortcutsButtons.append(shortcutButton)
        }
        actionButtonsStackView.removeButtons()
        actionButtonsStackView.addButtons(buttons: shortcutsButtons)
    }
}
