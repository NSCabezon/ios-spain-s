//
//  OrganizationSelectorCoordinator.swift
//  Bizum
//

import Foundation
import CoreFoundationLib

final class OrganizationSelectorCoordinator {
    private let dependencies: DependenciesResolver
    private let navigation: UINavigationController
    
    init(dependeciesResolver: DependenciesResolver,
         navigationController: UINavigationController) {
        dependencies = dependeciesResolver
        navigation = navigationController
    }
    
    func showAllOrganizations(listDelegate: BizumDonationNGOSelectorPresenter) {
        let presenter = BizumDonationNGOListPresenter(dependenciesResolver: dependencies)
        presenter.delegate = listDelegate
        let listViewController = BizumDonationNGOListViewController(presenter: presenter)
        presenter.view = listViewController
        listViewController.modalPresentationStyle = .fullScreen
        navigation.present(listViewController, animated: true)
    }
}
