//
//  OnBoardingStep2.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 2/12/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol Step2DependenciesResolver {
    func resolve() -> OnBoardingDependencies
}

extension Step2DependenciesResolver {
    
    func resolve() -> OnBoardingStep2ViewController {
        return OnBoardingStep2ViewController(dependencies: resolve())
    }
}

struct Step2Dependencies: Step2DependenciesResolver {
    
    var depencies: OnBoardingDependencies
    var dataBinding: DataBinding {
        return depencies.resolve()
    }
    
    func resolve() -> OnBoardingDependencies {
        return depencies
    }
}

final class OnBoardingStep2ViewController: UIViewController, StepIdentifiable {
    
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
        self.view.backgroundColor = .red
    }
}
