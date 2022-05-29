//
//  PendingTransactionCollectionView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/16/20.
//
import UI
import Foundation

protocol PendingTransactionCollectionViewDelegate: AnyObject {
    func didSelectViewModel(_ viewModel: PendingTransactionDetailViewModel)
}

final class PendingTransactionCollectionView: UICollectionView {
    private var viewModels = [PendingTransactionDetailViewModel]()
    private weak var transactionCollectionViewDelegate: PendingTransactionCollectionViewDelegate?
    private let stimatedHeight: CGFloat = 192
    lazy var layout: ZoomAndSnapFlowLayout? = {
        return self.collectionViewLayout as? ZoomAndSnapFlowLayout
    }()
    
    weak var heightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    func setViewModels(_ selected: PendingTransactionDetailViewModel, viewModels: [PendingTransactionDetailViewModel]) {
        self.viewModels = viewModels
        self.reloadData()
        self.setSelectedViewModel(selected)
    }
    
    private func setSelectedViewModel(_ selected: PendingTransactionDetailViewModel) {
        guard let index = viewModels.firstIndex(where: { selected == $0 }) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        self.layoutIfNeeded()
        self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        self.updateLayout(for: indexPath)
    }
    
    func setupViews() {
        self.registerCells()
        self.setupLayout()
        self.setupConstraint()
        self.backgroundColor = .clear
        self.decelerationRate = .fast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        self.contentInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    }
    
    func setDelegate(_ delegate: PendingTransactionCollectionViewDelegate) {
        self.transactionCollectionViewDelegate = delegate
    }
    
    private func registerCells() {
        let nib = UINib(nibName: PendingTransactionCollectionViewCell.identifier, bundle: .module)
        self.register(nib, forCellWithReuseIdentifier: PendingTransactionCollectionViewCell.identifier)
    }
    
    private func setupLayout() {
        let width = UIScreen.main.bounds.width * 0.80
        self.layout?.setItemSize(CGSize(width: width, height: stimatedHeight))
        self.layout?.setMinimumLineSpacing(16)
        self.layout?.setZoom(0)
    }
    
    private func setupConstraint() {
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: stimatedHeight)
        self.heightConstraint?.isActive = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateLayout(for indexPath: IndexPath) {
        let cell = self.cellForItem(at: indexPath)
        let cellHeight = (cell as? PendingTransactionCollectionViewCell)?.getCollapsedHeight() ?? stimatedHeight
        self.heightConstraint?.constant = (cellHeight > stimatedHeight) ? cellHeight : stimatedHeight
        self.layoutIfNeeded()
    }
}

extension PendingTransactionCollectionView: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.layout?.indexPathForCenterRect() else { return }
        self.updateLayout(for: indexPath)
        let viewModel = self.viewModels[indexPath.row]
        self.transactionCollectionViewDelegate?.didSelectViewModel(viewModel)
    }
}

extension PendingTransactionCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = self.viewModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PendingTransactionCollectionViewCell.identifier, for: indexPath)
        (cell as? PendingTransactionCollectionViewCell)?.configure(viewModel)
        return cell
    }
}
