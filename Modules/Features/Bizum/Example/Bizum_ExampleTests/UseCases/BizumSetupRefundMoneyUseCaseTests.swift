//
//  BizumPreSetupRefundMoneyUseCaseTests.swift
//  Bizum_ExampleTests
//
//  Created by José Carlos Estela Anguita on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import QuickSetupES
@testable import SANLibraryV3
@testable import SANLegacyLibrary
import CoreFoundationLib
@testable import Bizum

final class BizumSetupRefundMoneyUseCaseTests: XCTestCase {
    
    private let dependencies = DependenciesDefault()
    private let appConfig = AppConfigRepositoryMock()
    private var useCase: SetupBizumRefundMoneyUseCase {
        return SetupBizumRefundMoneyUseCase(dependenciesResolver: self.dependencies)
    }
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        return QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }
    private let checkPaymentStub = BizumCheckPaymentEntity(BizumCheckPaymentDTO(phone: "", contractIdentifier: BizumCheckPaymentContractDTO(center: CentroDTO(), subGroup: "", contractNumber: ""), initialDate: Date(), endDate: Date(), back: nil, message: nil, ibanCode: BizumCheckPaymentIBANDTO(country: "", controlDigit: "", codbban: ""), offset: nil, offsetState: nil, indMigrad: "", xpan: ""))
    
    override func setUp() {
        super.setUp()
        self.dependencies.register(for: AppRepositoryProtocol.self) { _  in
            return AppRepositoryMock()
        }
        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _  in
            return self.appConfig
        }
        self.dependencies.register(for: BSANManagersProvider.self, with: { _ in
            return self.quickSetup.managersProvider
        })
        self.dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            return self.quickSetup.getGlobalPosition()!
        }
        self.dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver,
                                                         globalPosition: globalPosition,
                                                         saveUserPreferences: true)
            return merger
        }
        quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
    }
    
    override func tearDown() {
        super.tearDown()
        quickSetup.setDemoAnswers([:])
    }
}
