//
//  OneFavouritesListViewController.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 4/1/22.
//

import CoreFoundationLib
import UIOneComponents
import OpenCombine
import CoreDomain
import UIKit
import UI

final class OneFavouritesListViewController: UIViewController {
    @IBOutlet private weak var oneOvalButton: OneOvalButton!
    @IBOutlet private weak var stackView: UIStackView!
    private let viewModel: OneFavouritesListViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OneFavouritesListDependenciesResolver
    private lazy var searchBarView: FavouriteContactsSearchBarView = {
        let view = FavouriteContactsSearchBarView(frame: .zero)
        return view
    }()
    private lazy var favouritesCollectionView: FavouriteContactsCollectionView = {
        let view = FavouriteContactsCollectionView(frame: .zero)
        return view
    }()
    private lazy var emptyView: FavouriteContactsEmptyView = {
        let view = FavouriteContactsEmptyView(frame: .zero)
        return view
    }()
    
    init(dependencies: OneFavouritesListDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "OneFavouritesListViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillStackView()
        configureOneOvalButton()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

private extension OneFavouritesListViewController {
    func fillStackView() {
        stackView.addArrangedSubview(searchBarView)
        stackView.addArrangedSubview(favouritesCollectionView)
        stackView.addArrangedSubview(emptyView)
        favouritesCollectionView.isHidden = true
        emptyView.isHidden = true
    }
    
    func configureOneOvalButton() {
        oneOvalButton.style = .redWithWhiteTint
        oneOvalButton.isEnabled = true
        oneOvalButton.size = .medium
        oneOvalButton.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactOneOvalButton
        self.view.bringSubviewToFront(oneOvalButton)
    }
    
    @IBAction func didSelectOneOvalButton() {
        viewModel.showHelp()
    }
    
    func configureNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_favourites")
            .setLeftAction(.back)
            .setRightAction(.help, action: didTapOnHelp)
            .setRightAction(.close, action: didTapOnClose)
            .build(on: self)
    }
    
    func didTapOnHelp() {
        viewModel.showHelp()
    }
    
    func didTapOnClose() {
        viewModel.close()
    }
    
    func getFavouriteContacts(payees: [PayeeRepresentable], sepaInfoList: SepaInfoListRepresentable?) -> [FavouriteContact] {
        return payees.compactMap {
            return FavouriteContact(contact: $0,
                                    sepaInfoList: sepaInfoList,
                                    legacyDependenciesResolver: self.dependencies.external.resolve())
        }
    }
    
    func setCollectionView(_ items: [FavouriteContact]) {
        favouritesCollectionView.bind(
            identifier: FavouriteCollectionViewCell.identifier,
            cellType: FavouriteCollectionViewCell.self,
            items: items) { _, cell, item in
                cell?.setContact(item)
            }
        favouritesCollectionView.isHidden = false
        favouritesCollectionView.reloadData()
        favouritesCollectionView.layoutIfNeeded()
    }
    
    func showEmptyView(_ item: FavouriteContactsEmptyItem) {
        emptyView.isHidden = false
        emptyView.setView(item)
    }
}

// MARK: - Bindings
private extension OneFavouritesListViewController {
    func bind() {
        bindContacts()
        bindEmptyContacts()
    }
    
    func bindContacts() {
        viewModel.state
            .case(OneFavouritesListState.contactsLoaded)
            .map { [unowned self] (payees, sepaList) in
                return self.getFavouriteContacts(payees: payees, sepaInfoList: sepaList)
            }
            .sink { [unowned self] items in
                self.setCollectionView(items)
            }
            .store(in: &subscriptions)
    }
    
    func bindEmptyContacts() {
        viewModel.state
            .case(OneFavouritesListState.empty)
            .map { [unowned self] type in
                return FavouriteContactsEmptyItem(type)
            }
            .sink { [unowned self] item in
                showEmptyView(item)
            }
            .store(in: &subscriptions)
    }
}
