//
//  PersonalAreaHomeViewController.swift
//  PersonalArea
//
//  Created by alvola on 4/4/22.
//

import UIKit
import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine

final class PersonalAreaHomeViewController: UIViewController {
    
    @IBOutlet weak var header: PersonalAreaUserNameHeader!
    @IBOutlet weak var tableView: UITableView!
    
    private let dependencies: PersonalAreaHomeDependenciesResolver
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    private let viewModel: PersonalAreaHomeViewModel
    private var subscriptions: Set<AnyCancellable> = []
    var didSelectPhotoActionSubject = PassthroughSubject<PhotoType, Never>()
    private lazy var tableController: ReactivePersonalAreaTableViewController = {
        return ReactivePersonalAreaTableViewController(tableView: self.tableView)
    }()
    private lazy var photoHelperReactive: PhotoHelperReactive = {
        PhotoHelperReactive(associatedViewController: self)
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(dependencies: PersonalAreaHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.navigationBarItemBuilder = dependencies.external.resolve()
        self.viewModel = dependencies.resolve()
        super.init(nibName: "PersonalAreaMainModuleViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bindTableConfiguration()
        bindUsername()
        bindUserAvatar()
        bindHeaderActions()
        bindTableSelection()
        bindSelectPhotoAction()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        viewModel.viewBecomeActive()
    }
}

private extension PersonalAreaHomeViewController {
    func configureNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_personalArea"))
            .addLeftAction(.back, selector: #selector(didPressBack))
            .addRightAction(.menu, selector: #selector(didPressMenu))
            .addRightAction(.search(position: 1),
                            selector: #selector(didPressSearch))
            .build(on: self)
    }
    
    func configureView() {
        view.backgroundColor = UIColor.white
        tableView?.backgroundColor = UIColor.clear
        tableView?.separatorStyle = .none
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 92
    }
    
    @objc private func didPressBack() {
        viewModel.didSelectBack()
    }

    @objc private func didPressMenu() {
        viewModel.didSelectMenu()
    }
    
    @objc private func didPressSearch() {
        viewModel.searchAction()
    }
}

private extension PersonalAreaHomeViewController {
    func bindTableConfiguration() {
        viewModel.state
            .case(PersonalAreaHomeState.homeFieldsLoaded)
            .sink { [unowned self] cells in
                tableController.cellsInfo = cells
                tableView.reloadData()
                tableView.scrollToNearestSelectedRow(at: .none, animated: true)
            }
            .store(in: &subscriptions)
    }
    
    func bindUsername() {
        viewModel.state
            .case(PersonalAreaHomeState.usernameLoaded)
            .sink { [unowned self] username in
                header.setUsername(username ?? "")
            }
            .store(in: &subscriptions)
    }
    
    func bindUserAvatar() {
        viewModel.state
            .case(PersonalAreaHomeState.avatarLoaded)
            .sink { [unowned self] data in
                header.setImage(UIImage(data: data))
            }
            .store(in: &subscriptions)
    }
    
    func bindHeaderActions() {
        header.didSelectActionSubject
            .sink { [unowned self] action in
                switch action {
                case .username:
                    viewModel.userInfoAction()
                case .camera:
                    self.showPhotoSourceDialog()
                }
            }
            .store(in: &subscriptions)
    }
    
    func bindTableSelection() {
        tableController.didSelectSectionSubject
            .sink { section in
                self.viewModel.didSelect(section)
            }
            .store(in: &subscriptions)
    }
    
    func bindSelectPhotoAction() {
        didSelectPhotoActionSubject
            .sink { [unowned self] type in
                bindPhotoHelper()
                photoHelperReactive.askImage(type: type)
                switch type {
                case .camera:
                    viewModel.didSelectCamera()
                case .photoLibrary:
                    viewModel.didSelectCameraRoll()
                }
            }
            .store(in: &subscriptions)
    }
    
    func bindPhotoHelper() {
        photoHelperReactive
            .photoDataPublisher
            .sink { [unowned self] completion in
                switch completion {
                case .failure(let error):
                    viewModel.showError(error: error)
                default: break
                }
            } receiveValue: { [unowned self] imageData in
                viewModel.receivedImageData(imageData)
            }
            .store(in: &subscriptions)

    }
}

extension PersonalAreaHomeViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return nil
    }
}

extension PersonalAreaHomeViewController: GetPhotoDialogReactiveCapable {}
extension PersonalAreaHomeViewController: NavigationBarWithSearch {}
