//
//  RecoveryExpandedView.swift
//  UI
//
//  Created by alvola on 06/10/2020.
//

import UIKit
import CoreFoundationLib

public final class RecoveryExpandedView: UICollectionViewCell {

    private lazy var debtView: DebtView = {
        let view = DebtView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private var superDismissBlock: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = self.superview else { return }
        NSLayoutConstraint.activate([self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 28.0),
                                     self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -28.0),
                                     self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)])
    }
}

private extension RecoveryExpandedView {
    func commonInit() {
        configureView()
        configureDebtView()
        configureAccessibilityIds()
    }
    
    func configureView() {
        backgroundColor = .white
    }
    
    func configureDebtView() {
        NSLayoutConstraint.activate([debtView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     debtView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     debtView.topAnchor.constraint(equalTo: self.topAnchor),
                                     debtView.heightAnchor.constraint(equalToConstant: 104.0)])
    }
    
    func configureAccessibilityIds() {
        debtView.accessibilityIdentifier = "RecoveryExpandedView"
    }
    
    func dismiss() {
        self.dismissAction()
        self.superDismissBlock?()
    }
}

extension RecoveryExpandedView: StickyExpandedViewProtocol {
    public func setInfo(_ info: Any) {
        guard let debt = info as? RecoveryViewModel else { return }
        debtView.setRecoveryViewModel(debt)
    }
}

extension RecoveryExpandedView: ExpandedViewActionsProtocol {
    public func superDismissAction(block: @escaping () -> Void) {
        self.superDismissBlock = block
    }
    
    public func dismissAction() { }
    
    public func presentAction() { }
}
