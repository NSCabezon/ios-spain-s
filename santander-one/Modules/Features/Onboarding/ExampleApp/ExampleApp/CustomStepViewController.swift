//
//  CustomStepViewController.swift
//  ExampleApp
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import UIKit
import UI

final class CustomStepViewController: UIViewController, StepIdentifiable {
    private let label = UILabel()
    
    override func viewDidLoad() {
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func configView() {
        view.backgroundColor = .white
        view.addSubview(label)
        configLabel()
    }
    
    func configLabel() {
        label.text = "Custom Step"
        label.font = .systemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
