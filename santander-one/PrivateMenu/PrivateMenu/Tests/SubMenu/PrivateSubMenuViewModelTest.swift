//
//  PrivateSubMenuViewModelTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import CoreFoundationLib
import CoreTestData
@testable import PrivateMenu
import XCTest

class PrivateSubMenuViewModelTest: XCTestCase {
    lazy var dependencies: TestPrivateSubmenuDependencies = {
        let external = TestPrivateSubMenuExternalDependencies(injector: self.mockDataInjector)
        return TestPrivateSubmenuDependencies(injector: self.mockDataInjector, externalDependencies: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
        return injector
    }()
    
    func test_When_loadFooterOptions_Then_expectedFooterOptionsReturned() throws {
        let sut = PrivateSubMenuViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        
        let publisher = sut.state
            .case(PrivateSubMenuState.footerOptions)
        let result = try publisher.sinkAwait()
        
        let expeted = expectedFooterOptions.map {
            AnyEquatable($0)
        }
        let options = result.map {
            AnyEquatable($0)
        }
        XCTAssertEqual(expeted, options)
    }
}

// MARK: - Helpers
fileprivate extension PrivateSubMenuViewModelTest {
    struct PrivateMenuFooterOption: PrivateMenuFooterOptionRepresentable {
        var title: String
        var imageName: String
        var imageURL: String?
        var accessibilityIdentifier: String
        var optionType: FooterOptionType
    }
    
    var expectedFooterOptions: [PrivateMenuFooterOptionRepresentable] {
        return [
            PrivateMenuFooterOption(
                title: "menu_link_HelpCenter",
                imageName: "icnSupportMenu",
                imageURL: nil,
                accessibilityIdentifier: "menuBtnHelpCenter",
                optionType: .helpCenter
            )
        ]
    }
}

