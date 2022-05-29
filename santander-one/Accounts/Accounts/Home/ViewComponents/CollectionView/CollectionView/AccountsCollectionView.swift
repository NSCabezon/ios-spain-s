//
//  AccountsCollectionView.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import Foundation
import UI

protocol AccountsCollectionViewDelegate: AnyObject {
    func didSelectAccountViewModel(_ viewModel: AccountViewModel)
    func didTapOnShareViewModel(_ viewModel: AccountViewModel)
    func didTapOnWithHolding(_ viewModel: AccountViewModel)
    func didBeginScrolling()
    func didEndScrolling()
    func didEndScrollingSelectedItem()
}

protocol AccountsCollectionViewCellDelegate: AnyObject {
    func didTapOnShareViewModel(_ viewModel: AccountViewModel)
    func didTapOnWithHolding(_ viewModel: AccountViewModel)
}

protocol AccountsCollectionViewCellProtocol {
    func configure(_ viewModel: AccountViewModel)
    var delegate: AccountsCollectionViewCellDelegate? { get set }
}

final class AccountsCollectionView: UICollectionView {
    let cellIndentifier = "AccountsCollectionViewCell"
    let cellMoneyBoxIndentifier = "PiggyBankCollectionViewCell"
    private var accountsViewModels: [AccountViewModel] = []
    private let layout: ZoomAndSnapFlowLayout = ZoomAndSnapFlowLayout()
    weak var pageControlDelegate: PageControlDelegate?
    weak var accountsDelegate: AccountsCollectionViewDelegate?
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func updateAccountViewModel(_ viewModel: AccountViewModel) {
        guard let index = self.getIndexForViewModel(viewModel) else { return } 
        self.accountsViewModels[index] = viewModel
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.cellForItem(at: indexPath) as? AccountsCollectionViewCell
        cell?.configure(viewModel)
        cell?.hideLoading()
        cell?.setWithholdingViewModel(viewModel)
    }
    
    func updateAccountsViewModels(_ viewModels: [AccountViewModel], selectedViewModel: AccountViewModel) {
        self.accountsViewModels = viewModels
        self.reloadData()
        self.setSelectedViewModel(selectedViewModel)
        self.notifySelectedViewModel(selectedViewModel)
    }
    
    func updateHeight(_ height: CGFloat) {
        let itemWidth = getProportionalItemSizeWidth()
        self.layout.setItemSize(CGSize(width: itemWidth, height: height))
    }
}

extension AccountsCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.accountsViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = self.accountsViewModels[indexPath.row]
        var cell: AccountsCollectionViewCellProtocol?
        if viewModel.isPiggyBankAccount {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellMoneyBoxIndentifier, for: indexPath) as? PiggyBankCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIndentifier, for: indexPath) as? AccountsCollectionViewCell
        }
        cell?.configure(viewModel)
        cell?.delegate = self
        return cell as? UICollectionViewCell ?? UICollectionViewCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.accountsDelegate?.didBeginScrolling()
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        self.pageControlDelegate?.didPageChange(page: indexPath.item)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.endScrollingAndSelectAccount()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.endScrollingAndSelectAccount()
    }
}

extension AccountsCollectionView: AccountsCollectionViewCellDelegate {
    func didTapOnShareViewModel(_ viewModel: AccountViewModel) {
        self.accountsDelegate?.didTapOnShareViewModel(viewModel)
    }
    
    func didTapOnWithHolding(_ viewModel: AccountViewModel) {
        self.accountsDelegate?.didTapOnWithHolding(viewModel)
    }
}

private extension AccountsCollectionView {
    
    func setupView() {
        self.registerCell()
        self.addLayout()
        self.decelerationRate = .fast
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        layout.setItemSize(CGSize(width: itemWidth, height: 176))
        layout.setMinimumLineSpacing(16)
        layout.setZoom(0)
        self.collectionViewLayout = layout
    }
    
    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    
    func registerCell() {
        let nib = UINib(nibName: cellIndentifier, bundle: Bundle.module)
        let moneyNib = UINib(nibName: cellMoneyBoxIndentifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: cellIndentifier)
        self.register(moneyNib, forCellWithReuseIdentifier: cellMoneyBoxIndentifier)
    }
    
    func setSelectedViewModel(_ viewModel: AccountViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: item, section: 0)
        self.layoutIfNeeded()
        self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        self.accountsDelegate?.didEndScrollingSelectedItem()
    }
    
    func getIndexForViewModel(_ viewModel: AccountViewModel) -> Int? {
        let index = self.accountsViewModels.firstIndex(where: { return $0 == viewModel})
        return index
    }
    
    func notifySelectedViewModel(_ viewModel: AccountViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        self.pageControlDelegate?.didPageChange(page: item)
        self.accountsDelegate?.didSelectAccountViewModel(viewModel)
    }
    
    func endScrollingAndSelectAccount() {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let viewModel = self.accountsViewModels[indexPath.item]
        self.accountsDelegate?.didSelectAccountViewModel(viewModel)
        self.accountsDelegate?.didEndScrolling()
    }
}
