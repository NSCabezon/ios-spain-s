//
//  ContactsCollectionView.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 04/02/2020.
//

import Foundation
import UI

private enum ContactCollectionViewCellType {
    case newShipment
    case contact(viewModel: ContactViewModel)
    case newContact
    case loading
}

extension ContactCollectionViewCellType: CollectionViewCellRepresentable {
    
    func cell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch self {
        case .newShipment:
            cell = collectionView.dequeue(type: NewShipmentCollectionViewCell.self, at: indexPath)
        case .contact(viewModel: let viewModel):
            let contactCell = collectionView.dequeue(type: ContactCollectionViewCell.self, at: indexPath)
            contactCell.setup(with: viewModel)
            cell = contactCell
        case .newContact:
            cell = collectionView.dequeue(type: NewContactCollectionViewCell.self, at: indexPath)
        case .loading:
            cell = collectionView.dequeue(type: ContactLoadingCollectionViewCell.self, at: indexPath)
        }
        cell.accessibilityIdentifier = self.accessibilityIdentifier(at: indexPath)
        return cell
    }
    
    func idenfier() -> String {
        switch self {
        case .newShipment: return "NewShipmentCollectionViewCell"
        case .contact: return "ContactCollectionViewCell"
        case .newContact: return "NewContactCollectionViewCell"
        case .loading: return "ContactLoadingCollectionViewCell"
        }
    }
    
    func accessibilityIdentifier(at indexPath: IndexPath) -> String? {
        switch self {
        case .newShipment: return "btnNewSend"
        case .contact: return "btnSendFav\(indexPath.item)"
        case .newContact: return "btnNewContacts"
        case .loading: return nil
        }
    }
    
    func size() -> CGSize {
        switch self {
        case .newShipment: return CGSize(width: 168, height: 152)
        case .newContact: return CGSize(width: 168, height: 152)
        default:
            return CGSize(width: 120, height: 152)
        }
    }
}

private class ContactCollectionViewHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var cells: [ContactCollectionViewCellType] = []
    weak var delegate: ContactsCollectionViewDelegate?
    
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
        case .newContact: self.delegate?.didSelectNewContact()
        case .newShipment: self.delegate?.didSelectNewShipment()
        case .contact(viewModel: let viewModel): self.delegate?.didSelectContact(viewModel)
        case .loading: break
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.didSwipe()
    }
}

protocol ContactsCollectionViewDelegate: AnyObject {
    func didSelectNewShipment()
    func didSelectNewContact()
    func didSelectContact(_ viewModel: ContactViewModel)
    func didSwipe()
}

final class ContactsCollectionView: UICollectionView {
    
    // MARK: - Private
    
    private lazy var contactHandler: ContactCollectionViewHandler = {
        let handler = ContactCollectionViewHandler()
        self.dataSource = handler
        self.delegate =  handler
        return handler
    }()
    
    // MARK: - Public
    
    var contactsCollectionViewDelegate: ContactsCollectionViewDelegate? {
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
    }
    
    func showLoading() {
        self.contactHandler.cells.removeAll()
        self.contactHandler.cells.append(.newShipment)
        self.contactHandler.cells.append(.loading)
        self.reloadData()
    }
    
    func set(_ viewModels: [ContactViewModel]) {
        self.contactHandler.cells.removeAll()
        self.contactHandler.cells.append(.newShipment)
        self.contactHandler.cells.append(contentsOf: viewModels.map(ContactCollectionViewCellType.contact))
        self.contactHandler.cells.append(.newContact)
        self.reloadData()
    }
    
    // MARK: - Private
    
    private func registerCells() {
        self.register(type: NewShipmentCollectionViewCell.self, bundle: .module)
        self.register(type: ContactCollectionViewCell.self, bundle: .module)
        self.register(type: NewContactCollectionViewCell.self, bundle: .module)
        self.register(type: ContactLoadingCollectionViewCell.self, bundle: .module)
    }
    
    private func setupCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionViewLayout = layout
    }
}
