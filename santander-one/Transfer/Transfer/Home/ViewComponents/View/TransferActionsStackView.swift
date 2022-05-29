//
//  TransferActionsView.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/18/19.
//

import UIKit
import UI
import CoreFoundationLib

final class TransferActionsStackView: UIView {
    
    private lazy var verticalStackView: Stackview = {
        let stackView = Stackview()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private(set) var height: CGFloat  = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.addStackView()
        verticalStackView.delegate = self
    }
    
    public func setViewModels(_ viewModels: [TransferActionViewModel]) {
        verticalStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        viewModels.forEach { self.addTransferaActionView($0) }
        layoutSubviews()
    }
    
    public func setOrigin(_ origin: TransferActionOrigin) {
        switch origin {
        case .home:
            self.backgroundColor = .skyGray
        case .curtain:
            self.backgroundColor = .white
        }
    }
    
    private func addStackView() {
        self.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -23),
            self.verticalStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            self.verticalStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)
        ])
    }
    
    private func addTransferaActionView(_ viewModel: TransferActionViewModel) {
        let view = TransferActionView(frame: .zero)
        view.accessibilityIdentifier = viewModel.accessibilityIdentifier
        self.verticalStackView.addArrangedSubview(view)
        self.verticalStackView.layoutSubviews()
        view.updateViewModel(viewModel)
    }
}

extension TransferActionsStackView: StackviewDelegate {
    func didChangeBounds(for stackview: UIStackView) {
        self.height = stackview.frame.size.height
    }
}
