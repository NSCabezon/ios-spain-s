import UIKit

protocol ProductDetailHeaderPresenterProtocol {
    func numberOfItems() -> Int
    func viewModel(for element: Int) -> CarouselItem
}

class ProductDetailHeaderViewController: BaseViewController<ProductDetailHeaderPresenterProtocol>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ToolTipDisplayer {
    
    @IBOutlet weak var collectionView: UICollectionView!

    override class var storyboardName: String {
        return "ProductDetail"
    }
    
    override func prepareView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.register(UINib(nibName: "ProductDetailCardCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "ProductDetailCardCollectionViewCell")
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItems()
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = presenter.viewModel(for: indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.identifier, for: indexPath)
        viewModel.configure(cell: cell)
        if let cell = cell as? ToolTipCompatible {
            cell.toolTipDelegate = self
        }
        return cell
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }

}
