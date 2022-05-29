//
//  GPCustomizationProductSectionCollectionViewCell.swift
//  PersonalArea
//
//  Created by Francisco del Real Escudero on 27/11/2019.
//

import UIKit
import CoreFoundationLib
import UI
import CoreDomain

final class GPCustomizationProductSectionCollectionViewCell: UICollectionViewCell {
    private var headerTitle: LocalizedStylableText {
        guard
            let productType = products.first?.productType,
            let basketTitleKey = productType.basketTitleKey()
            else { return .empty }
        return localized(basketTitleKey)
    }
    
    weak var delegate: ChangedGPSectionProtocol?
    @IBOutlet weak var tableView: UITableView!
    
    var products: [GPCustomizationProductViewModel] = [] 
	
    var productAliasConfiguration: ProductAlias?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 6.0
        tableView.layer.borderColor = UIColor.mediumSky.cgColor
        tableView.layer.borderWidth = 1.0
        let cellNib = UINib(nibName: String(describing: GPCustomizationProductTableViewCell.self), bundle: Bundle.module)
        tableView.register(cellNib, forCellReuseIdentifier: String(describing: GPCustomizationProductTableViewCell.self))
        let headerNib = UINib(nibName: String(describing: GPCustomizationProductHeaderView.self), bundle: Bundle.module)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: String(describing: GPCustomizationProductHeaderView.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 56
        tableView.estimatedSectionHeaderHeight = 40
        tableView.estimatedSectionFooterHeight = 0
        tableView.isEditing = true
        tableView.isScrollEnabled = false
        tableView.allowsSelectionDuringEditing = false
    }
}

extension GPCustomizationProductSectionCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return products.count != 0 ? 1: 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GPCustomizationProductTableViewCell.self), for: indexPath)
        (cell as? GPCustomizationProductTableViewCell)?.setCellInfo(products[indexPath.row])
        (cell as? GPCustomizationProductTableViewCell)?.delegate = self
        (cell as? GPCustomizationProductTableViewCell)?.configureTextfield(configuration: productAliasConfiguration)
        addDashedBottomBorder(to: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setReorderControlImage(Assets.image(named: "icnDragLine"))
        if #available(iOS 13.0, *) {
            cell.setReorderControlAlignment(.right, correction: 6.5)
        } else {
            cell.setReorderControlAlignment(.right, correction: 20.0)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GPCustomizationProductHeaderView.self))
        (header as? GPCustomizationProductHeaderView)?.set(title: headerTitle)
        tableView.removeUnnecessaryHeaderTopPadding()
        return header
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let product = products.remove(at: sourceIndexPath.item)
        products.insert(product, at: destinationIndexPath.item)
        delegate?.updateModel(products)
        delegate?.trackMoved(product)
    }
}

private extension GPCustomizationProductSectionCollectionViewCell {
    func addDashedBottomBorder(to cell: UITableViewCell) {
        let color = UIColor.mediumSkyGray.cgColor
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let frameSize = cell.frame.size
        let shapeRect = CGRect(x: 0,
                               y: 0,
                               width: frameSize.width,
                               height: 0)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2,
                                      y: frameSize.height)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1.0
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [1, 1, 1, 1]
        shapeLayer.lineCap = .round
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                           y: shapeRect.height,
                                                           width: shapeRect.width,
                                                           height: 0),
                                       cornerRadius: 0).cgPath
        cell.layer.addSublayer(shapeLayer)
    }
}

extension GPCustomizationProductSectionCollectionViewCell: ChangedGPProductProtocol {
    func didUpdateAlias(_ info: GPCustomizationProductViewModel) {
        tableView.reloadData()
        delegate?.didUpdateAlias(info)
    }
    
    func updateModel(_ info: GPCustomizationProductViewModel) {
        guard
            let indexToChange = products.firstIndex(where: { $0.identifier == info.identifier && $0.productName == info.productName })
        else { return }
        
        products[indexToChange] = info
        delegate?.updateModel(products)
        delegate?.trackChangedSwitch(info)
    }
    
    func hideAllEditingFields() {
        delegate?.hideAllEditingFields()
    }
}
