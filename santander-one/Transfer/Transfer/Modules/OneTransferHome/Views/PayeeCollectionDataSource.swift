import UIOneComponents
import OpenCombine
import CoreDomain
import CoreFoundationLib
import UIKit

extension PayeeCollectionDataSource {
    enum ViewState {
        case disabled
        case loading
        case filled([OneFavoriteContactCardViewModel])
    }
}

final class PayeeCollectionDataSource: NSObject {
    var state: ViewState = .loading
    weak var delegate: OneFavoriteContactCardDelegate?
    let didSelectRowAtSubject = PassthroughSubject<[OneFavoriteContactCardViewModel], Never>()
    var newTransferType: OneAdditionalFavoritesActionsViewModel.ViewType = .newTransfer
    
    init(initialState: ViewState, delegate: OneFavoriteContactCardDelegate) {
        state = initialState
        self.delegate = delegate
    }
}

extension PayeeCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch state {
        case .disabled:
            return 1
        case .filled(let list):
            return 1 + list.count + 1
        case .loading:
            return 2
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return createNewTransferCell(collectionView, cellForItemAt: indexPath)
        }
        switch state {
        case .disabled:
            return UICollectionViewCell()
        case .loading:
            return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TransferHomeFavoriteLoadingCollectionViewCell.self), for: indexPath)
        case .filled(let list):
            if indexPath.item == list.count + 1 {
                return createNewContactCell(collectionView, cellForItemAt: indexPath)
            } else if indexPath.item > 0 && indexPath.item <= list.count {
                return createFavoriteCell(collectionView, from: list, cellForItemAt: indexPath)
            } else {
                return UICollectionViewCell()
            }
        }
    }
}

private extension PayeeCollectionDataSource {
    func createNewTransferCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OneAdditionalFavoritesActionsCollectionViewCell.self), for: indexPath)
        (cell as? OneAdditionalFavoritesActionsCollectionViewCell)?.set(
            OneAdditionalFavoritesActionsViewModel(
                viewType: newTransferType,
                accessibilityIdentifier: AccessibilityTransferHome.sendMoneyBtnNewSend
            )
        )
        return cell
    }
    
    func createNewContactCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OneAdditionalFavoritesActionsCollectionViewCell.self), for: indexPath)
        (cell as? OneAdditionalFavoritesActionsCollectionViewCell)?.set(
            OneAdditionalFavoritesActionsViewModel(
                viewType: .newContact,
                accessibilityIdentifier: AccessibilityTransferHome.sendMoneyBtnNewContact
            )
        )
        return cell
    }
    
    func createFavoriteCell(_ collectionView: UICollectionView, from list: [OneFavoriteContactCardViewModel], cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OneFavoriteContactCardCollectionViewCell.self), for: indexPath)
        (cell as? OneFavoriteContactCardCollectionViewCell)?.set(model: list[indexPath.item - 1])
        if let delegate = delegate {
            (cell as? OneFavoriteContactCardCollectionViewCell)?.set(delegate: delegate)
        }
        return cell
    }
}
