//
//  FintechTPPConfirmationPresenterTests.swift
//  Ecommerce_ExampleTests
//
//  Created by César González Palomino on 07/05/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import SANLibraryV3
import ESCommons
import LocalAuthentication
import CoreTestData
@testable import Ecommerce

class FintechTPPConfirmationPresenterTests: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let appConfigRepository: AppConfigRepositoryProtocol = MockAppConfigRepository(mockDataInjector: MockDataInjector(mockDataProvider: MockDataProvider()))
    private let appRepository: AppRepositoryProtocol = AppRepositoryMock()
    private var quickSetup: QuickSetup = QuickSetup.shared
    
    // mocks
    private var viewMock: FintechTPPConfirmationViewMock!
    private var getRememberedUserNameUseCaseMock: GetRememberedUserNameUseCaseMock!
    private var fintechConfirmAccessKeyUseCaseMock: FintechConfirmAccessKeyUseCaseMock!
    private var fintechConfirmFootprintUseCase: FintechConfirmFootprintUseCaseMock!
    private var getTouchIdLoginDataUseCaseMock: GetTouchIdLoginDataUseCaseMock!
    private var userAuthenticationRepresentableMock: FintechUserAuthenticationRepresentable!
    private var touchIdDataMock: TouchIdData!
    private var useCaseHandlerMock: UseCaseHandler!
    private var coordinator: FintechTPPConfirmationCoordinatorMock!
    private var configurationMock: FintechTPPConfiguration!
    private var authenticationPermissionsManagerMock: LocalAuthenticationPermissionsManagerMock!
    var sut: FintechTPPConfirmationPresenterProtocol!

    override func setUpWithError() throws {
        setupMocks()
        setDependencies()
        self.quickSetup.setEnviroment(BSANEnvironments.environmentPre)
        self.quickSetup.doLogin(withUser: .demo)
        self.sut = FintechTPPConfirmationPresenter(dependenciesResolver: dependencies)
        self.viewMock = FintechTPPConfirmationViewMock(presenter: sut)
        sut.view = viewMock
    }
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewMock = nil
        sut = nil
    }
    
    func setupMocks() {
        dependencies.register(for: AppRepositoryProtocol.self) { _ in
            self.appRepository
        }
        dependencies.register(for: BSANManagersProvider.self, with: { _ in
            self.quickSetup.managersProvider
        })
        self.touchIdDataMock = TouchIdData(deviceMagicPhrase: "",
                                               touchIDLoginEnabled: true,
                                               footprint: "")
        dependencies.register(for: CompilationProtocol.self, with: { _ in
            CompilationProtocolMock()
        })
        dependencies.register(for: TouchIdData.self, with: { _ in
            self.touchIdDataMock
        })
        self.userAuthenticationRepresentableMock = FintechUserAuthenticationRepresentableMock()
        self.configurationMock = FintechTPPConfiguration(self.userAuthenticationRepresentableMock)
        self.getRememberedUserNameUseCaseMock = GetRememberedUserNameUseCaseMock(dependenciesResolver: dependencies)
        self.fintechConfirmAccessKeyUseCaseMock = FintechConfirmAccessKeyUseCaseMock(dependenciesResolver: dependencies)
        self.fintechConfirmFootprintUseCase = FintechConfirmFootprintUseCaseMock(dependenciesResolver: dependencies)
        self.coordinator = FintechTPPConfirmationCoordinatorMock()
        self.getTouchIdLoginDataUseCaseMock = GetTouchIdLoginDataUseCaseMock(dependenciesResolver: dependencies)
        self.useCaseHandlerMock = UseCaseHandlerMock()
        self.authenticationPermissionsManagerMock = LocalAuthenticationPermissionsManagerMock()
    }

    func test_viewDidLoad_shouldAlwaysAskViewToSetState() {
        let exp = expectation(description: "")
        viewMock.state = nil
        sut.viewDidLoad()
        XCTAssertNotNil(viewMock.state)
        Async.after(seconds: 0.2) {
            XCTAssertNotNil(self.viewMock.state)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func test_viewDidLoad_shouldSetCorrectState_Loading() {
        sut.viewDidLoad()
        XCTAssert(viewMock.state == .loading)
    }
    
    func test_viewDidLoad_whenSuccessResponse_shouldSetCorrectState_Home() {
        let exp = expectation(description: "")
        sut.viewDidLoad()
        Async.after(seconds: 0.2) {
            switch self.viewMock.state {
            case .home:
                exp.fulfill()
            default:
                XCTFail("incorrect view State")
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func test_confirmWithEcommerceTypeFaceOrTouchID_whenSuccessResponse_shouldSetCorrectState() {
        let exp = expectation(description: "")
        sut.viewDidLoad()
        Async.after(seconds: 0.2) {
            self.sut.confirm(withType: EcommerceAuthType.faceId)
            Async.after(seconds: 0.4) {
                switch self.viewMock.state {
                case .success:
                    exp.fulfill()
                default:
                    XCTFail("incorrect view State")
                }
            }
            
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func test_confirmWithEcommerceTypeFaceOrTouchID_whenFailureResponse_shouldSetCorrectState() {
        let exp = expectation(description: "")
        sut.viewDidLoad()
        Async.after(seconds: 0.2) {
            self.authenticationPermissionsManagerMock.setFailureResponse()
            self.sut.confirm(withType: EcommerceAuthType.faceId)
            Async.after(seconds: 0.4) {
                switch self.viewMock.state {
                case .home(_, let authStatus, _, _):
                    XCTAssert(authStatus == .notConfirmed, "incorrect view state")
                    exp.fulfill()
                default:
                    break
                }
            }
            
        }
        waitForExpectations(timeout: 1.0)
    }

    func setDependencies() {
        
        dependencies.register(for: FintechTPPConfirmationViewProtocol.self) { _ in
            self.viewMock
        }
        
        dependencies.register(for: GetRememberedUserNameUseCase.self) { _ in
            self.getRememberedUserNameUseCaseMock
        }
        
        dependencies.register(for: FintechConfirmAccessKeyUseCase.self) { _ in
            self.fintechConfirmAccessKeyUseCaseMock
        }
        
        dependencies.register(for: FintechUserAuthenticationRepresentable.self) { _ in
            self.userAuthenticationRepresentableMock
        }
        
        dependencies.register(for: UseCaseHandler.self) { _ in
            UseCaseHandler()
        }
        
        dependencies.register(for: FintechTPPConfiguration.self) { _ in
            self.configurationMock
        }
        dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            self.appConfigRepository
        }
        
        dependencies.register(for: GetTouchIdLoginDataUseCase.self) { _ in
            self.getTouchIdLoginDataUseCaseMock
        }
        
        dependencies.register(for: LocalAuthenticationPermissionsManagerProtocol.self) { _ in
            self.authenticationPermissionsManagerMock
        }
        
        dependencies.register(for: FintechConfirmFootprintUseCase.self) { _ in
            self.fintechConfirmFootprintUseCase
        }
        
        dependencies.register(for: FintechTPPConfirmationCoordinatorProtocol.self) { _ in
            self.coordinator
        }
    }

}

extension FintechTPPConfirmationState: Equatable {
    public static func == (lhs: FintechTPPConfirmationState, rhs: FintechTPPConfirmationState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.identifyRemembered, identifyRemembered):
            return true
        case (.identifyUnremembered, identifyUnremembered):
            return true
        case (.success, success):
            return true
        case (.error, error):
            return true
        case (.home, home):
            return true
        default:
            return false
        }
    }
}
