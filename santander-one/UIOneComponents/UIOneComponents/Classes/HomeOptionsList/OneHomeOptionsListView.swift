//
//  OneHomeOptionsListView.swift
//  UIOneComponents
//
//  Created by Carlos Monfort Gómez on 23/11/21.
//

import UIKit
import UI
import CoreFoundationLib

public class OneHomeOptionsListView: UIView {
    private lazy var verticalStackView: Stackview = {
        let stackView = Stackview()
        stackView.spacing = 0
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
    
    public func setViewModels(_ viewModels: [SendMoneyHomeOption]) {
        self.verticalStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        viewModels.enumerated().forEach {
            self.addOneHomeOptionView($0.element, isLast: $0.offset == viewModels.count - 1)
        }
        self.layoutSubviews()
    }
}

private extension OneHomeOptionsListView {
    func setupView() {
        self.addStackView()
        self.verticalStackView.delegate = self
    }
    
    func addStackView() {
        self.addSubview(self.verticalStackView)
        self.borders(for: [.all], width: 1, color: .oneMediumSkyGray)
        self.setOneCornerRadius(type: .oneShRadius8)
        self.verticalStackView.fullFit()
    }
    
    func addOneHomeOptionView(_ viewModel: SendMoneyHomeOption, isLast: Bool) {
        let view = OneHomeOptionView(frame: .zero)
        view.accessibilityIdentifier = viewModel.accessibilityIdentifier
        self.verticalStackView.addArrangedSubview(view)
        self.verticalStackView.layoutSubviews()
        view.setViewModel(viewModel)
        if !isLast {
            self.addSeparator()
        }
    }
    
    func addSeparator() {
        let separatorView = UIView()
        separatorView.backgroundColor = .oneMediumSkyGray
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.verticalStackView.addArrangedSubview(separatorView)
    }
}

extension OneHomeOptionsListView: StackviewDelegate {
    public func didChangeBounds(for stackview: UIStackView) {
        self.height = stackview.frame.size.height
    }
}
