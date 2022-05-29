//
//  RepositoriesProvider.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 11/5/21.
//

import Foundation
import SANSpainLibrary
import CoreDomain

protocol RepositoriesProvider {
    var bizumRepository: BizumRepository { get }
    var loginRepository: LoginRepository { get }
    var configurationRepository: ConfigurationRepository { get }
    var sessionRepository: UserSessionRepository { get }
    var adobeTargetRepository: AdobeTargetRepository { get }
    var loansRepository: LoansDataRepository { get }
    var santanderKeyOnboardingRepository: SantanderKeyOnboardingRepository { get }
}
