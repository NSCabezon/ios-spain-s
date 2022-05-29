//
//  GlobalSearchMovementsView.swift
//  GlobalSearch
//
//  Created by alvola on 22/07/2020.
//

import UI
import UIKit
import CoreFoundationLib

protocol GlobalSearchMovementActionsDelegate: class {
    func didSelectMovement(at index: Int, groupedBy productId: String?, of type: GlobalSearchMovementType)
}

final class GlobalSearchMovementsView: XibView {
    
    @IBOutlet private weak var movementsView: UIStackView!
    
    private let heightForHeaderSection: CGFloat = 35.0
    
    weak var delegate: GlobalSearchMovementActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    private func setupViews() {
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.view?.backgroundColor = .white
        self.accessibilityIdentifier = "movementView"
    }
    
    public func addMovements(_ model: GlobalSearchMovementsGroupViewModel) {
        cleanView()
        addHeader(title: model.productAlias, num: model.movements.count)
        setMovements(model.movements, productId: model.productIdentifier)
    }
    
    public func cleanView() {
        movementsView.removeAllArrangedSubviews()
    }
}

private extension GlobalSearchMovementsView {
        
    func addHeader(title: String?, num: Int) {
        let header = GlobalSearchHeaderSectionView(headerTitle: titleString(title: title, num: num))
        movementsView.addArrangedSubview(header)
        header.heightAnchor.constraint(equalToConstant: heightForHeaderSection).isActive = true
        header.widthAnchor.constraint(equalTo: movementsView.widthAnchor).isActive = true
    }
    
    func titleString(title: String?, num: Int) -> LocalizedStylableText {
        let numberOfMovementsAsString = String(num)
        
        if let value = title {
            return localized("search_title_productMovements", [StringPlaceholder(.value, value), StringPlaceholder(.number, numberOfMovementsAsString)])
        } else {
            return localized("search_title_movements", [StringPlaceholder(.number, numberOfMovementsAsString)])
        }
    }
    
    func setMovements(_ movements: [GlobalSearchResultMovementViewModel], productId: String?) {
                
        movements.enumerated().forEach {
            addMovementView(viewModel: $0.element, index: $0.offset, productId: productId)
        }
    }
    
    func addMovementView(viewModel: GlobalSearchResultMovementViewModel, index: Int, productId: String?) {
        let view = GlobalSearchMovementView(frame: .zero)
        view.setInfo(with: viewModel.movement)
        view.accessibilityIdentifier = "movementView\(index)"
        view.onTapAction = { [weak self] in
            self?.delegate?.didSelectMovement(at: index, groupedBy: productId, of: viewModel.resultType)
        }
        movementsView.addArrangedSubview(view)
    }
}
