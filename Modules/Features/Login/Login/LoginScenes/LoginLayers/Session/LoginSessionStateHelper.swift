//
//  LoginSessionStateHelper.swift
//  Login
//
//  Created by Hernán Villamil on 20/10/21.
//

import Foundation

public final class LoginSessionStateHelper {
    private weak var delegate: LoginSessionStateprotocol?
    
    public init() { }
    
    func setDelegate(_ delegate: LoginSessionStateprotocol) {
        self.delegate = delegate
    }
    
    public func onBloqued() {
        delegate?.onBloqued()
    }
    
    public func onOtp(firsTime: Bool) {
        delegate?.onOtp(firsTime: firsTime, userName: nil)
    }
}
