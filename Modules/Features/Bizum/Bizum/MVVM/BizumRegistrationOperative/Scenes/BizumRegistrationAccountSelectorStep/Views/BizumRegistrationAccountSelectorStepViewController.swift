//
//  BizumRegistrationAccountSelectorStepViewController.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 25/4/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine

final class BizumRegistrationAccountSelectorStepViewController: UIViewController {
    private let viewModel: BizumRegistrationAccountSelectorStepViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: BizumRegistrationAccountSelectorStepDependenciesResolver
    
    init(dependencies: BizumRegistrationAccountSelectorStepDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "BizumRegistrationAccountSelectorStepViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

private extension BizumRegistrationAccountSelectorStepViewController {
    func setAppearance() {
        
    }
    
    func bind() {
        
    }
}

extension BizumRegistrationAccountSelectorStepViewController: StepIdentifiable {}
