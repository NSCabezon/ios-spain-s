//
//  EasyPaySelectorViewController.swift
//  Cards
//
//  Created by alvola on 14/12/2020.
//

import UIKit
import Operative
import UI
import CoreFoundationLib

protocol EasyPaySelectorViewProtocol: OperativeView {
    func setTitle(_ title: LocalizedStylableText, subtitle: LocalizedStylableText)
    func setSections(_ sections: [EasyPayTableModelViewSection])
    func hideTopTexts()
}

final class EasyPaySelectorViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var topLabelsView: UIView!
    
    // TableModelViewSection
    private var sections: [EasyPayTableModelViewSection] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var operativePresenter: OperativeStepPresenterProtocol
    var presenter: EasyPaySelectorPresenterProtocol? {
        operativePresenter as? EasyPaySelectorPresenterProtocol
    }
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: EasyPaySelectorPresenterProtocol) {
        self.operativePresenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "EasyPayTitleTableViewCell", bundle: Bundle.module),
                           forCellReuseIdentifier: "EasyPayTitleTableViewCell")
        tableView.register(UINib(nibName: "EasyPaySeparatorTableViewCell", bundle: Bundle.module),
                           forCellReuseIdentifier: "EasyPaySeparatorTableViewCell")
        tableView.register(UINib(nibName: "EasyPayCardTableViewCell", bundle: Bundle.module),
                           forCellReuseIdentifier: "EasyPayCardTableViewCell")
        tableView.register(UINib(nibName: "EmptyViewCell", bundle: Bundle.module),
                           forCellReuseIdentifier: "EmptyViewCell")
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .bg
        view.backgroundColor = .bg
        topLabelsView.backgroundColor = .clear
        titleLabel.textColor = .sanGreyDark
        titleLabel.font = UIFont.santander(type: .bold, size: 16.0)
        subtitleLabel.textColor = .brownGray
        subtitleLabel.font = UIFont.santander(size: 14.0)
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

extension EasyPaySelectorViewController: EasyPaySelectorViewProtocol {
    var progressBarBackgroundColor: UIColor {
        .white
    }
    
    func setTitle(_ title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        titleLabel.configureText(withLocalizedString: title)
        subtitleLabel.configureText(withLocalizedString: subtitle)
    }
    
    func setSections(_ sections: [EasyPayTableModelViewSection]) {
        self.sections = sections
    }
    
    func hideTopTexts() {
        topLabelsView.isHidden = true
    }
}

private extension EasyPaySelectorViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .white,
                                           title: .title(key: "toolbar_title_easyPay"))
        builder.setRightActions(NavigationBarBuilder.RightAction.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
    
    @IBAction func back() {
        self.presenter?.close()
    }
    
    @IBAction func close() {
        self.presenter?.close()
    }
}

extension EasyPaySelectorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rowsCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = sections[indexPath.section].get(indexPath.row)
        guard let identifier = (info as? EasyPayTableViewModelProtocol)?.identifier,
              let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                       for: indexPath) as? EasyPayTableViewCellProtocol
            else { return UITableViewCell() }
        cell.setCellInfo(info as Any)
        return cell
    }
}

extension EasyPaySelectorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.presenter?.selected(index: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
        cell.setHighlighted()
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
        cell.setUnhighlighted()
    }
}
