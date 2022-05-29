//
//  TipListViewController.swift
//  Menu
//
//  Created by Margaret on 04/08/2020.

import UIKit
import CoreFoundationLib
import UI

protocol TipListViewProtocol: AnyObject {
    func showTitle(_ title: String)
    func showTipList(viewModels: [TipDetailViewModel])
}

class TipListViewController: UIViewController {
    private var tableView: UITableView?
    private var homeTitle: String?
    private var tipList: [TipDetailViewModel]?
    private let presenter: TipListPresenterProtocol?
    private let tipCellBuilder = TipDetailBuilder()

    init(presenter: TipListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        self.configureTableView()
    }
}

private extension TipListViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: localized(homeTitle ?? "").text,
                                    header: .title(key: "toolbar_title_tips", style: .default))
        )
        .setRightActions(.menu(action: #selector(openMenu)))
        .setLeftAction(.back(action: #selector(didSelectDismiss)))
        builder.build(on: self, with: self.presenter)
        self.view.backgroundColor = UIColor.skyGray
    }

    func configureTableView() {
        let nibTipCell = UINib(nibName: TipDetailBuilder.tipCellIdentifier, bundle: .module)
        self.tableView = UITableView()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view.addSubview(tableView!)
        self.tableView?.fullFit()
        self.tableView?.register(nibTipCell, forCellReuseIdentifier: TipDetailBuilder.tipCellIdentifier)
        self.tableView?.separatorStyle = .none
        self.tableView?.allowsSelection = true
        self.tableView?.backgroundColor = .white
        self.tableView?.estimatedRowHeight = 44
        self.tableView?.rowHeight = UITableView.automaticDimension
        self.tableView?.sectionHeaderHeight = 51
        self.tableView?.accessibilityIdentifier = AccessibilityTipList.tipList.rawValue
    }

    @objc func didSelectDismiss() {
        self.presenter?.didSelectDismiss()
    }

    @objc func openMenu() {
        self.presenter?.didSelectMenu()
    }
}

extension TipListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tipList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.tipList?[indexPath.row] else { fatalError() }
        let cell = tipCellBuilder.cell(for: tableView, at: indexPath, viewModel: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TipListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        label.accessibilityIdentifier = AccessibilityTipList.titleLabel.rawValue
        label.textColor = .lisboaGray
        label.configureText(withKey: homeTitle ?? "",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18)))
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = self.tipList?[indexPath.row] else { return }
        self.presenter?.didSelectTip(offerId: viewModel.offerId)
    }
}

extension TipListViewController: TipListViewProtocol {
    func showTipList(viewModels: [TipDetailViewModel]) {
        self.tipList = viewModels
    }

    func showTitle(_ title: String) {
        self.homeTitle = title
    }   
}
