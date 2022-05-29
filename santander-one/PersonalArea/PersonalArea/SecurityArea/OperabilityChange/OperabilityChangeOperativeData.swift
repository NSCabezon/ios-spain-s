//
//  OperabilityChangeData.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

final class OperabilityChangeOperativeData {
    
    var operabilityInd: OperabilityInd = .consultive
    var newOperabilityInd: OperabilityInd?
    var isUnderage: Bool = false
    var isSignatureBlocked: Bool = false
    var isUserWithoutCMC: Bool = false
    
    init() {}
}

enum OperabilityInd: String {
    case consultive = "C"
    case operative = "O"
    var trackName: String {
        switch self {
        case .consultive:
            return "consultivo"
        case .operative:
            return "operativo"
        }
    }
}
