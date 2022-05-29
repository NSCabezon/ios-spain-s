//
//  CardSelectorListViewController.swift
//  Cards
//
//  Created by Ignacio González Miró on 10/6/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol CardSelectorListGenericViewProtocol: OldDialogViewPresentationCapable {
    var presenter: CardSelectorListPresenterProtocol { get }
    func loadCardSelectorList(_ viewModels: [CardboardingCardCellViewModel])
    func showLoadingView()
    func hideLoadingView(_ completion: (() -> Void)?)
    func setNavigationBar(with title: String)
}

final class CardSelectorListViewController: UIViewController {
    @IBOutlet private weak var tableView: CardSelectorListTableView!
    
    var presenter: CardSelectorListPresenterProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver, presenter: CardSelectorListPresenterProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.presenter = presenter
        super.init(nibName: "CardSelectorListViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
}

private extension CardSelectorListViewController {
    func setView() {
        view.backgroundColor = .white
        tableView.tableDelegate = self
    }
    
    @objc func didTapBack() {
        self.presenter.didTapBack()
    }
    
    @objc func close() {
        self.presenter.didTapClose()
    }
}

extension CardSelectorListViewController: CardSelectorListGenericViewProtocol {
    func loadCardSelectorList(_ viewModels: [CardboardingCardCellViewModel]) {
        tableView.configView(viewModels)
    }
           
    func setNavigationBar(with title: String) {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: title)
        )
        builder.setLeftAction(.back(action: #selector(didTapBack)))
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
}

extension CardSelectorListViewController: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView() {
        self.showLoading()
    }
    
    func hideLoadingView(_ completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
}

extension CardSelectorListViewController: CardSelectorListTableViewDelegate {
    func didTapInCard(_ viewModel: CardboardingCardCellViewModel) {
        presenter.didTapInCard(viewModel)
    }
}
