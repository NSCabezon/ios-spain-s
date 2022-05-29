import UIKit
import UI

protocol HomeTipsViewProtocol: AnyObject {
    func showHomeTips(_ viewModel: [HomeTipsCellViewModel])
}
class HomeTipsViewController: UIViewController {
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let presenter: HomeTipsPresenterProtocol
    var homeTips: [HomeTipsCellViewModel] = []
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: HomeTipsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupTableView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
    }
}

private extension HomeTipsViewController {
    func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_tips")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(didPressDrawer)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc func dismissViewController() {
        self.presenter.didPressClose()
    }
    
    @objc func didPressDrawer() {
        self.presenter.didPressDrawer()
    }
    
    func setupView() {
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setupTableView() {
        let nib = UINib(nibName: "HomeTipsTableViewCell", bundle: .module)
        self.tableView.register(nib, forCellReuseIdentifier: HomeTipsTableViewCell.cellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 268.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
}

extension HomeTipsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeTips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTipsTableViewCell", for: indexPath) as? HomeTipsTableViewCell else {
            return UITableViewCell()
        }
        cell.setViewModels(viewModel: self.homeTips[indexPath.row], indexPath: indexPath)
        cell.tipDelegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? HomeTipsTableViewCell else { return }
        let contentOffset = cell.collectionView.contentOffset
        self.homeTips[indexPath.row].position = contentOffset
    }
}

extension HomeTipsViewController: HomeTipsViewProtocol {
    func showHomeTips(_ viewModel: [HomeTipsCellViewModel]) {
        self.homeTips = viewModel
        self.tableView.reloadData()
    }
}

extension HomeTipsViewController: HomeTipsTableViewCellDelegate {
    func didSelectTip(_ viewModel: HomeTipsViewModel) {
        self.presenter.didSelectOffer(viewModel.offerId)
    }
    
    func didSelectAll(_ indexPath: IndexPath) {
        self.presenter.didSelectAll(section: self.homeTips[indexPath.row].title,
                                    content: self.homeTips[indexPath.row].content)
    }
    
    func scrollViewDidEndDecelerating() {}
}
