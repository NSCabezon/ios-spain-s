import UI

private enum BizumHomeContactCollectionViewCellType {
    case newShipment
    case contact(viewModel: BizumHomeContactViewModel)
    case search
    case loading
}

protocol BizumHomeContactCollectionViewDelegate: class {
    func didSelectNewShipment()
    func didSelectSearchContact()
    func didSelectContact(_ viewModel: BizumHomeContactViewModel)
}

extension BizumHomeContactCollectionViewCellType: CollectionViewCellRepresentable {
    func cell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch self {
        case .newShipment:
            cell = collectionView.dequeue(type: BizumHomeContactNewSendCollectionViewCell.self, at: indexPath)
        case .contact(let viewModel):
            let contactCell = collectionView.dequeue(type: BizumHomeContactItemCollectionViewCell.self, at: indexPath)
            contactCell.set(viewModel)
            cell = contactCell
        case .loading:
            cell = collectionView.dequeue(type: BizumHomeContactLoadingCollectionViewCell.self, at: indexPath)
        case .search:
            cell = collectionView.dequeue(type: BizumHomeContactSearchCollectionViewCell.self, at: indexPath)
        }
        cell.accessibilityIdentifier = self.accessibilityIdentifier(at: indexPath)
        return cell
    }
    
    func idenfier() -> String {
        switch self {
        case .newShipment: return "BizumHomeContactNewSendCollectionViewCell"
        case .contact: return "BizumHomeContactItemCollectionViewCell"
        case .loading: return "BizumHomeContactLoadingCollectionViewCell"
        case .search: return "BizumHomeContactSearchCollectionViewCell"
        }
    }
    
    func accessibilityIdentifier(at indexPath: IndexPath) -> String? {
        switch self {
        case .newShipment: return "bizumBtnNewSend"
        case .contact: return "bizumCarouselFavorites"
        case .loading: return nil
        case .search: return "bizumBtnSearch"
        }
    }
    
    func size() -> CGSize {
        switch self {
        case .newShipment:
            return CGSize(width: 170, height: 154)
        case .loading:
            return CGSize(width: 122, height: 154)
        case .contact:
            return CGSize(width: 122, height: 154)
        case .search:
            return CGSize(width: 170, height: 154)
        }
    }
}

private class BizumHomeContactCollectionViewHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var cells: [BizumHomeContactCollectionViewCellType] = []
    weak var delegate: BizumHomeContactCollectionViewDelegate?
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.cells[indexPath.item].cell(in: collectionView, at: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cells[indexPath.item].size()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.cells[indexPath.item] {
        case .newShipment:
            self.delegate?.didSelectNewShipment()
        case .contact(viewModel: let viewModel):
            self.delegate?.didSelectContact(viewModel)
        case .search:
            self.delegate?.didSelectSearchContact()
        case .loading:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cellType = self.cells[indexPath.item]
        switch cellType {
        case .loading:
            return false
        default:
            return true
        }
    }
}

final class BizumHomeContactCollectionView: UICollectionView {
    
    // MARK: - Private
    
    private lazy var contactHandler: BizumHomeContactCollectionViewHandler = {
        let handler = BizumHomeContactCollectionViewHandler()
        self.dataSource = handler
        self.delegate =  handler
        return handler
    }()
    
    // MARK: - Public
    
    var contactsCollectionViewDelegate: BizumHomeContactCollectionViewDelegate? {
        get {
            return self.contactHandler.delegate
        }
        set {
            self.contactHandler.delegate = newValue
        }
    }
    
    func setup() {
        self.registerCells()
        self.showsHorizontalScrollIndicator = false
        self.setupCollectionViewFlowLayout()
        self.showLoading()
        self.accessibilityIdentifier = AccessibilityBizum.bizumContactCaroussel
    }
    
    func showLoading() {
        self.contactHandler.cells.removeAll()
        self.contactHandler.cells.append(.newShipment)
        self.contactHandler.cells.append(.loading)
        self.reloadData()
    }
    
    func setEmpty() {
        self.contactHandler.cells.removeAll()
        self.contactHandler.cells.append(.newShipment)
        self.reloadData()
    }
    
    func set(_ viewModels: [BizumHomeContactViewModel]) {
        self.contactHandler.cells.removeAll()
        self.contactHandler.cells.append(.newShipment)
        self.contactHandler.cells.append(contentsOf: viewModels.map(BizumHomeContactCollectionViewCellType.contact))
        self.contactHandler.cells.append(.search)
        self.reloadData()
    }
}
 
// MARK: - Private

private extension BizumHomeContactCollectionView {
    func registerCells() {
        self.register(type: BizumHomeContactItemCollectionViewCell.self, bundle: .module)
        self.register(type: BizumHomeContactNewSendCollectionViewCell.self, bundle: .module)
        self.register(type: BizumHomeContactLoadingCollectionViewCell.self, bundle: .module)
        self.register(type: BizumHomeContactSearchCollectionViewCell.self, bundle: .module)
    }
    
    func setupCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.collectionViewLayout = layout
    }
}
