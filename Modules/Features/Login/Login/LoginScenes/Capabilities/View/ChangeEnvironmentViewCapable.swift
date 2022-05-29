//
//  ChangeEnvironmentCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/27/20.
//

import Foundation
import CoreFoundationLib
import UI
import ESCommons

protocol ChangeEnvironmentViewCapable {
    var environmentButton: UIButton? { get }
    var dependenciesResolver: DependenciesResolver { get }
    func chooseEnvironment()
    func didUpdateEnvironments()
}

extension ChangeEnvironmentViewCapable {
    func updateEnvironmentsText(_ environments: [EnvironmentViewModel]) {
        var text = ""
        environments.forEach {
            text = text.appending("\($0.title)\n")
        }
        text.removeSubrange(text.index(text.endIndex, offsetBy: -1)...)
        let attributedTitle = NSMutableAttributedString(string: text)
        attributedTitle.lineSpacing(10, alignment: .center)
        self.environmentButton?.setAttributedTitle(attributedTitle, for: .normal)
        self.didUpdateEnvironments()
    }
    
    func setupEnvironmentButton() {
        let compilation = self.dependenciesResolver.resolve(for: CompilationProtocol.self)
        guard compilation.isEnvironmentsAvailable else {
            environmentButton?.isHidden = true
            return
        }
        environmentButton?.titleLabel?.lineBreakMode = .byWordWrapping
        environmentButton?.titleLabel?.textAlignment = .center
        environmentButton?.titleLabel?.numberOfLines = 2
        environmentButton?.titleLabel?.font = UIFont.santander(family: .lato, size: 14)
        environmentButton?.layer.cornerRadius = 5
        environmentButton?.layer.borderColor = UIColor.sanGreyDark.cgColor
        environmentButton?.layer.borderWidth = 0.5
    }
}
