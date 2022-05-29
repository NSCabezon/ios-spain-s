//
//  OldLoanTransactionDetailViewController.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 19/8/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol LoanTransactionDetailViewProtocol: AnyObject {
    func showTransactions(_ viewModels: [OldLoanTransactionDetailViewModel], withSelected selected: OldLoanTransactionDetailViewModel)
    func showActions(_ viewModels: [LoanTransactionDetailActionViewModel])
    func updateTransaction(with detail: OldLoanTransactionDetailViewModel)
}

final class OldLoanTransactionDetailViewController: UIViewController {
    let presenter: LoanTransactionDetailPresenterProtocol
    private var actionButtons = LoanTransactionDetailActionsView()
    private var transactionCollectionView = OldLoanTransactionCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var referenceView: UIView!
    @IBOutlet private weak var safeAreaBackground: UIView!
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: LoanTransactionDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
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
}

private extension OldLoanTransactionDetailViewController {
    func setupViews() {
        self.view.backgroundColor = UIColor.skyGray
        self.referenceView.backgroundColor = UIColor.skyGray
        self.safeAreaBackground.backgroundColor = UIColor.skyGray
        self.stackView.addArrangedSubview(transactionCollectionView)
        self.stackView.addArrangedSubview(actionButtons)
    }

    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_movesDetail")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc func mapSelected() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissViewController() {
        self.presenter.dismiss()
    }
}

extension OldLoanTransactionDetailViewController: LoanTransactionDetailViewProtocol {
    
    func showTransactions(_ viewModels: [OldLoanTransactionDetailViewModel], withSelected selected: OldLoanTransactionDetailViewModel) {
        self.transactionCollectionView.updateTransactionViewModel(viewModels, selectedViewModel: selected)
    }
    
    func updateTransaction(with detail: OldLoanTransactionDetailViewModel) {
        self.transactionCollectionView.updateTransactionViewModel(detail)
    }
    
    func showActions(_ viewModels: [LoanTransactionDetailActionViewModel]) {
        self.actionButtons.removeSubviews()
        self.actionButtons.setViewModels(viewModels)
    }
}

extension OldLoanTransactionDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
