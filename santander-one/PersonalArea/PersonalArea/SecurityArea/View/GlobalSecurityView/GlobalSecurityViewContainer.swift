import Foundation
import CoreFoundationLib

public protocol GlobalSecurityViewContainerProtocol: AnyObject {
    func createView(data: GlobalSecurityViewDataComponentsProtocol?,
                    delegate: GlobalSecurityViewDelegate?) -> UIView
}

final class GlobalSecurityViewContainer {
    private let viewComponent: GlobalSecurityViewComponentsProtocol
    private let mainStackView = UIStackView()

    init(dependencies: DependenciesResolver) {
        self.viewComponent = GlobalSecurityViewComponents(dependencies: dependencies)
    }
}

extension GlobalSecurityViewContainer: GlobalSecurityViewContainerProtocol {
    func createView(data: GlobalSecurityViewDataComponentsProtocol?,
                    delegate: GlobalSecurityViewDelegate?) -> UIView {
        self.viewComponent.dataComponents = data
        self.viewComponent.delegate = delegate
        self.configureStackView()
        self.createLastLogonView()
        self.createFirstRow()
        self.createSecondRow()
        self.createPasswordView()
        self.createTravelView()
        if (data?.isOtpPushEnabled ?? false) || data?.alertSecurityViewModel != nil {
            self.createFiftView()
        }
        let view = UIView()
        view.addSubview(self.mainStackView)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.mainStackView.leadingAnchor, constant: -16.0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.mainStackView.trailingAnchor, constant: 16.0).isActive = true
        view.topAnchor.constraint(equalTo: self.mainStackView.topAnchor, constant: -16.0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.mainStackView.bottomAnchor, constant: 23.0).isActive = true
        return view
    }
}

private extension GlobalSecurityViewContainer {
    func createLastLogonView() {
        guard let view = self.viewComponent.setLastLogonView() else { return }
        view.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        self.addToMainView(view)
    }
    
    func createFirstRow() {
        guard let view = viewComponent.setProtectionView() else { return }
        view.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        self.addToMainView(view)
    }
    
    func createSecondRow() {
        let stackViewRow = UIStackView()
        stackViewRow.translatesAutoresizingMaskIntoConstraints = false
        stackViewRow.axis = .horizontal
        stackViewRow.spacing = 8
        stackViewRow.distribution = .fillEqually
        stackViewRow.heightAnchor.constraint(equalToConstant: 184.0).isActive = true
        let fraudView = self.viewComponent.setReportFraudView(nil, viewStyle: .showNumberLabel)
        stackViewRow.addArrangedSubview(fraudView)
        let stackViewColumnSecond = UIStackView()
        stackViewColumnSecond.translatesAutoresizingMaskIntoConstraints = false
        stackViewColumnSecond.axis = .vertical
        stackViewColumnSecond.spacing = 8
        stackViewColumnSecond.distribution = .fillEqually
        let stolenView = self.viewComponent.setStolenView(nil, viewStyle: .showNumberLabel)
        stackViewColumnSecond.addArrangedSubview(stolenView)
        let permissionsView = self.viewComponent.setupPermissionsView()
        stackViewColumnSecond.addArrangedSubview(permissionsView)
        stackViewRow.addArrangedSubview(stackViewColumnSecond)
        self.addToMainView(stackViewRow)
    }
    
    func createPasswordView() {
        let view = self.viewComponent.setPasswordView()
        view.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        self.addToMainView(view)
    }
    
    func createTravelView() {
        let view = self.viewComponent.setTravelView()
        view.heightAnchor.constraint(equalToConstant: 96.0).isActive = true
        self.addToMainView(view)
    }
    
    func createFiftView() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.heightAnchor.constraint(equalToConstant: 184.0).isActive = true
        let secureDeviceView = self.viewComponent.setSecureDevice()
        let alertView = self.viewComponent.setAlertView()
        stackView.addArrangedSubview(secureDeviceView)
        stackView.addArrangedSubview(alertView)
        self.addToMainView(stackView)
    }
    
    func configureStackView() {
        self.mainStackView.translatesAutoresizingMaskIntoConstraints = false
        self.mainStackView.axis = .vertical
        self.mainStackView.spacing = 8
        self.mainStackView.distribution = .fill
    }
    
    func addToMainView(_ view: UIView) {
        self.mainStackView.addArrangedSubview(view)
    }
}
