//
//  OneRadioButtonsContainerView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 21/9/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol OneRadioButtonsContainerDelegate: AnyObject {
    func didSelectOneRadioButton(_ index: Int)
}

public final class OneRadioButtonsContainerView: XibView {
    
    @IBOutlet private weak var stackView: UIStackView!
    private var selectedIndex: Int = 0
    private var optionsNum: Int = 0
    public weak var delegate: OneRadioButtonsContainerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setViewModel(_ viewModel: OneRadioButtonsContainerViewModel) {
        guard !viewModel.viewModels.isEmpty else { return }
        self.setViews(viewModel.viewModels)
        self.selectedIndex = viewModel.selectedIndex
        self.setOneRadioButtonsStatus()
    }
}

private extension OneRadioButtonsContainerView {
    func setViews(_ viewModels: [OneRadioButtonViewModel]) {
        self.optionsNum = viewModels.count
        self.addSeparatorView()
        var viewIndex: Int = 0
        viewModels.map {
            self.addOneRadioButton($0, index: viewIndex)
            self.addSeparatorView()
            viewIndex+=1
        }
    }
    
    func addOneRadioButton(_ viewModel: OneRadioButtonViewModel, index: Int) {
        let oneRadioButtonView = OneRadioButtonView()
        oneRadioButtonView.delegate = self
        oneRadioButtonView.setViewModel(viewModel, index: index)
        self.stackView.addArrangedSubview(oneRadioButtonView)
    }
    
    func addSeparatorView() {
        let separatorView = UIView()
        separatorView.backgroundColor = .oneSkyGray
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.stackView.addArrangedSubview(separatorView)
    }
    
    func setOneRadioButtonsStatus() {
        self.stackView.subviews.forEach {
            guard let view = $0 as? OneRadioButtonView,
                  view.getStatus() != .disabled,
                  view.index != self.selectedIndex else { return }
            view.setByStatus(.inactive)
        }
    }
}

extension OneRadioButtonsContainerView: OneRadioButtonViewDelegate {
    public func didSelectOneRadioButton(_ index: Int) {
        self.selectedIndex = index
        self.setOneRadioButtonsStatus()
        self.delegate?.didSelectOneRadioButton(index)
    }
}
