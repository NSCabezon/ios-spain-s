//
//  CardBoardingCardsSelectorViewController.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/01/2021.
//
import UI
import CoreFoundationLib

protocol CardBoardingCardsSelectorPresenterViewProtocol: AnyObject {}

final class CardBoardingCardsSelectorViewController: UIViewController {
    private let presenter: CardBoardingCardsSelectorPresenterProtocol
    @IBOutlet weak private var tableView: UITableView!
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: CardBoardingCardsSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupTableView()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        let tableHeaderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 36.0))
        tableHeaderLabel.accessibilityIdentifier = AccessibilityCardBoardingCardsSelector.tableHeaderLabel
        tableHeaderLabel.textAlignment = .left
        tableHeaderLabel.setHeadlineTextFont(type: .regular, size: 18.0, color: .lisboaGray)
        tableHeaderLabel.configureText(withKey: "cardboarding_label_chooseCardConfigure")
        self.tableView.tableHeaderView = tableHeaderLabel
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_configureCards")
        )
        builder.setLeftAction(.back(action: #selector(didTapBack)))
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
}

extension CardBoardingCardsSelectorViewController {
    @objc func didTapBack() {
        self.presenter.didTapBack()
    }
    
    @objc func close() {
        self.presenter.didTapClose()
    }
}

extension CardBoardingCardsSelectorViewController: CardBoardingCardsSelectorPresenterViewProtocol {}

private extension CardBoardingCardsSelectorViewController {
    func setupTableView() {
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .none
        let cellNib = UINib(nibName: CardboardingCardCell.nibName, bundle: .module)
        self.tableView.register(cellNib, forCellReuseIdentifier: CardboardingCardCell.identifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension CardBoardingCardsSelectorViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = presenter.getCardsViewModel()
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let optionalCell = tableView.dequeueReusableCell(withIdentifier: CardboardingCardCell.identifier,
                                                               for: indexPath) as? CardboardingCardCell else {
            return UITableViewCell()
        }
        let item = presenter.getCardsViewModel()[indexPath.row]
        optionalCell.configureCellWithModel(model: item)
        return optionalCell
    }
}

// MARK: - UITableViewDelegate
extension CardBoardingCardsSelectorViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CardboardingCardCell.heightForRow
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = presenter.getCardsViewModel()[indexPath.row]
        self.presenter.didSelectItem(selectedItem)
    }
}
