//
//  SendMoneySelectAccountViewController.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine

final class SendMoneySelectAccountViewController: UIViewController {
    private let viewModel: SendMoneySelectAccountViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SendMoneySelectAccountDependenciesResolver
    
    let button = UIButton(frame: .zero)
    
    init(dependencies: SendMoneySelectAccountDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SendMoneySelectAccountViewController", bundle: .main)
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
        
        button.backgroundColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 120),
            button.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func didSelect() {
        viewModel.next()
    }
}

extension SendMoneySelectAccountViewController: StepIdentifiable {}

private extension SendMoneySelectAccountViewController {
    
    func setAppearance() {
        
    }
    
    func bind() {
        
    }
}
