//
//  SecurityAreaActionsView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol SecurityAreaActionsViewProtocol: AnyObject {
    func didSelectSecurityAction(_ action: SecurityActionType)
    func didSelectSecuritySwitchAction(_ action: SecurityActionType, isSwitchOn: Bool)
    func didSelectSecuritySwitchCustomAction(_ action: CustomAction, isSwitchOn: Bool)
    func didSelectVideo(_ viewModel: SecurityVideoViewModel)
}

class SecurityAreaActionsView: UIView {
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    weak var delegate: SecurityAreaActionsViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.addSubview(stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 0),
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            self.stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        ])
    }
    
    func setViewModels(_ viewModels: [SecurityActionViewModelProtocol]) {
        self.clearStackView()
        self.addHeader()
        self.addViewsToStackView(for: viewModels)
    }
    
    private func clearStackView() {
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func addHeader() {
        let securityAreaHeader = SecurityAreaHeaderView()
        stackView.addArrangedSubview(securityAreaHeader)
    }
    
    private func addViewsToStackView(for viewModels: [SecurityActionViewModelProtocol]) {
        for viewModel in viewModels {
            let securityAction = makeSecurityActionsForViewModel(viewModel)
            self.stackView.addArrangedSubview(securityAction)
        }
        let separatorView = self.makeSeparatorView()
        self.stackView.addArrangedSubview(separatorView)
    }
    
    private func makeSecurityActionsForViewModel(_ viewModel: SecurityActionViewModelProtocol) -> UIView {
        var view = UIView()
        switch viewModel.type {
        case .actionView:
            guard let viewModel = viewModel as? SecurityActionViewModel else { return UIView() }
            view = makeSecurityActionView(viewModel)
        case .switchView:
            guard let viewModel = viewModel as? SecuritySwitchViewModel else { return UIView() }
            view = makeSecuritySwitchView(viewModel)
        case .videoView:
            guard let viewModel = viewModel as? SecurityVideoViewModel else { return UIView() }
            view = makeSecurityVideoView(viewModel)
        }
        return view
    }
    
    private func makeSecuritySwitchView(_ viewModel: SecuritySwitchViewModel) -> UIView {
        let securityAreaSwitchView = SecurityAreaSwitchView()
        securityAreaSwitchView.setViewModel(viewModel)
        securityAreaSwitchView.delegate = self
        securityAreaSwitchView.customActionDelegate = self
        return securityAreaSwitchView
    }
    
    private func makeSecurityActionView(_ viewModel: SecurityActionViewModel) -> UIView {
        let securityAreaView = SecurityAreaActionView()
        securityAreaView.setViewModel(viewModel)
        securityAreaView.delegate = self
        return securityAreaView
    }
    
    private func makeSecurityVideoView(_ viewModel: SecurityVideoViewModel) -> UIView {
        let securityVideoView = SecurityAreaVideoView()
        securityVideoView.setViewModel(viewModel)
        securityVideoView.delegate = self
        return securityVideoView
    }
    
    private func makeSeparatorView() -> UIView {
        let separatorView = UIView()
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorView.backgroundColor = UIColor.mediumSkyGray
        return separatorView
    }
}

extension SecurityAreaActionsView: SecurityActionProtocol {
    func didSelectAction(_ action: SecurityActionType) {
        self.delegate?.didSelectSecurityAction(action)
    }
}

extension SecurityAreaActionsView: SecurityAreaSwitchProtocol {
    func didChangedSwitchValue(_ action: SecurityActionType, _ isSwitchOn: Bool) {
        self.delegate?.didSelectSecuritySwitchAction(action, isSwitchOn: isSwitchOn)
    }
}

extension SecurityAreaActionsView: SecurityAreaCustomActionSwitchProtocol {
    func didChangedSwitchValue(_ action: CustomAction, _ isSwitchOn: Bool) {
        self.delegate?.didSelectSecuritySwitchCustomAction(action, isSwitchOn: isSwitchOn)
    }
}

extension SecurityAreaActionsView: SecurityAreaVideoProtocol {
    func didSelectVideo(_ viewModel: SecurityVideoViewModel) {
        self.delegate?.didSelectVideo(viewModel)
    }
}
