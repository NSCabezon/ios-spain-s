//
//  OnePayCollectionViewController.swift
//  GlobalPosition
//
//  Created by alvola on 05/11/2019.
//

import Foundation
import CoreFoundationLib

struct OnePayCollectionInfo {
    let cellClass: String
    let info: FavouriteContactViewModel?
}

protocol OnePayCollectionViewControllerDelegate: AnyObject {
    func newShippmentPressed()
    func newFavContactPressed()
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel)
    func didTapInHistoricSendMoney()
}

final class OnePayCollectionViewController: NSObject {
    weak var controlledCollectionView: UICollectionView?
    weak var delegate: OnePayCollectionViewControllerDelegate?
    var currentContentOffset: CGPoint?
    var hasShadow = false
    var cellsInfo: [OnePayCollectionInfo] = [] {
        didSet {
            controlledCollectionView?.reloadData()
        }
    }
    private enum CellClass: String {
        case newShippment = "NewShippmentCollectionViewCell"
        case newContact = "NewFavContactCollectionViewCell"
        case favouriteContact = "FavouriteContactCell"
        case loading = "FutureLoadingCollectionViewCell"
        case historicSendMoney = "HistoricSendMoneyCell"
    }
    private let supportedCells = [CellClass.newShippment.rawValue,
                                  CellClass.newContact.rawValue,
                                  CellClass.favouriteContact.rawValue,
                                  CellClass.loading.rawValue,
                                  CellClass.historicSendMoney.rawValue]
    
    init(collectionView: UICollectionView?, dataList: [OnePayCollectionInfo]?) {
        super.init()
        controlledCollectionView = collectionView
        registerCellClasses()
        controlledCollectionView?.delegate = self
        controlledCollectionView?.dataSource = self
        controlledCollectionView?.clipsToBounds = false
        cellsInfo = dataList ?? []
    }
}

private extension OnePayCollectionViewController {
    func registerCellClasses() {
        supportedCells.forEach {
            controlledCollectionView?.register(UINib(nibName: $0, bundle: Bundle(for: PGClassicViewController.self)), forCellWithReuseIdentifier: $0)
            controlledCollectionView?.register(UINib(nibName: $0, bundle: Bundle(for: PGSmartViewController.self)), forCellWithReuseIdentifier: $0)
        }
    }
    
    func setAccessibilityValue(_ indexPath: IndexPath, _ cell: UICollectionViewCell) {
        let items = String(self.cellsInfo.count)
        let index = String(indexPath.row + 1)
        let label = localized("voiceover_position", [StringPlaceholder(.number, index), StringPlaceholder(.number, items)]).text
        cell.accessibilityLabel = label
    }
}

extension OnePayCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellsInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellsInfo[indexPath.row].cellClass, for: indexPath)
        if let favouriteCell = cell as? FavouriteContactCell, let item = cellsInfo[indexPath.row].info {
            favouriteCell.configCell(item)
        }
        if let loadingCell = cell as? FutureLoadingCollectionViewCell {
            loadingCell.loadUpdatedAppearance()
        }
        if hasShadow {
            (cell as? NewShippmentCollectionViewCell)?.configureShadow()
            (cell as? NewFavContactCollectionViewCell)?.configureShadow()
            (cell as? FavouriteContactCell)?.configureShadow()
            (cell as? HistoricSendMoneyCell)?.configureShadow()
        }
        setAccessibilityValue(indexPath, cell)
        return cell
    }
}

extension OnePayCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let kindOfCell = cellsInfo[indexPath.row].cellClass
        switch kindOfCell {
        case CellClass.newShippment.rawValue:
            delegate?.newShippmentPressed()
        case CellClass.newContact.rawValue:
            delegate?.newFavContactPressed()
        case CellClass.favouriteContact.rawValue:
            guard let item = cellsInfo[indexPath.row].info else { return }
            delegate?.didTapInFavContact(item)
        case CellClass.historicSendMoney.rawValue:
            delegate?.didTapInHistoricSendMoney()
        default:
            break
        }
    }
}

extension OnePayCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kindOfCell = cellsInfo[indexPath.row].cellClass
        switch kindOfCell {
        case CellClass.newShippment.rawValue, CellClass.newContact.rawValue, CellClass.loading.rawValue, CellClass.historicSendMoney.rawValue:
            return CGSize(width: 168, height: 152)
        case CellClass.favouriteContact.rawValue:
            return CGSize(width: 128, height: 152)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 13)
    }
}
