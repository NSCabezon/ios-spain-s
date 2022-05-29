import UIKit
import UI

protocol BizumHomeOperationCollectionViewDelegate: class {
    func didSelectOperation(_ viewModel: BizumHomeOperationViewModel)
    func didSelectAllOperations()
    func didSelectOperationMultiple(_ viewModel: BizumHomeOperationViewModel)
}

final class BizumHomeOperationCollectionView: UICollectionView {
    private var viewModels: [BizumHomeOperationViewModel] = []
    private let identifierItem = "BizumHomeOperationCollectionViewCell"
    private let identifierAll = "BizumHomeOperationAllCollectionViewCell"
    private let identifierMultiple = "BizumHomeOperationMultipleCollectionViewCell"
    weak var opearionDelegate: BizumHomeOperationCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModels(_ viewModels: [BizumHomeOperationViewModel]) {
        self.viewModels = viewModels
        self.reloadData()
    }
}

extension BizumHomeOperationCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.createCollectionViewCell(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= self.viewModels.count {
            self.opearionDelegate?.didSelectAllOperations()
        } else if viewModels[indexPath.row].isMultiple {
            let viewModel = self.viewModels[indexPath.row]
            self.opearionDelegate?.didSelectOperationMultiple(viewModel)
        } else {
            let viewModel = self.viewModels[indexPath.row]
            self.opearionDelegate?.didSelectOperation(viewModel)
        }

    }
}

private extension BizumHomeOperationCollectionView {
    func setupView() {
        self.configureLayout()
        self.registerCell()
        self.delegate = self
        self.dataSource = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = .fast
    }
    
    func configureLayout() {
        guard let flowloyout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowloyout.itemSize = CGSize(width: 122, height: 157)
        flowloyout.minimumLineSpacing = 6
        flowloyout.minimumInteritemSpacing = 0
        flowloyout.scrollDirection = .horizontal
        flowloyout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func registerCell() {
        self.register(UINib(nibName: self.identifierItem, bundle: Bundle.module), forCellWithReuseIdentifier: self.identifierItem)
        self.register(UINib(nibName: self.identifierAll, bundle: Bundle.module), forCellWithReuseIdentifier: self.identifierAll)
        self.register(UINib(nibName: self.identifierMultiple, bundle: Bundle.module), forCellWithReuseIdentifier: self.identifierMultiple)
    }
    
    func createCollectionViewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row >= self.viewModels.count {
            return self.createSeeAllCell(collectionView, cellForItemAt: indexPath)
        } else if viewModels[indexPath.row].isMultiple {
            return self.createOperationMultipleCell(collectionView, cellForItemAt: indexPath)
        } else {
            return self.createOperationCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func createSeeAllCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifierAll, for: indexPath)
        cell.accessibilityIdentifier = AccessibilityBizum.bizumBtnRecentSeeAll
        return cell
    }
    
    func createOperationCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifierItem, for: indexPath) as? BizumHomeOperationCollectionViewCell else {
            return UICollectionViewCell()
        }
        let viewModel = self.viewModels[indexPath.row]
        cell.set(viewModel)
        cell.accessibilityIdentifier = AccessibilityBizum.bizumBtnRecent
        return cell
    }
    
    func createOperationMultipleCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifierMultiple, for: indexPath) as? BizumHomeOperationMultipleCollectionViewCell else {
            return UICollectionViewCell()
        }
        let viewModel = self.viewModels[indexPath.row]
        cell.setViewModel(viewModel)
        cell.accessibilityIdentifier = AccessibilityBizum.bizumBtnRecent
        return cell
    }
}
