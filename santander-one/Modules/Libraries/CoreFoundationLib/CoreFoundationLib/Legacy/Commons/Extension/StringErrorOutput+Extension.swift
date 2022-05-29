//
//  StringErrorOutput.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 1/12/20.
//


extension StringErrorOutput: LocalizedError {
    
    public var localizedDescription: String {
        return self.getErrorDesc() ?? ""
    }
}
