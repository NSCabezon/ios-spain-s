//
//  OperativeBizumFrequentContactsView.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 18/1/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol OperativeBizumFrequentContactsViewDelegate: class {
    func didSelectFrequentContact(_ viewModel: BizumFrequentViewModel)
}

final class OperativeBizumFrequentContactsView: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Private properties
    
    private var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 152)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        return layout
    }()
    private var frequentContacts: [BizumFrequentViewModel] = []
    private let loadingView = LoadingCollectionView()
    private let emptyView = EmptyCollectionView()
    
    // MARK: - View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Public
    
    weak var delegate: OperativeBizumFrequentContactsViewDelegate?
    
    func setViewModels(_ viewModels: [BizumFrequentViewModel]) {
        self.stopLoading()
        self.collectionView.backgroundView = nil
        self.frequentContacts = viewModels
        self.collectionView.reloadData()
    }
    
    func showEmptyView() {
        self.stopLoading()
        self.emptyView.frame = self.collectionView.bounds
        self.collectionView.backgroundView = emptyView
    }
    
    func addLoadingView() {
        self.setViewModels([])
        self.loadingView.frame = self.collectionView.bounds
        self.collectionView.backgroundView = self.loadingView
        self.loadingView.startAnimating()
    }
    
    func stopLoading() {
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
    }
}

private extension OperativeBizumFrequentContactsView {
    func setupView() {
        self.view?.backgroundColor = .white
        self.titleLabel.font = .santander(size: 18.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "bizum_label_recentContacts")
        self.collectionView.register(UINib(nibName: "BizumFrequentCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "BizumFrequentCollectionViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.clipsToBounds = false
        self.collectionView.setCollectionViewLayout(self.collectionViewLayout, animated: false)
        self.collectionView.backgroundColor = .white
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.reloadData()
    }
}

extension OperativeBizumFrequentContactsView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.frequentContacts.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BizumFrequentCollectionViewCell.identifier, for: indexPath) as? BizumFrequentCollectionViewCell
        cell?.setViewModel(self.frequentContacts[indexPath.item])
        return cell ?? UICollectionViewCell()
    }
}

extension OperativeBizumFrequentContactsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectFrequentContact(self.frequentContacts[indexPath.item])
    }
}

extension OperativeBizumFrequentContactsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
    }
}
