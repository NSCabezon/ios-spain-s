//
//  SearchEmittersViewController.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import UIKit
import UI
import Operative
import CoreFoundationLib

protocol SearchEmittersViewProtocol: OperativeView {
    func showEmittersEmpty()
    func showEmitters(_ viewModels: [EmitterViewModel])
    func updateEmitter(viewModel: EmitterViewModel)
    func showSearchingView()
    func showFrequentEmitter()
    func setFrecuentEmitterHidden()
    func showAccountDetail(name: String, amaunt: String)
    func showPageLoading()
    func hidePageLoading()
    func showFaqs(_ items: [FaqsItemViewModel])
}

class SearchEmittersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editAccountView: UIView!
    private let presenter: SearchEmittersPresenterProtocol
    private let editAccountOperativeHeader = EditAccountOperativeHeader()
    private let emitterTableViewHeader = EmitterTableViewHeader()
    private let searchTableViewFooter = SearchTableViewFooter()
    private let emitterDatasource = EmitterTableViewDatasource(state: .loading)
    private let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    private let cellIdentifiers = [
        EmitterHeaderTableViewCell.identifier,
        EmitterElementTableViewCell.identifier,
        EmitterFooterTableViewCell.identifier,
        EmitterLoadingTableViewCell.identifier,
        EmitterEmptyTableViewCell.identifier,
        ElementLoadingTableViewCell.identifier
    ]
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: SearchEmittersPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupTableViewDatasource()
        self.setupNavigationBar()
        self.setAppearance()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
}

private extension SearchEmittersViewController {
    func setAppearance() {
        self.editAccountOperativeHeader.delegate = self 
        self.editAccountView.addSubview(editAccountOperativeHeader)
        self.editAccountOperativeHeader.getBottomLine()
            .addShadow(location: .bottom, color: .clear, opacity: 1, height: -2.5)
    }
    
    func setupTableView() {
        self.tableView.allowsSelection = true
        self.tableView.bounces = false
        self.tableView.backgroundColor = .white
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableHeaderView = emitterTableViewHeader
        self.tableView.contentInset = self.contentInset
        self.emitterTableViewHeader.setDelegate(self)
        self.registerCells()
    }
    
    func setupTableViewDatasource() {
        self.emitterDatasource.setDelegate(delegate: self)
        self.tableView.dataSource = emitterDatasource
        self.tableView.delegate = emitterDatasource
    }
    
    func registerCells() {
        cellIdentifiers.forEach {
            let nib = UINib(nibName: $0, bundle: .module)
            self.tableView.register(nib, forCellReuseIdentifier: $0)
        }
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(
                titleKey: "receiptsAndTaxes_label_paymentOfReceipts",
                header: .title(key: "toolbar_title_paymentOther", style: .default)
            ))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    @objc func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc func close() {
        presenter.didTapClose()
    }
}

extension SearchEmittersViewController: SearchEmittersViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
    
    func showSearchingView() {
        self.emitterDatasource.didStateChanged(.loading)
        self.tableView.reloadData()
    }
    
    func showEmittersEmpty() {
        self.emitterDatasource.didStateChanged(.empty)
        self.tableView.reloadData()
    }
    
    func showEmitters(_ viewModels: [EmitterViewModel]) {
        self.emitterDatasource.didStateChanged(.filled(viewModels))
        self.tableView.reloadData()
    }
    
    func updateEmitter(viewModel: EmitterViewModel) {
        self.emitterDatasource.updateEmitterViewModel(viewModel)
    }
    
    func showFrequentEmitter() {
        self.emitterTableViewHeader.showFrecuentEmitter()
        self.tableView.updateHeaderWithAutoLayout()
    }
    
    func setFrecuentEmitterHidden() {
        self.emitterTableViewHeader.setFrecuentEmitterHidden()
        self.tableView.updateHeaderWithAutoLayout()
    }
    
    func showAccountDetail(name: String, amaunt: String) {
        let viewModel = EditAccountViewModel(
            title: "generic_label_paymentAccount",
            subTitle: name,
            amount: amaunt)
        self.editAccountOperativeHeader.setViewModel(viewModel)
    }
    
    func showEditAccount(_ viewModel: EditAccountViewModel) {
        self.editAccountOperativeHeader.setViewModel(viewModel)
    }
    
    func showPageLoading() {
        let size = CGSize(width: tableView.bounds.width, height: 68)
        let frame = CGRect(origin: .zero, size: size)
        self.searchTableViewFooter.frame = frame
        self.searchTableViewFooter.startLoading()
        self.tableView.tableFooterView = searchTableViewFooter
        self.tableView.scrollRectToVisible(searchTableViewFooter.frame, animated: true)
    }
    
    func hidePageLoading() {
        self.searchTableViewFooter.stopLoading()
        self.tableView.tableFooterView = nil
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension SearchEmittersViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension SearchEmittersViewController: EmitterTableViewDatasourceDelegate {
    func didSelectEmitterViewModel(_ viewModel: EmitterViewModel) {
        self.presenter.didSelectEmitter(viewModel)
    }
    
    func didSelectIncomeViewModel(_ viewModel: IncomeViewModel, emitterViewModel: EmitterViewModel) {
        self.presenter.didSelectIncomeViewModel(viewModel, emitterViewModel: emitterViewModel)
    }
    
    func reloadCellSection(_ section: Int) {
        self.tableView.reloadSections([section], with: .none)
    }
    
    func reloadCellSection(_ cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        self.tableView.beginUpdates()
        self.tableView.reloadSections([indexPath.section], with: .none)
        self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        self.tableView.endUpdates()
    }
    
    func tableViewDidReachTheEndOfTheList() {
        self.presenter.loadMoreEmitters()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.self.editAccountOperativeHeader.getBottomLine().layer.shadowColor =
            scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}

extension SearchEmittersViewController: EmitterTableViewHeaderDelegate {
    func searchEmitterBy(emitterCode: String) {
        self.view.endEditing(true)
        self.emitterDatasource.setSearchTerm(emitterCode)
        self.presenter.searchBy(emitterCode: emitterCode)
    }
}

extension SearchEmittersViewController: EditAccountOperativeHeaderDelegate {
    func didSelectEditAccount() {
        self.presenter.didSelectEditAccount()
    }
}
