import UIKit

final class OneFavoritesCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        setupAvailableContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAvailableContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAvailableContent()
    }
}

private extension OneFavoritesCollectionView {
    func setupAvailableContent() {
        showsHorizontalScrollIndicator = false
        setLayout()
        registerCells()
    }
    
    func setLayout() {
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.itemSize = CGSize(width: 136, height: 148)
        flowLayout?.scrollDirection = .horizontal
        flowLayout?.minimumLineSpacing = 12.0
        flowLayout?.sectionInset = UIEdgeInsets(top: 21, left: 16, bottom: 30, right: 16)
    }
    
    func registerCells() {
        register(
            UINib(
                nibName: String(describing: OneAdditionalFavoritesActionsCollectionViewCell.self),
                bundle: .module
            ),
            forCellWithReuseIdentifier: String(describing: OneAdditionalFavoritesActionsCollectionViewCell.self)
        )
        register(
            UINib(
                nibName: String(describing: OneFavoriteContactCardCollectionViewCell.self),
                bundle: .module
            ),
            forCellWithReuseIdentifier: String(describing: OneFavoriteContactCardCollectionViewCell.self)
        )
        register(
            UINib(
                nibName: String(describing: TransferHomeFavoriteLoadingCollectionViewCell.self),
                bundle: .module
            ),
            forCellWithReuseIdentifier: String(describing: TransferHomeFavoriteLoadingCollectionViewCell.self)
        )
    }
}
