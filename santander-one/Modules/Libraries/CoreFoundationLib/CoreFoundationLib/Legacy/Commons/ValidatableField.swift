//
//  ValidatableField.swift
//  Commons
//
//  Created by Margaret López Calderon on 14/07/2020.
//

import Foundation

public protocol ValidatableField: AnyObject {
    var fieldValue: String? { get set }
}

public protocol ValidatableFormPresenterProtocol: AnyObject {
    var fields: [ValidatableField] { get set }
    func validatableFieldChanged()
}

public extension ValidatableFormPresenterProtocol {
    var isValidForm: Bool {
        return !(fields.filter { (($0.fieldValue ?? "").isEmpty) }.count > 0)
    }
}

public protocol UpdatableTextFieldDelegate: AnyObject {
    func updatableTextFieldDidUpdate()
}

public protocol ValidatableFormViewProtocol: AnyObject {
    func updateContinueAction(_ enable: Bool)
}
