//
//  FakeOperativePresenter.swift
//  Operative_Example
//
//  Created by Jose Carlos Estela Anguita on 18/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Operative
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import CoreGraphics

protocol FakeOperativeStepPresenterProtocol: OperativeStepPresenterProtocol {
    func goNext()
    func setView(view: FakeOperativeViewProtocol)
    func loaded()
}

// MARK: - FakeOperativeStepPresenterProtocol

class FakeOperativeStepPresenter {
    private weak var view: FakeOperativeViewProtocol?
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    
    func validateCharacters(of text: String) -> Bool {
        return true
    }
}

// MARK: - FakeOperativeStepPresenterProtocol

extension FakeOperativeStepPresenter: FakeOperativeStepPresenterProtocol {
    func goNext() {
        let signatureDTO = SignatureDTO(length: 8, positions: [1, 3, 4, 7])
        let signature = SignatureMock(signatureDTO)
        self.container?.save(signature)
        self.container?.stepFinished(presenter: self)
    }
    
    func setView(view: FakeOperativeViewProtocol) {
        self.view = view
    }
    
    func loaded() {
        switch number {
        case 0:
            self.view?.setImage(name: "uno")
        case 1:
            self.view?.setImage(name: "dos")
        case 2:
            self.view?.setImage(name: "tres")
        default:
            self.view?.setImage(name: "cuatro")
        }
    }
}

// MARK: - OperativeStepEvaluateCapable

extension FakeOperativeStepPresenter: OperativeStepEvaluateCapable {
    func evaluateBeforeShowing(container: OperativeContainerProtocol?, action: @escaping (EvaluateBeforeShowing) -> Void) {}
    
    func evaluateBeforeShowing(_ shouldShow: @escaping (Bool, OperativeSetupError?) -> Void, container: OperativeContainerProtocol?) {
        shouldShow(true, nil)
    }
}

class SignatureMock: SignatureRepresentable {
    
    var length: Int?
    var positions: [Int]?
    var values: [String]?
    
    init(_ dto: SignatureDTO) {
        self.length = dto.length
        self.positions = dto.positions
        self.values = dto.values
    }
}
