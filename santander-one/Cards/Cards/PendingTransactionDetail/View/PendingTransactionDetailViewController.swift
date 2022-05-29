//
//  PendingTransactionDetailViewController.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/16/20.
//

import UI
import UIKit

protocol PendingTransactionDetailView: AnyObject {
    func showTransaction(_ selectedViewModel: PendingTransactionDetailViewModel, viewModels: [PendingTransactionDetailViewModel])
    func showActions(_ viewModels: [CardActionViewModel])
}

class PendingTransactionDetailViewController: UIViewController {
    private let presenter: PendingTransactionDetailPresenterProtocol
    private let scrollableStackView = ScrollableStackView()
    private let transactionDetailActions = OldCardTransactionDetailActions()
    private var pendingTransactionCollectionView = PendingTransactionCollectionView(frame: .zero, collectionViewLayout: ZoomAndSnapFlowLayout())
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: PendingTransactionDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky, title: .title(key: "toolbar_title_movesDetail"))
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func setupViews() {
        self.view.backgroundColor = .skyGray
        self.pendingTransactionCollectionView.setDelegate(self)
        self.scrollableStackView.setup(with: self.view)
        self.scrollableStackView.addArrangedSubview(self.pendingTransactionCollectionView)
        self.scrollableStackView.addArrangedSubview(self.transactionDetailActions)
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
}

extension PendingTransactionDetailViewController: PendingTransactionDetailView {
    func showTransaction(_ selectedViewModel: PendingTransactionDetailViewModel, viewModels: [PendingTransactionDetailViewModel]) {
        self.pendingTransactionCollectionView.setViewModels(selectedViewModel, viewModels: viewModels)
    }
    
    func showActions(_ viewModels: [CardActionViewModel]) {
        self.transactionDetailActions.removeSubviews()
        self.transactionDetailActions.setViewModels(viewModels)
    }
}

extension PendingTransactionDetailViewController: PendingTransactionCollectionViewDelegate {
    func didSelectViewModel(_ viewModel: PendingTransactionDetailViewModel) {
        self.presenter.didSelectViewModel(viewModel)
    }
}
