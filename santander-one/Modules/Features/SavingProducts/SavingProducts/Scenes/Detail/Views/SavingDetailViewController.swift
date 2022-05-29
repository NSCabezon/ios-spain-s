//
//  SavingDetailViewController.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 25/4/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import UIOneComponents
import CoreDomain

final class SavingDetailViewController: UIViewController {

    private enum Constants {

        static let complementaryFieldHeight: CGFloat = 20
        static let scrollConstentInset: CGFloat = 20
        static let stackViewSpacing: CGFloat = 18
        static let isCopyFeedbackAutoCloseEnable: Bool = true
    }

    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SavingDetailDependenciesResolver
    private let viewModel: SavingDetailViewModel
    private let detailsContainerView = UIView()
    private var bottomSheetScreenName: String?
    private let copyFeedbackView = SavingsDetailCopyFeedbackView()
    private var copyFeedbackViewDownConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    private var copyFeedbackViewUpConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView()
        scrollableStackView.stackView.distribution = .equalSpacing
        scrollableStackView.stackView.axis = .vertical
        scrollableStackView.stackView.spacing = Constants.stackViewSpacing
        scrollableStackView.scrollView.contentInset = UIEdgeInsets(top: Constants.scrollConstentInset, left: 0, bottom: Constants.scrollConstentInset, right: 0)
        return scrollableStackView
    }()
    let savingDetailHeaderView = SavingDetailHeaderView(frame: .zero)

    private lazy var savingsCollectionView: SavingsHomeCollectionView = {
        return savingDetailHeaderView.collectionView
    }()

    init(dependencies: SavingDetailDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: nil, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configureSubviews()
        setupOneNavigationBar()
        bind()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.savingsCollectionView.reloadData()
    }
}

private extension SavingDetailViewController {

    func addSubviews() {
        self.view.addSubview(savingDetailHeaderView)
        self.view.addSubview(detailsContainerView)
        view.addSubview(copyFeedbackView)
    }

    func configureSubviews() {
        view.backgroundColor = .oneWhite
        detailsContainerView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainerView.backgroundColor = UIColor.oneWhite
        scrollableStackView.setup(with: detailsContainerView)
        copyFeedbackView.translatesAutoresizingMaskIntoConstraints = false
        savingDetailHeaderView.translatesAutoresizingMaskIntoConstraints = false
        savingDetailHeaderView.setInitialHeight()
        createConstraints()
        handleCopyFeedbackToastAnimation(show: false, isInitialSetup: true)
        copyFeedbackView.drawRoundedAndShadowedNew(radius: 8, borderColor: .mediumSkyGray)
    }

