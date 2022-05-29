import UIOneComponents
import CoreFoundationLib
import UIKit
import UI

protocol OneFavoritesViewDelegate: OneFavoriteContactCardDelegate {
    func didTapOnSeeFavorites()
    func didTapOnNewTransfer()
    func didTapOnNewContact()
}

final class OneFavoritesView: XibView {
    @IBOutlet private weak var sendTitleLabel: UILabel!
    @IBOutlet private weak var seeAllFavoritesButton: UIButton!
    @IBOutlet private weak var favoritesCollectionView: OneFavoritesCollectionView!
    weak var delegate: OneFavoritesViewDelegate?
    var didSwipe: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    @IBAction func didTapOnSeeFavoritesButton(_ sender: Any) {
        delegate?.didTapOnSeeFavorites()
    }
    
    func set(datasource: PayeeCollectionDataSource) {
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = datasource
        favoritesCollectionView.reloadData()
    }
    
    func reloadData() {
        self.favoritesCollectionView.reloadData()
    }

    func disableFavoritesButton() {
        seeAllFavoritesButton.isHidden = true
    }
}

extension OneFavoritesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 &&
                    collectionView.cellForItem(at: indexPath) is OneAdditionalFavoritesActionsCollectionViewCell {
            delegate?.didTapOnNewTransfer()
        } else if indexPath.item != 0 &&
                    collectionView.cellForItem(at: indexPath) is OneAdditionalFavoritesActionsCollectionViewCell {
            delegate?.didTapOnNewContact()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didSwipe?()
    }
}

private extension OneFavoritesView {
    func configureView() {
        setAppearance()
        setAccessibilityIdentifiers()
    }
    
    func setAppearance() {
        sendTitleLabel.font = .typography(fontName: .oneH200Bold)
        sendTitleLabel.textColor = .oneLisboaGray
        sendTitleLabel.configureText(withKey: "transfer_title_sendTo")
        if #available(iOS 15.0, *) {
            seeAllFavoritesButton.configuration = nil
        }
        seeAllFavoritesButton.titleLabel?.font = .typography(fontName: .oneB200Bold)
        seeAllFavoritesButton.setTitleColor(.oneDarkTurquoise, for: .normal)
        seeAllFavoritesButton.setTitleColor(.oneDarkEmerald, for: .highlighted)
        seeAllFavoritesButton.setTitle(localized("transfer_label_seeContacts"), for: .normal)
    }
    
    func setAccessibilityIdentifiers() {
        sendTitleLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelTitle
        seeAllFavoritesButton.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeBtnSeeContacts
    }
}
