//
//  OnBoardingStep1.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 2/12/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol Step1DependenciesResolver {
    func resolve() -> OnBoardingDependencies
    func resolve() -> OnBoardingStep1ViewController
    func resolve() -> DataBinding
}

extension Step1DependenciesResolver {
    
    func resolve() -> OnBoardingStep1ViewController {
        return OnBoardingStep1ViewController(dependencies: resolve())
    }
}

struct Step1Dependencies: Step1DependenciesResolver {
    var depencies: OnBoardingDependencies
    var dataBinding: DataBinding {
        return depencies.resolve()
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> OnBoardingDependencies {
        return depencies
    }
}

final class OnBoardingStep1ViewController: UIViewController, StepIdentifiable {
    
    let dependencies: OnBoardingDependencies
    
    init(dependencies: OnBoardingDependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Async.after(seconds: 1.0) {
            self.dependencies.resolve().next()
        }
    }
}
