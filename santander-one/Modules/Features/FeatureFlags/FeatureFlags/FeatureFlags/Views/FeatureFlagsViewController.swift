//
//  FeatureFlagsViewController.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import CoreDomain
import UIOneComponents
import CoreFoundationLib

final class FeatureFlagsViewController: UIViewController {
    
    private let viewModel: FeatureFlagsViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: FeatureFlagsDependenciesResolver
    private lazy var dataSource: DataSource = {
        return DataSource(tableView: tableView)
    }()
    
    // MARK: - UI components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .skyGray
        let label = UILabel()
        label.textColor = .oneLisboaGray
        label.font = .typography(fontName: .oneH200Regular)
        label.text = "Configure options"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label, topMargin: .oneSizeSpacing20, bottomMargin: .oneSizeSpacing20, leftMargin: .oneSizeSpacing16, rightMargin: .oneSizeSpacing16)
        return view
    }()
    private lazy var footer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.setTitle(localized("generic_button_save"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .oneBostonRed
        button.layer.cornerRadius = 24
        button.accessibilityIdentifier = "generic_button_save"
        button.addTarget(self, action: #selector(saveSelected), for: .touchUpInside)
        view.addSubview(button)
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: OneSpacingType.oneSizeSpacing16.value).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -OneSpacingType.oneSizeSpacing16.value).isActive = true
        button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: OneSpacingType.oneSizeSpacing16.value).isActive = true
        if #available(iOS 11.0, *) {
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -OneSpacingType.oneSizeSpacing16.value).isActive = true
        } else {
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -OneSpacingType.oneSizeSpacing16.value).isActive = true
        }
        return view
    }()
    
    init(dependencies: FeatureFlagsDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
}

private extension FeatureFlagsViewController {
    func setAppearance() {
        addFooter()
        addHeader()
        addTableView()
        addNavigationBar()
    }
    
    func addNavigationBar() {
        let builder = NavigationBarItemBuilder(dependencies: dependencies.external)
        builder.addStyle(.sky)
        builder.addRightAction(.close, associatedAction: .closure { [weak self] in
            self?.viewModel.dismiss()
        })
        builder.addTitle(.title(key: "Feature flags", identifier: nil))
        builder.build(on: self)
    }
    
    func addHeader() {
        view.addSubview(header)
        if #available(iOS 11.0, *) {
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            header.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        header.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    func addFooter() {
        view.addSubview(footer)
        footer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        footer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        footer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    func addTableView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: footer.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.register(BooleanFeatureFlagTableViewCell.self, forCellReuseIdentifier: "BooleanFeatureFlagTableViewCell")
    }
    
    func bind() {
        bindLoadedFeatureFlags()
        bindFeatureChanged()
    }
    
    func bindLoadedFeatureFlags() {
        viewModel.state
            .case(FeatureFlagsState.loaded)
            .map { $0.map(TableViewItem.init) }
            .assign(to: \.items, on: dataSource)
            .store(in: &subscriptions)
    }
    
    func bindFeatureChanged() {
        dataSource.publisher
            .sink { value in
                self.viewModel.featureDidUpdate(value)
            }.store(in: &subscriptions)
    }
}

private extension FeatureFlagsViewController {
    
    @objc func saveSelected() {
        viewModel.save()
    }
    
    enum TableViewItem {
        case boolean(FeatureFlagRepresentable, value: Bool)
        
        init(feature: FeatureFlagWithValue) {
            switch feature.value {
            case .boolean(let value): self = .boolean(feature.feature, value: value)
            }
        }
    }
    
    final class DataSource: NSObject, UITableViewDataSource {
        
        var items: [TableViewItem] = [] {
            didSet {
                tableView?.reloadData()
            }
        }
        weak var tableView: UITableView?
        private var subscriptions: Set<AnyCancellable> = []
        private var subject = PassthroughSubject<FeatureFlagWithValue, Never>()
        var publisher: AnyPublisher<FeatureFlagWithValue, Never> {
            return subject.eraseToAnyPublisher()
        }
        
        init(tableView: UITableView) {
            self.tableView = tableView
            super.init()
            tableView.dataSource = self
        }
        
        private func cell(for item: TableViewItem, at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
            switch item {
            case .boolean(let feature, value: let value):
                let cell = tableView.dequeueReusableCell(BooleanFeatureFlagTableViewCell.self, indexPath: indexPath)
                cell.setup(with: feature, value: value)
                cell.publisher
                    .map {  FeatureFlagWithValue(feature: feature.eraseToAnyFeature(), value: .boolean($0)) }
                    .subscribe(subject)
                    .store(in: &subscriptions)
                return cell
            }
        }
        
        // MARK: - UITableViewDataSource
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return cell(for: items[indexPath.row], at: indexPath, in: tableView)
        }
    }
}
