//
//  PrivateViewModelTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import CoreFoundationLib
import CoreTestData
@testable import PrivateMenu
import XCTest

class PrivateMenuViewModelTest: XCTestCase {
    lazy var dependencies: TestPrivateMenuDependencies = {
        let external = TestPrivateMenuExternalDependencies(injector: self.mockDataInjector)
        return TestPrivateMenuDependencies(injector: self.mockDataInjector, externalDependencies: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
        return injector
    }()
    
    func test_When_loadMenuOptions_then_expectedOptionsReturned() throws {
        let sut = PrivateMenuViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        
        let publisher = sut.state
            .case(PrivateMenuState.menuOptions)
        let result = try publisher.sinkAwait()
        
        let expeted = expectedMenuOptions.map {
            AnyEquatable($0)
        }
        let options = result.map {
            AnyEquatable($0)
        }
        XCTAssertEqual(expeted, options)
    }
    
    func test_When_loadFooterOptions_Then_expectedFooterOptionsReturned() throws {
        let sut = PrivateMenuViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        
        let publisher = sut.state
            .case(PrivateMenuState.footerOptions)
        let result = try publisher.sinkAwait()
        
        let expeted = expectedFooterOptions.map {
            AnyEquatable($0)
        }
        let options = result.map {
            AnyEquatable($0)
        }
        XCTAssertEqual(expeted, options)
    }
    
    func test_When_isDigitalProfileEnabled_Then_digitalProfileEnabledIsReturned() throws {
        let sut = PrivateMenuViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(PrivateMenuState.isDigitalProfileEnabled)
        let isDigitalProfileEnabled = try publisher.sinkAwait()
        XCTAssertNotNil(isDigitalProfileEnabled)
    }
    
    func test_When_loadNameOrAlias_Then_nameOrAliasReturned() throws {
        let sut = PrivateMenuViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(PrivateMenuState.nameOrAlias)
        let nameOrAlias = try publisher.sinkAwait()
        XCTAssertNotNil(nameOrAlias)
        XCTAssertEqual(nameOrAlias.availableName, "PILAR RODRIGUEZ")
        XCTAssertEqual(nameOrAlias.initials, "PR")
    }
    
    func test_When_loadAvatarImage_Then_avatarImageReturned() throws {
        let sut = PrivateMenuViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(PrivateMenuState.avatarImage)
        let avatarImage = try publisher.sinkAwait()
        XCTAssertNotNil(avatarImage)
        XCTAssertEqual(avatarImage, Data("F15869".utf8))
    }
}

// MARK: - Helpers
fileprivate extension PrivateMenuViewModelTest {
    struct PrivateMenuOption: PrivateMenuOptionRepresentable {
        var imageKey: String
        var titleKey: String
        var extraMessageKey: String?
        var newMessageKey: String?
        var imageURL: String?
        var showArrow: Bool
        var isHighlighted: Bool
        var type: PrivateMenuOptions
        var isFeatured: Bool
        var accesibilityIdentifier: String?
    }
    
    var expectedMenuOptions: [PrivateMenuOptionRepresentable] {
        return [
            PrivateMenuOption(
                imageKey: "icnPgMenuRed",
                titleKey: "menu_link_pg",
                extraMessageKey: "",
                newMessageKey: "",
                imageURL: nil,
                showArrow: false,
                isHighlighted: true,
                type: .globalPosition,
                isFeatured: false,
                accesibilityIdentifier: "btnPg"
            )
        ]
    }
    
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
