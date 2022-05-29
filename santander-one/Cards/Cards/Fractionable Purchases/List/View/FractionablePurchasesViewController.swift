//
//  FractionablePurchasesViewController.swift
//  Cards
//
//  Created by César González Palomino on 12/02/2021.
//

import UI
import CoreFoundationLib

protocol FractionablePurchasesViewProtocol: AnyObject {
    func setupHeaderWith(_ viewModel: FractionablePurchasesHeaderViewModel)
    func showFractionableMovements(_ viewModel: [FractionableMovementCollectionViewModel])
    func showFractionatedMovements(_ viewModel: [FractionableMovementViewModel])
    func showSettledMovements(_ viewModel: [FractionableMovementViewModel])
    func showEmptyView()
    func showLoading(_ show: Bool)
}

extension FractionablePurchasesViewController: LoadingViewPresentationCapable {
    
}

final class FractionablePurchasesViewController: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var headerView: FractionablePurchasesHeaderView!
    @IBOutlet private weak var bottomView: FractionableCarrouselView!
    @IBOutlet private weak var bottomSafeAreaView: UIView!
    @IBOutlet private weak var bottomViewHeight: NSLayoutConstraint!
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: self.containerView)
        view.setScrollInsets(UIEdgeInsets(top: 16, left: 0.0, bottom: 16.0, right: 0.0))
        view.setSpacing(8.0)
        return view
    }()
    
    private var completedIsVisible = false
    private var separator: ShowCompletedMovementsView?
    private var completedCells: [FractionableMovementView]?
    private let presenter: FractionablePurchasesPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: FractionablePurchasesPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        NavigationBarBuilder(
            style: .custom(background: .color(.skyGray), tintColor: .santanderRed),
            title: .title(key: "toolbar_title_instalmentsPurchases"))
        .setLeftAction(.back(action: #selector(dismissViewController)))
        .setRightActions(.menu(action: #selector(openMenu)))
        .build(on: self, with: self.presenter)
    }
}

extension FractionablePurchasesViewController: FractionablePurchasesViewProtocol {
    
    func setupHeaderWith(_ viewModel: FractionablePurchasesHeaderViewModel) {
        headerView.setInfo(viewModel)
    }
    
    func showFractionatedMovements(_ viewModel: [FractionableMovementViewModel]) {
        viewModel.forEach { (viewModel) in
            let view = FractionableMovementView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.drawBorderAndShadow()
            scrollableStackView.addArrangedSubview(view)
            view.setInfo(viewModel, delegate: self)
        }
    }
    
    func showFractionableMovements(_ viewModels: [FractionableMovementCollectionViewModel]) {
        bottomView.setInfo(viewModels)
        hideBottomCarrousel(viewModels.isEmpty)
    }
    
    func showSettledMovements(_ viewModel: [FractionableMovementViewModel]) {
        let isViewEmpty = scrollableStackView.getArrangedSubviews().isEmpty
        if !isViewEmpty {
            addSeparator()
        }
        completedCells = viewModel.map { (viewModel) in
            let view = FractionableMovementView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.drawBorderAndShadow()
            scrollableStackView.addArrangedSubview(view)
            view.setInfo(viewModel, delegate: self)
            view.isHidden = !isViewEmpty
            return view
        }
    }
    
    func showEmptyView() {
        clearView()
        let view = SingleEmptyView()
        view.titleFont(UIFont.santander(family: .headline,
                                        size: 20.0))
        view.updateTitle(localized("fractionatePurchases_text_emptyView"))
        scrollableStackView.addArrangedSubview(view)
    }
    
    func showLoading(_ show: Bool) {
        show ? self.showLoading() : self.dismissLoading()
    }
}

private extension FractionablePurchasesViewController {
    func configureView() {
        bottomSafeAreaView.backgroundColor = .blueAnthracita
        scrollableStackView.setScrollDelegate(self)
        headerView.layer.masksToBounds = false
        headerView.drawShadow(offset: 0.0, opaticity: 0.3, color: .black, radius: 0.0)
        bottomView.delegate = self
        hideBottomCarrousel(true)
    }
    
    func hideBottomCarrousel(_ hide: Bool) {
        bottomView.isHidden = hide
        bottomSafeAreaView.isHidden = hide
        bottomViewHeight.constant = hide ? 0.0 : 200.0
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func separatorPressed() {
        completedIsVisible = !completedIsVisible
        separator?.isOpen(completedIsVisible)
        completedCells?.forEach({
            $0.isHidden = !completedIsVisible
        })
    }
    
    func addSeparator() {
        let view = ShowCompletedMovementsView(frame: .zero)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(separatorPressed)))
        view.isUserInteractionEnabled = true
        scrollableStackView.addArrangedSubview(view)
        separator = view
    }
    
    func clearView() {
        scrollableStackView.getArrangedSubviews().forEach {
            scrollableStackView.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}

extension FractionablePurchasesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.headerView.layer.shadowRadius = scrollView.contentOffset.y > 0.0 ? 2.0 : 0.0
    }
}

extension FractionablePurchasesViewController: FractionableCarrouselViewDelegate {
    func showAllFractionableMovements() {
        presenter.showAllFractionableMovements()
    }
    
    func didSelectElegiblePurchase(_ purchase: FractionableMovementCollectionViewModel) {
        presenter.didSelectElegiblePurchase(purchase)
    }
    
    func didSelectViewMore() {
        presenter.didSelectViewMore()
    }

    func didSwipe() {
        presenter.didSwipeFractionableCarousel()
    }
}

extension FractionablePurchasesViewController: FractionableMovementViewDelegate {
    func didSelectMovement(_ movement: FractionableMovementView) {
        presenter.didSelectMovement(movement.model)
    }
}
