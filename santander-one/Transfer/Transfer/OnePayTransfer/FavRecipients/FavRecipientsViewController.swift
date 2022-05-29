//
//  FavRicipientsViewController.swift
//  Transfer
//
//  Created by Ignacio González Miró on 26/05/2020.
//

import UIKit
import CoreFoundationLib

protocol FavRecipientProtocol: AnyObject {
    func recipientSelected(_ viewModel: ContactListItemViewModel)
}

final class FavRecipientsViewController: UIViewController {
    @IBOutlet weak private var headerBackgroundView: UIView!
    @IBOutlet weak private var headerView: FavRecipientsHeaderView!
    @IBOutlet weak private var tableView: FavRecipientsTableView!
    
    let presenter: FavRecipientsPresenterProtocol?
    var viewModel: [ContactListItemViewModel]?
    var country: String = ""
    weak var recipientDelegate: FavRecipientProtocol?
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: FavRecipientsPresenterProtocol? = nil) {
        self.presenter = presenter
        self.viewModel = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(presenter: FavRecipientsPresenterProtocol? = nil) {
        self.init(nibName: "FavRecipientsViewController", bundle: .module, presenter: presenter)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupHeader()
    }
}

private extension FavRecipientsViewController {
    func setupHeader() {
        self.headerView.textInHeader(localized("transfer_label_favoriteRecipients"))
        self.headerView.delegate = self
        headerBackgroundView.backgroundColor = .skyGray
    }

    func setupTableView() {
        guard let viewModel = self.viewModel else { return }
        self.tableView.setViewModels(viewModel, country: self.country)
        self.tableView.favRecipientDelegate = self
        self.tableView.register(FavRecipientTableViewCell.self, bundle: Bundle.module)
        self.tableView.register(FavRecipientEmptyTableViewCell.self, bundle: Bundle.module)
    }
}

extension FavRecipientsViewController: FavRecipientsHeaderViewProtocol {
    func didTapOnBack() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FavRecipientsViewController: FavRecipientsTableViewDelegate {
    func didSelectFavRecipient(_ viewModel: ContactListItemViewModel) {
        recipientDelegate?.recipientSelected(viewModel)
        self.dismiss(animated: true, completion: nil)
    }
}
