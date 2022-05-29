//
//  CardSelectorStepViewController.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 7/9/21.
//

import Foundation
import UIKit
import Operative
import UI
import CoreFoundationLib

protocol CardSelectorStepViewProtocol: OperativeView {
    func setNavigationBar(with title: String)
    func loadCardSelectorList(_ viewModels: [CardboardingCardCellViewModel])
    func showErrorDialog(_ error: String)
}

final class CardSelectorStepViewController: UIViewController {
    @IBOutlet var tableView: CardSelectorListTableView!
    private let presenter: CardSelectorStepPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: CardSelectorStepPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
}

private extension CardSelectorStepViewController {
    func setupView() {
        view.backgroundColor = .white
        tableView.tableDelegate = self
    }
    
    @objc func close() {
        presenter.didTapClose()
    }
    
    @objc func goBack() {
        presenter.didTapGoBack()
    }
}

extension CardSelectorStepViewController: CardSelectorStepViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        presenter
    }
    
    func loadCardSelectorList(_ viewModels: [CardboardingCardCellViewModel]) {
        tableView.configView(viewModels)
    }
           
    func setNavigationBar(with title: String) {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: title)
        )
        builder.setLeftAction(.back(action: #selector(goBack)))
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
    
    func showErrorDialog(_ error: String) {
        let descriptionTextConfiguration = LocalizedStylableTextConfiguration(alignment: .center)
        self.showDialog(items: [.styledConfiguredText(localized(error),
                                                            configuration: descriptionTextConfiguration)],
                              image: nil,
                              action: .some(Dialog.Action(title: "generic_button_understand",
                                                  style: .red,
                                                  action: {})),
                              isCloseOptionAvailable: false)
    }
}

extension CardSelectorStepViewController: CardSelectorListTableViewDelegate {
    func didTapInCard(_ viewModel: CardboardingCardCellViewModel) {
        presenter.didSelectCard(viewModel)
    }
}
