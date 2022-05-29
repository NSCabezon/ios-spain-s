//
//  LastMovementsViewController.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 15/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol LastMovementsViewProtocol: AnyObject {
    func setViewModel(_ viewModel: WhatsNewLastMovementsViewModel?, configuration: LastMovementsConfiguration)
    func showEmptyView()
    func configureNavigationBar(_ title: String)
}

final class LastMovementsViewController: UIViewController {
    
    @IBOutlet private weak var lastMovementsListView: LastMovementsListView!
    @IBOutlet private weak var lastMovementsListViewHeight: NSLayoutConstraint!
    
    let presenter: LastMovementsPresenterProtocol
    
    init(presenter: LastMovementsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "LastMovementsViewController", bundle: Bundle(for: LastMovementsViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
    }
}

private extension LastMovementsViewController {
    func configureView() {
        self.view.backgroundColor = .iceBlue
        self.lastMovementsListView.layer.cornerRadius = 6
        self.lastMovementsListView.drawRoundedAndShadowedNew()
        self.lastMovementsListView.delegate = self
    }

    @objc func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
}

extension LastMovementsViewController: LastMovementsViewProtocol {
    func setViewModel(_ viewModel: WhatsNewLastMovementsViewModel?, configuration: LastMovementsConfiguration) {
        guard let viewModel = viewModel else { return }
        self.lastMovementsListView.configList(viewModel, isSmallList: false, section: configuration.fractionableSection)
    }

    func showEmptyView() {
        self.lastMovementsListView.showEmptyView()
    }

    func configureNavigationBar(_ title: String) {
        NavigationBarBuilder(style: .clear(tintColor: .santanderRed),
                             title: .title(key: title))
            .setLeftAction(.back(action: #selector(dismissSelected)))
            .setRightActions(.close(action: #selector(dismissSelected)))
            .build(on: self, with: nil)
    }
}

extension LastMovementsViewController: LastMovementsListDelegate {
    func didSelectItem(_ item: UnreadMovementItem) {
        self.presenter.showMovementDetailForItem(item)
    }
    
    func didTapInGoToMoreMovements() { }
    
    func updatedTableView() {
        DispatchQueue.main.async {
            self.lastMovementsListViewHeight.constant = self.lastMovementsListView.tableView.contentSize.height
        }
    }
    
    func didTapCrossSellingButton(_ item: UnreadMovementItem) {
        self.presenter.loadCandidatesOffersForViewModel(item)
    }
}
