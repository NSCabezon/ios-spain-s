//
//  LoginCoordinatorDelegate.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

public protocol LoginModuleCoordinatorProtocol {
    var navigationController: UINavigationController? { get set }
    func start(_ section: LoginSection)
}

public enum LoginSection: CaseIterable {
    case unrememberedLogin
    case loginRemembered
    case quickBalance
}
