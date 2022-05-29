import UIKit
import CoreFoundationLib
import UI
import Operative

protocol ContactSelectionCollectionViewCellDelegate: AnyObject {
    func didTapOnShareViewModel(_ viewModel: ContactListItemViewModel)
}
protocol ContactSelectorViewProtocol: OldDialogViewPresentationCapable, LoadingViewPresentationCapable, ModuleLauncherDelegate {
    func showLoading()
    func dismissLoading()
    func showContacts(_ contacts: [ContactListItemViewModel])
    func showError()
    func dismissError()
    func disableEditMode()
    func showNotAvaliableToast()
    func setupNavigationBar(showCloseButton: Bool)
}

class ContactSelectorViewController: UIViewController {
    let presenter: ContactSelectorPresenterProtocol
    private var contacts: [ContactListItemViewModel] = []
    private var offsetCellBeingMoved: CGPoint = .zero
    private let cellHeight: CGFloat = 120
    private var isEditEnabled: Bool = true
    
    @IBOutlet weak var errorContactView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addContactButton: RedLisboaButton! {
        didSet {
            addContactButton.setTitle(localized("confirmation_text_newFavoriteRecipients"), for: .normal)
            addContactButton.addSelectorAction(target: self, #selector(addContactDidPressed))
        }
    }
    
    @IBOutlet weak var saveChanges: RedLisboaButton! {
        didSet {
            saveChanges.setTitle(localized("displayOptions_button_saveChanges"), for: .normal)
            saveChanges.addSelectorAction(target: self, #selector(saveChangesDidPressed))
        }
    }
    
    @IBOutlet weak var contactLoadingView: ContactLoadingView!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: ContactSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isHidden = true
        self.errorContactView.isHidden = true
        self.saveChanges.isHidden = true
        self.addContactButton.isHidden = false
        self.presenter.viewDidLoad()
        self.setAccessibilityIdentifiers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = true
    }
    
    @objc private func addContactDidPressed() {
        self.presenter.didSelectNewContact()
        self.addContactButton.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeBtnSaveFavoriteRecipients
    }
    
    @objc private func saveChangesDidPressed() {
        self.saveChanges.isHidden = true
        self.addContactButton.isHidden = false
        self.presenter.didSelectSaveSortedContacts(contacts)
    }
    
    func setupView() {
        self.collectionView.register(type: ContactSelectionCollectionViewCell.self, bundle: .module)
        self.collectionView.register(type: ContactSelectionNoEditCollectionViewCell.self, bundle: .module)
    }
}

private extension ContactSelectorViewController {
    @objc private func closeSelected() {
        self.presenter.didSelectClose()
    }
    
    @objc private func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    func setAccessibilityIdentifiers() {
        self.saveChanges.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeBtnSaveFavoriteRecipients
        self.addContactButton.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeBtnFavoriteNewContact
        self.collectionView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewFavoriteRecipientsList
    }
}

extension ContactSelectorViewController: ContactSelectorViewProtocol {
    func showNotAvaliableToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }

    func disableEditMode() {
        self.isEditEnabled = false
    }
    
    func dismissError() {
        self.errorContactView.isHidden = true
    }
    
    func showError() {
        self.errorContactView.isHidden = false
    }
    
    func dismissLoading() {
        self.contactLoadingView.stopAnimating()
        self.contactLoadingView.isHidden = true
    }
    
    func showLoading() {
        self.contactLoadingView.startAnimating()
    }
    
    func showContacts(_ contacts: [ContactListItemViewModel]) {
        self.contacts = contacts
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
    }
    
    func setupNavigationBar(showCloseButton: Bool) {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "transfer_label_favoriteRecipients")
        )
        builder.setLeftAction(.back(action: #selector(dismissSelected)))
        if showCloseButton {
            builder.setRightActions(.close(action: #selector(closeSelected)))
        } else {
            builder.setRightActions(.menu(action: #selector(openMenu)))
        }
        builder.build(on: self, with: nil)
        self.view.backgroundColor = UIColor.skyGray
    }
}

private extension ContactSelectorViewController {
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.saveChanges.isHidden = false
            self.addContactButton.isHidden = true
            guard let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)),
                let cell = self.collectionView.cellForItem(at: indexPath) else {
                    self.collectionView.endInteractiveMovement()
                    return
            }
            self.collectionView.beginInteractiveMovementForItem(at: indexPath)
            offsetCellBeingMoved = offsetOfTouchFrom(recognizer: gesture, inCell: cell)
            var location = gesture.location(in: self.collectionView)
            location.x += offsetCellBeingMoved.x
            location.y += offsetCellBeingMoved.y
            self.collectionView.updateInteractiveMovementTargetPosition(location)
        case .changed:
            var location = gesture.location(in: self.collectionView)
            location.x += offsetCellBeingMoved.x
            location.y += offsetCellBeingMoved.y
            self.collectionView.updateInteractiveMovementTargetPosition(location)
        case .ended, .cancelled, .failed:
            self.collectionView.endInteractiveMovement()
        default:
            self.collectionView.cancelInteractiveMovement()
        }
    }
    
    func offsetOfTouchFrom(recognizer: UIGestureRecognizer, inCell cell: UICollectionViewCell) -> CGPoint {
        let locationOfTouchInCell = recognizer.location(in: cell)
        let cellCenterX = cell.frame.width / 2
        let cellCenterY = cell.frame.height / 2
        let cellCenter = CGPoint(x: cellCenterX, y: cellCenterY)
        var offSetPoint = CGPoint.zero
        offSetPoint.y = cellCenter.y - locationOfTouchInCell.y
        offSetPoint.x = cellCenter.x - locationOfTouchInCell.x
        return offSetPoint
    }
    
    func configureCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isEditEnabled {
            return self.configureEditableCollectionView(collectionView,
                                                        cellForItemAt: indexPath)
        } else {
            return self.configureNoEditableCollectionView(collectionView,
                                                        cellForItemAt: indexPath)
        }
    }
    
    func configureEditableCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactSelectionCollectionViewCell", for: indexPath) as? ContactSelectionCollectionViewCell else {
            return UICollectionViewCell()
        }
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        cell.setLongGesture(gesture)
        cell.delegate = self
        cell.setup(withViewModel: self.contacts[indexPath.row])
        return cell
    }
    
    func configureNoEditableCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactSelectionNoEditCollectionViewCell", for: indexPath) as? ContactSelectionNoEditCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.setup(withViewModel: self.contacts[indexPath.row])
        return cell
    }
}

extension ContactSelectorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contacts.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.isUserInteractionEnabled = false
        self.presenter.didSelectContact(self.contacts[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.configureCollectionView(collectionView,
                                            cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = contacts.remove(at: sourceIndexPath.row)
        contacts.insert(item, at: destinationIndexPath.row)
    }
}

extension ContactSelectorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: self.cellHeight)
    }
}

extension ContactSelectorViewController: ContactSelectionCollectionViewCellDelegate {
    func didTapOnShareViewModel(_ viewModel: ContactListItemViewModel) {
        self.view.isUserInteractionEnabled = false
        self.presenter.didTapOnShareViewModel(viewModel)
    }
}
