//
//  StepIdentifiable.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 1/12/21.
//

import Foundation

public protocol StepIdentifiable: UIViewController {
    static var stepName: String { get }
}

extension StepIdentifiable {
    public static var stepName: String {
        return String(describing: type(of: Self.self))
    }
}