    func createConstraints() {
        var constraint: NSLayoutConstraint
        let commonConstraints: [NSLayoutConstraint] = [
            savingDetailHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor),
            savingDetailHeaderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            savingDetailHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

            detailsContainerView.topAnchor.constraint(equalTo: savingDetailHeaderView.bottomAnchor),
            detailsContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            detailsContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            detailsContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            copyFeedbackView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            copyFeedbackView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ]
        copyFeedbackViewDownConstraints = commonConstraints
        constraint = copyFeedbackView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        copyFeedbackViewDownConstraints.append(constraint)
        copyFeedbackViewUpConstraints = commonConstraints
        constraint = copyFeedbackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        copyFeedbackViewUpConstraints.append(constraint)
    }

    func setupOneNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_savingsDetails")
            .setLeftAction(.back, customAction: {
                self.didSelectGoBack()
            })
            .setRightAction(.menu) {
                self.didSelectOpenMenu()
            }
            .build(on: self)
    }

    func handleCopyFeedbackToastAnimation(show: Bool, isInitialSetup: Bool = false) {
        func activateUpConstraint() {
            NSLayoutConstraint.deactivate(copyFeedbackViewDownConstraints)
            NSLayoutConstraint.activate(copyFeedbackViewUpConstraints)
        }
        func activateDownConstraint() {
            NSLayoutConstraint.deactivate(copyFeedbackViewUpConstraints)
            NSLayoutConstraint.activate(copyFeedbackViewDownConstraints)
        }
        func handleVisibility(isHiddenAndTappable: Bool) {
            copyFeedbackView.isHidden = isHiddenAndTappable
            savingsCollectionView.handleTapableIconCopyDetailCell(isTappable: isHiddenAndTappable)
        }
        func hideCopyFeedback(_ isInitialSetup: Bool = false) {
            guard !isInitialSetup else {
                activateDownConstraint()
                handleVisibility(isHiddenAndTappable: true)
                return
            }
            UIView.animate(
                withDuration: 0.4,
                animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                },
                completion: { _ in
                    activateDownConstraint()
                    UIView.animate(
                        withDuration: 0.2,
                        animations: { [weak self] in
                            self?.view.layoutIfNeeded()
                        },
                        completion: { _ in
                            handleVisibility(isHiddenAndTappable: true)
                        })
                })
        }
        func showCopyFeedback() {
            handleVisibility(isHiddenAndTappable: false)
            activateUpConstraint()
            if Constants.isCopyFeedbackAutoCloseEnable {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                    guard let isAlreadyHidden = self?.copyFeedbackView.isHidden,
                          !isAlreadyHidden else {
                        return
                    }
                    hideCopyFeedback()
                }
            }
        }
        show ? showCopyFeedback() : hideCopyFeedback(isInitialSetup)
    }

    @objc func didSelectGoBack() {
        viewModel.didSelectBack()
    }

    @objc func didSelectOpenMenu() {
        viewModel.didSelectMenu()
    }

    func bind() {
        bindSavingDetails()
        bindBottomSheet()
        bindCopyFeedbackView()
    }

    func bindSavingDetails() {
        viewModel.state
            .case(SavingDetailState.dataLoaded)
            .sink {[unowned self] saving in
                self.savingDetailHeaderView.updateHeight(CGFloat(saving.totalNumberOfFields) * Constants.complementaryFieldHeight)
                self.savingsCollectionView.bind(
                    identifier: Identifiers.savingsCell,
                    cellType: SavingProductsHomeCollectionViewCell.self,
                    items: [saving]) { (indexPath, cell, item) in
                        cell?.configure(withModel: item, isDetailCell: true)
                        cell?.updateMainCellColor()
                        self.bindCopyIconDetailCell(cell)
                    }
                
                DispatchQueue.main.async {
                    self.view.layoutIfNeeded()
                }
                self.savingsCollectionView.reloadData()
            }.store(in: &anySubscriptions)

        viewModel.state
            .case(SavingDetailState.dataDetailsInfoLoaded)
            .sink {[unowned self] elements in
                let views = elements.compactMap { element -> SavingDetailElementView? in
                    guard let saving = self.viewModel.savingRepresentable else { return nil }
                    let elementView = SavingDetailElementViewFactory.createDetailElementView(for: element, saving: saving)
                    elementView.onTouchIconSubject
                        .sink {
                            switch element.action {
                            case .edit:
                                if element.type == .alias {
                                    self.viewModel.didSelectChangeAlias()
                                }
                            case .share:
                                if element.type == .number {
                                    self.viewModel.didSelectShare()
                                }
                            case .none:
                                return
                            }
                        }.store(in: &anySubscriptions)

                    return elementView
                }

                DispatchQueue.main.async {
                    views.forEach { scrollableStackView.addArrangedSubview($0) }
                    self.view.layoutIfNeeded()
                }
            }.store(in: &anySubscriptions)
    }

    func bindBottomSheet() {
        viewModel
            .state
            .case(SavingDetailState.bottomSheet)
            .sink { [weak self] (titleKey, infoKey) in
                guard let self = self else { return }
                let type: SizablePresentationType = .custom(isPan: true, bottomVisible: true, tapOutsideDismiss: true)
                let view = SavingsBottomView()
                view.configure(titleKey: titleKey, infoKey: infoKey)
                self.bottomSheetScreenName = self.trackerPage.balancePage
                BottomSheet().show(in: self,
                                   type: type,
                                   view: view,
                                   btnCloseAccessibilityLabel: localized("voiceover_closeHelp"), delegate: self)
                UIAccessibility.post(notification: .announcement, argument: localized(titleKey) + " " + localized(infoKey))
            }.store(in: &anySubscriptions)
        viewModel
            .state
            .case(SavingDetailState.bottomSheetInterest)
            .sink { [weak self] (titleKey, infoKey) in
                guard let self = self else { return }
                let type: SizablePresentationType = .custom(isPan: true, bottomVisible: true, tapOutsideDismiss: true)
                let view = SavingsBottomView()
                view.configure(titleKey: titleKey, infoKey: infoKey)
                self.bottomSheetScreenName = self.trackerPage.interestRatePage
                BottomSheet().show(in: self,
                                   type: type,
                                   view: view,
                                   btnCloseAccessibilityLabel: localized("voiceover_closeHelp"), delegate: self)
                UIAccessibility.post(notification: .announcement, argument: localized(titleKey) + " " + localized(infoKey))
            }.store(in: &anySubscriptions)
    }

    func bindCopyIconDetailCell(_ cell: SavingProductsHomeCollectionViewCell?) {
        cell?.copyIconTappedSubject
            .sink { [unowned self] in
                self.handleCopyFeedbackToastAnimation(show: true)
            }.store(in: &anySubscriptions)
    }

    func bindCopyFeedbackView() {
        copyFeedbackView.closeTappedSubject
            .sink { [unowned self] in
                self.handleCopyFeedbackToastAnimation(show: false)
            }.store(in: &anySubscriptions)
    }
}

extension SavingDetailViewController: BottomSheetViewProtocol {

    func didShow() {
        guard let bottomSheetScreenName = bottomSheetScreenName else {
            return
        }
        trackerManager.trackScreen(screenId: bottomSheetScreenName, extraParameters: [:])
    }

    func didTapCloseButton() {
        guard let bottomSheetScreenName = bottomSheetScreenName else {
            return
        }
        trackerManager.trackEvent(screenId: bottomSheetScreenName, eventId: SavingDetailPage.Action.clickCancel.rawValue, extraParameters: [:])
        self.bottomSheetScreenName = nil
    }
}

// MARK: - Analytics
extension SavingDetailViewController: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: SavingDetailPage {
        SavingDetailPage()
    }
}

extension SavingDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
