import UIKit
import CoreFoundationLib

protocol ProductCollectionPresenterProtocol: Presenter, SideMenuCapable {
    func didSelectElement(at position: IndexPath)
}

final class ProductCollectionViewController: BaseViewController<ProductCollectionPresenterProtocol>, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override class var storyboardName: String {
        return "PublicProducts"
    }
    
    lazy var dataSource: GenericCollectionViewDataSource<ImageTitleCollectionCellItem> = {
        let ds = GenericCollectionViewDataSource<ImageTitleCollectionCellItem>()
        return ds
    }()
    
    override func loadView() {
        super.loadView()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.backgroundColor = .uiBackground
        collectionView.registerCells(["ImageTitleCollectionViewCell"])
        emptyView.backgroundColor = .uiBackground
        emptyLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoSemibold(size: 16.0), textAlignment: .center))
        let colors: [UIColor] = [.white]
        let vector = (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        navigationController?.navigationBar.setGradientBackground(colors: colors, vector: vector)
    }
    
    var textEmtpyLabel: LocalizedStylableText? {
        didSet {
            if let textEmtpyLabel = textEmtpyLabel {
                emptyLabel.set(localizedStylableText: textEmtpyLabel)
            } else {
                emptyLabel.text = nil
            }
        }
    }
    
    func isEmptyViewVisible(visible: Bool) {
        emptyView.isHidden = !visible
    }
    
    var sections: [ImageTitleCollectionCellItem] {
        return dataSource.sections.first ?? []
    }
    
    func setSections(_ sections: [ImageTitleCollectionCellItem]) {
        dataSource.setSections([sections])
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectElement(at: indexPath)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthInsets = CGFloat(10)
        let cellHeight = CGFloat(132)
        let halfScreen = (UIScreen.main.bounds.width - widthInsets) / 2
        return CGSize(width: halfScreen, height: cellHeight)
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
}

extension ProductCollectionViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
