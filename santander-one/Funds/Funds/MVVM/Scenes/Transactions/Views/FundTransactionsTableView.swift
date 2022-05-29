//
//  FundTransactionsTableView.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 29/3/22.
//

import UI
import UIKit
import OpenCombine
import CoreDomain

final class FundTransactionsTableView: UITableView {
    let bindableDatasource = Datasource()
    private var anySubscriptions = Set<AnyCancellable>()
    let didLoadMoreMovementsSubject = PassthroughSubject<Void, Never>()
    
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.setupView()
        self.bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        setupStateCells()
        self.bind()
    }

    func clean() {
        bindableDatasource.movementItem = []
        bindableDatasource.movementsBind = nil
    }

    func changeInfoState(infoState: Datasource.InfoViewState, reload: Bool = true) {
        bindableDatasource.infoState = infoState
        if reload {
            reloadSections([Datasource.Sections.info.rawValue], with: .none)
        }
    }
}

private extension FundTransactionsTableView {
    func setupView() {
        self.backgroundColor = .white
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.dataSource = self.bindableDatasource
        self.delegate = self.bindableDatasource
    }

    func setupStateCells() {
        registerCell("FundTransactionsPaginationLoadingViewCell")
        registerCell("FundTransactionsLoadingViewCell")
        registerCell("FundTransactionsEmptyListCell")
    }
}

private extension FundTransactionsTableView {
    func bind() {
        self.bindableDatasource.moreItemsBind = {
            self.didLoadMoreMovementsSubject.send()
        }
    }
}

extension FundTransactionsTableView {
    func registerCell(_ identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellReuseIdentifier: identifier)
    }

    func bind<Cell: FundHeaderTableViewCell>(headerItem: FundMovements, completion: @escaping (IndexPath, Cell?, FundMovements) -> Void) {
        self.registerCell("FundHeaderTableViewCell")
        self.bindableDatasource.setHeaderItem(headerItem)
        self.bindableDatasource.headerBind = { (indexPath, cell) in
            completion(indexPath, cell as? Cell, headerItem)
        }
    }

    func bind<Cell: FundTransactionTableViewCell>(movementItem: FundMovements, completion: @escaping (IndexPath, Cell?, FundMovements?, FundTransactionTableViewCellModel?) -> Void) {
        self.registerCell("FundTransactionTableViewCell")
        self.bindableDatasource.setItems(movementItem)
        self.bindableDatasource.movementsBind = { (indexPath, cell) in
            completion(indexPath, cell as? Cell, movementItem, self.bindableDatasource.movementItem?[indexPath.row] )
        }
    }
}

extension FundTransactionsTableView {
    typealias cellBinds = (IndexPath, UITableViewCell) -> Void?
    typealias moreItemsBind = () -> Void?

    class Datasource: NSObject, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
        var headerItem: FundMovements?
        var headerBind: cellBinds?
        var movementItem: [FundTransactionTableViewCellModel]? = []
        var movementsBind: cellBinds?
        var moreItemsBind: moreItemsBind?
        let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
        let scrollViewDidEndDecelerating = PassthroughSubject<CGPoint, Never>()
        var infoState: InfoViewState = .none

        enum InfoViewState {
            case empty
            case loading
            case loadingPage
            case none
        }

        enum Sections: Int {
            case header = 0
            case transactions = 1
            case info = 2
        }

        func setItems(_ element: FundMovements) {
            self.headerItem = element
            let temp = element.movements.map({ fundMovementRepresentable -> FundTransactionTableViewCellModel in
                let model = FundTransactionTableViewCellModel()
                model.isOpened = false
                model.movement = fundMovementRepresentable
                return model
            })
            movementItem?.append(contentsOf: temp)
        }

        func setHeaderItem(_ element: FundMovements) {
            self.headerItem = element
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            return 3
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
            case Sections.header.rawValue:
                return headerItem != nil ? 1 : 0
            case Sections.transactions.rawValue:
                return movementItem?.count ?? 0
            case Sections.info.rawValue:
                return infoState != .none ? 1 : 0
            default:
                return 0
            }
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == Sections.header.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FundHeaderTableViewCell", for: indexPath)
                self.headerBind?(indexPath, cell)
                return cell
            }

            if indexPath.section == Sections.transactions.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FundTransactionTableViewCell", for: indexPath)
                self.movementsBind?(indexPath, cell)
                return cell
            }

            if indexPath.section == Sections.info.rawValue {
                switch infoState {
                case .empty:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FundTransactionsEmptyListCell", for: indexPath)
                    return cell
                case .loading:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FundTransactionsLoadingViewCell", for: indexPath)
                    return cell
                case .loadingPage:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FundTransactionsPaginationLoadingViewCell", for: indexPath)
                    return cell
                case .none:
                    return UITableViewCell()
                }
            }
            return UITableViewCell()
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let items = movementItem else {
                return
            }
            if indexPath.section == Sections.transactions.rawValue, indexPath.row == items.count - 1, let headerItem = headerItem {
                self.moreItemsBind?()
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.scrollViewDidScroll.send(scrollView.contentOffset)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.scrollViewDidEndDecelerating.send(scrollView.contentOffset)
        }
    }
}
