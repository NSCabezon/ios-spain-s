//
//  FundProductsHeaderView.swift
//  Funds
//

import UI
import UIKit
import CoreFoundationLib
import CoreDomain
import OpenCombine
import UIOneComponents

private extension FundProductsHeaderView {
    struct Appearance {
        let leadingAnchorSV: CGFloat = 16
        let trailingAnchorSV: CGFloat = -16
    }
}

final class FundProductsHeaderView: XibView {
    @IBOutlet private weak var previousFundButton: UIButton!
    @IBOutlet private weak var nextFundButton: UIButton!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: FundsHomeCollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet private weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionButtonsView: UIView!
    @IBOutlet private weak var actionButtonsStackView: UIStackView!
    private var stackViewBorderConstraints = [NSLayoutConstraint]()
    private var stackViewWidthConstraint: NSLayoutConstraint?
    private var stackViewHeightConstraint: NSLayoutConstraint?
    private var anySubscriptions = Set<AnyCancellable>()
    private let appearance = Appearance()
    let optionsSubject = CurrentValueSubject<[FundHomeOption], Never>([])
    let didSelectOptionSubject = PassthroughSubject<(option: FundHomeOption, fund: Fund), Never>()
    var fund: Fund?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setAccessibilityIds()
        self.setupView()
        self.bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAccessibilityIds()
        self.setupView()
        self.bind()
    }

    @IBAction func previousFundButtonDidPressed(_ sender: Any) {
        guard self.collectionView.currentPosition > 0 else { return }
        self.collectionView.scrollTo(IndexPath(row: self.collectionView.currentPosition - 1, section: 0))
    }

    @IBAction func nextFundButtonDidPressed(_ sender: Any) {
        guard self.collectionView.currentPosition < (self.collectionView.numberOfItems(inSection: 0) - 1) else { return }
        self.collectionView.scrollTo(IndexPath(row: self.collectionView.currentPosition + 1, section: 0))
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

private extension FundProductsHeaderView {
    func bind() {
        self.optionsSubject
            .sink { [unowned self] options in
                self.actionButtonsStackView.distribution = options.count > 1 ? .fillEqually : .fill
                self.setupStackView(totalOptions: options.count)
                self.addActionButtons(with: options)
            }.store(in: &self.anySubscriptions)
    }

    @objc private func didTapOption(_ gesture: UIGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let optionViewModel = actionButton.getViewModel() as? FundHomeOption else { return }
        guard let fund = self.fund else { return }
        self.didSelectOptionSubject.send((optionViewModel, fund))
    }

    func setAccessibilityIds() {
        pageControl.accessibilityIdentifier = AccessibilityIdFundHeader.productCarouselTab.rawValue
        pageControl.isAccessibilityElement = true
        pageControl.accessibilityTraits = .button
        self.setAccessibility { [weak self] in
            self?.previousFundButton.isAccessibilityElement = true
            self?.previousFundButton.accessibilityLabel = localized("voiceover_changePreviousFund")
            self?.nextFundButton.isAccessibilityElement = true
            self?.nextFundButton.accessibilityLabel = localized("voiceover_changeNextFund")
        }
    }

    func setupView() {
        self.setupPageControl()
        self.backgroundColor = .skyGray
        self.stackViewBorderConstraints.append(self.actionButtonsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.appearance.leadingAnchorSV))
        self.stackViewBorderConstraints.append(self.actionButtonsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: self.appearance.trailingAnchorSV))
        self.stackViewWidthConstraint = self.actionButtonsStackView.widthAnchor.constraint(equalToConstant: 168)
        self.stackViewHeightConstraint = self.actionButtonsStackView.heightAnchor.constraint(equalToConstant: 72)
        self.actionButtonsView.applyGradientBackground(colors: [UIColor.oneWhite, UIColor.skyGray])
        self.collectionView.currentPositionChanged = { [weak self] in
            self?.setAccessibility { [weak self] in
                let indexPathSelected = IndexPath(row: self?.collectionView?.currentPosition ?? 0, section: 0)
                let cellSelected = self?.collectionView.cellForItem(at: indexPathSelected)
                self?.accessibilityElements = [self?.previousFundButton, cellSelected, self?.nextFundButton, self?.pageControl, self?.actionButtonsView].compactMap({ $0 })
            }
        }
        self.previousFundButton.isHidden = !UIAccessibility.isVoiceOverRunning
        self.nextFundButton.isHidden = !UIAccessibility.isVoiceOverRunning
    }

    func setupPageControl() {
        let pages = self.collectionView.numberOfItems(inSection: 0)
        self.pageControl.numberOfPages = pages
        self.pageControl.hidesForSinglePage = true
        self.pageControl.isHidden = pages <= 1
        if #available(iOS 14.0, *) {
            self.pageControlHeightConstraint.isActive = false
            self.pageControl.backgroundStyle = .minimal
        }
        self.pageControl.addTarget(self, action: #selector(self.pageControlSelectionAction), for: .valueChanged)
    }

    @objc func pageControlSelectionAction(_ pageControl: UIPageControl) {
        let index = IndexPath(item: pageControl.currentPage, section: 0)
        self.collectionView.scrollTo(index)
    }
}

private extension FundProductsHeaderView {
    func setupActionButtons(enabled: Bool) {
        self.actionButtonsStackView.isUserInteractionEnabled = enabled
    }

    func addActionButtons(with values: [FundHomeOption]) {
        self.actionButtonsStackView.removeAllArrangedSubviews()
        values.forEach { viewModel in
            let actionButton = self.createActionButton()
            actionButton.addSelectorAction(target: self, #selector(self.didTapOption))
            actionButton.accessibilityIdentifier = viewModel.accessibilityIdentifier
            actionButton.setViewModel(viewModel)
            self.actionButtonsStackView.addArrangedSubview(actionButton)
        }
    }

    func createActionButton() -> ActionButton {
        let actionButton = ActionButton()
        actionButton.setExtraLabelContent(nil)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: .zero)
        widthConstraint.priority = .defaultLow
        widthConstraint.isActive = true
        let actionButtonStyle = ActionButtonStyle(backgroundColor: UIColor.oneWhite, selectedBackgroundColor: UIColor.oneWhite, imageTintColor: UIColor.oneBostonRed, textColor: UIColor.oneLisboaGray, borderColor: UIColor.clear, shadow: (UIColor.oneLisboaGray, 0.15), emptyShadow: UIColor.clear, shadowRadius: 7, shadowOffset: CGSize(width: 1, height: 2), imageIconSize: (width: 24, height: 24), textHeight: 32, textFont: .santander(family: .micro, type: .regular, size: 12))
        actionButton.setAppearance(withStyle: actionButtonStyle)
        return actionButton
    }

    func setupStackView(totalOptions: Int) {
        self.actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        let moreThanOneOptions = totalOptions > 1
        self.stackViewBorderConstraints.forEach({ $0.isActive = moreThanOneOptions })
        self.stackViewWidthConstraint?.isActive = !moreThanOneOptions
        self.stackViewHeightConstraint?.isActive = totalOptions > 0
    }
}

extension FundProductsHeaderView: AccessibilityCapable {}
