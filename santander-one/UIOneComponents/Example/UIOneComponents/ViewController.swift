//
//  ViewController.swift
//  UIOneComponents
//
//  Created by ADRIAN ARCALA OCON on 08/13/2021.
//  Copyright (c) 2021 ADRIAN ARCALA OCON. All rights reserved.
//

import UI
import UIKit
import CoreFoundationLib
import QuickSetup
import UIOneComponents

class ViewController: UIViewController {
    private lazy var bankingUtils: BankingUtilsProtocol = {
        let bankingUtils = BankingUtils(dependencies: dependenciesResolver)
        bankingUtils.setCountryCode("ES")
        return bankingUtils
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let viewController = OneComponentsQAViewController(dependenciesResolver: dependenciesResolver)
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        let dependencies = DependenciesDefault()
        DefaultDependenciesInitializer(dependencies: dependencies).registerDefaultDependencies()
        dependencies.register(for: BankingUtilsProtocol.self) { _ in
            return self.bankingUtils
        }
        dependencies.register(for: ColorsByNameEngine.self) { _ in
            ColorsByNameEngine()
        }
        return dependencies
    }()
}
