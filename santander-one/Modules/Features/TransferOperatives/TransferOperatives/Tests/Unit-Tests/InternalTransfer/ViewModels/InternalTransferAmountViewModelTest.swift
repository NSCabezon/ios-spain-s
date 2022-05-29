//
//  InternalTransferAmountViewModelTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by crodrigueza on 2/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import OpenCombine
import CoreFoundationLib
import CoreTestData
import CoreDomain
import UnitTestCommons
import SANLegacyLibrary

@testable import TransferOperatives

class InternalTransferAmountViewModelTest: XCTestCase {

    var dependencies: InternalTransferAmountDependenciesResolver!
    private var mockDataInjector = MockDataInjector()
    private var globalPositionMock: GlobalPositionRepresentable!
    private var sut: InternalTransferAmountViewModel!

    enum Constants {
        static let eurCurrency = CurrencyRepresented(currencyCode: CurrencyType.eur.rawValue)
        static let plnCurrency = CurrencyRepresented(currencyCode: CurrencyType.złoty.rawValue)
        static let usdCurrency = CurrencyRepresented(currencyCode: CurrencyType.dollar.rawValue)
    }

    override func setUp() {
        defaultRegistration()
        globalPositionMock = getGlobalPositionMock()
        dependencies = TestInternalTransferAmountDependencies(externalDependencies: TestInternalTransferAmountExternalDependencies())
        sut = InternalTransferAmountViewModel(dependencies: dependencies)
        setDataBinding()
    }

    override func tearDownWithError() throws {
        dependencies = nil
    }

    func test_Given_OriginAndDestinationAccount_When_LoadedStateIsCalled_Then_OriginAccountIsnotNil() throws {
        let publisher = sut.state
            .case(InternalTransferAmountState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.originAccount)
    }

    func test_Given_OriginAndDestinationAccount_When_LoadedStateIsCalled_Then_DestinationAccountIsnotNil() throws {
        let publisher = sut.state
            .case(InternalTransferAmountState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.destinationAccount)
    }

    func test_Given_OriginAndDestinationAccount_When_SetAmountAndDescription_Then_IsAvailableToContinue() throws {
        let publisher = sut.state
            .case(InternalTransferAmountState.didChangeAvailabilityToContinue)
        sut.viewDidLoad()
        sut.didSetInternalTransferPresentableType(.amount("123,90"))
        sut.didSetInternalTransferPresentableType(.description("description"))
        let result = try publisher.sinkAwait()
        XCTAssertTrue(result)
    }

    func test_Given_OriginAndDestinationAccount_When_SetAmountIsNotSet_Then_Is_Not_AvailableToContinue() throws {
        let publisher = sut.state
            .case(InternalTransferAmountState.didChangeAvailabilityToContinue)
        sut.viewDidLoad()
        sut.didSetInternalTransferPresentableType(.description("description"))
        let result = try publisher.sinkAwait()
        XCTAssertFalse(result)
    }

    func test_Given_OriginAndDestinationAccount_When_SetAmountAndDate_Then_IsAvailableToContinue() throws {
        let publisher = sut.state
            .case(InternalTransferAmountState.didChangeAvailabilityToContinue)
        sut.viewDidLoad()
        sut.didSetInternalTransferPresentableType(.amount("123,90"))
        sut.didSetInternalTransferPresentableType(.issueDate(Date()))
        let result = try publisher.sinkAwait()
        XCTAssertTrue(result)
    }

    func test_OperativeData_Loaded_Correctly_When_View_Is_Loaded() throws {
        let publisher = sut.state
            .case(InternalTransferAmountState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.originAccount)
        XCTAssertNotNil(result.destinationAccount)
        XCTAssertNil(result.amount)
        XCTAssertNil(result.description)
        XCTAssertNotNil(result.issueDate)
        XCTAssertEqual(result.transferType, .noExchange)
    }

    func test_Given_InternalTransferType_NoExchange_Amount_Is_And_With_Correct_Decimals_numbers() throws {
        let publisher = sut.state
            .case(InternalTransferAmountState.didChangeAmount)
        sut.viewDidLoad()
        sut.operativeData.transferType = .noExchange
        sut.didSetInternalTransferPresentableType(.amount("100,4"))
        sut.updateAmountsIfNecessary()
        let result = try publisher.sinkAwait()
        XCTAssertEqual(result, "100,40")
    }

    // Transfer from an account in EUR to account in PLN
    // With following exchange rate:
    // 1 EUR -> 0.1234 PLN
    func test_Given_InternalTransferType_SimpleExchange_ReceiveAmount_Is_Correct() throws {

        let accounts = self.getAccounts()
        self.sut.operativeData.originAccount = accounts[0]
        self.sut.operativeData.destinationAccount = accounts[1]
        self.sut.operativeData.transferType = .simpleExchange(sellExchange: InternalTransferExchangeType(originCurrency: Constants.eurCurrency,
                                                                                                         destinationCurrency: Constants.plnCurrency,
                                                                                                         rate: 0.1234))
        let trigger = {
            self.sut.didSetInternalTransferPresentableType(.amount("10"))
            self.sut.updateAmountsIfNecessary()
        }

        let resultReciveAmount = try sut.state
            .case ( InternalTransferAmountState.didChangeReceiveAmount )
            .sinkAwait(beforeWait: trigger)

        let resultAmount = try sut.state
            .case ( InternalTransferAmountState.didChangeAmount )
            .sinkAwait(beforeWait: trigger)

        XCTAssertEqual(resultReciveAmount, "1,23")
        XCTAssertEqual(resultAmount, "10")
    }

    // EUR -> USD
    // Giving following exchange rates:
    // 1 EUR -> 0.5555 PLN
    // 1 USD -> 2.2222 PLN
    func test_Given_InternalTransferType_DoubleExchange_ReceiveAmount_Is_Correct2() throws {

        let accounts = self.getAccounts()
        self.sut.operativeData.originAccount = accounts[0]
        self.sut.operativeData.destinationAccount = accounts[2]
        self.sut.operativeData.transferType = .doubleExchange(sellExchange: InternalTransferExchangeType(originCurrency: Constants.eurCurrency,
                                                                                                         destinationCurrency: Constants.plnCurrency,
                                                                                                         rate: 0.5555),
                                                              buyExchange: InternalTransferExchangeType(originCurrency: Constants.plnCurrency,
                                                                                                        destinationCurrency: Constants.usdCurrency,
                                                                                                        rate: 2.2222))

        let trigger = {
            self.sut.didSetInternalTransferPresentableType(.amount("10"))
            self.sut.updateAmountsIfNecessary()
        }

        let resultReciveAmount = try sut.state
            .case ( InternalTransferAmountState.didChangeReceiveAmount )
            .sinkAwait(beforeWait: trigger)

        XCTAssertEqual(resultReciveAmount, "2,49")
    }

    // Transfer PLN -> USD
    // With following exchanges:
    // 1 PLN -> 0.5555 EUR
    // 1 PLN -> 2.2222 USD
    func test_Given_InternalTransferType_DoubleExchange_ReceiveAmount_Is_Correct3() throws {

        let accounts = self.getAccounts()
        self.sut.operativeData.originAccount = accounts[1]
        self.sut.operativeData.destinationAccount = accounts[2]
        self.sut.operativeData.transferType = .doubleExchange(sellExchange: InternalTransferExchangeType(originCurrency: Constants.plnCurrency,
                                                                                                         destinationCurrency: Constants.eurCurrency,
                                                                                                         rate: 0.5555),
                                                              buyExchange: InternalTransferExchangeType(originCurrency: Constants.plnCurrency,
                                                                                                        destinationCurrency: Constants.usdCurrency,
                                                                                                        rate: 2.2222))
        let trigger = {
            self.sut.didSetInternalTransferPresentableType(.amount("10"))
            self.sut.updateAmountsIfNecessary()
        }

        let resultReciveAmount = try sut.state
            .case ( InternalTransferAmountState.didChangeReceiveAmount )
            .sinkAwait(beforeWait: trigger)

        XCTAssertEqual(resultReciveAmount, "12,34")
    }
}

extension InternalTransferType: Equatable {
    public static func ==(lhs: InternalTransferType, rhs: InternalTransferType) -> Bool {
        switch (lhs, rhs) {
        case (.noExchange, .noExchange):
            return true
        case (let .simpleExchange(lhs_exchange), let .simpleExchange(rhs_exchange)):
            return lhs_exchange == rhs_exchange
        case (let .doubleExchange(lhs_exchange1, lhs_exchange12),let .doubleExchange(rhs_exchange1, rhs_exchange2)):
            return (lhs_exchange1, lhs_exchange12) == (rhs_exchange1, rhs_exchange2)
        default:
            return false
        }
    }
}

extension InternalTransferExchangeType: Equatable {
    public static func == (lhs: InternalTransferExchangeType, rhs: InternalTransferExchangeType) -> Bool {
        return lhs.destinationCurrency.currencyType == rhs.destinationCurrency.currencyType &&
        lhs.originCurrency.currencyType == rhs.originCurrency.currencyType &&
        lhs.rate == rhs.rate
    }
}

extension InternalTransferAmountViewModelTest {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
    }

    func getGlobalPositionMock() -> GlobalPositionMock {
        return GlobalPositionMock(
            self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
            cardsData: [:],
            temporallyOffCards: [:],
            inactiveCards: [:],
            cardBalances: [:]
        )
    }

    func setDataBinding() {
        let dataBinding: DataBinding = dependencies.resolve()
        let operativeData = InternalTransferOperativeData()
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }
        operativeData.originAccount = accounts[0]
        operativeData.destinationAccount = accounts[1]
        dataBinding.set(operativeData)
    }

    func getAccounts() -> [AccountDTO] {
        let jsonString = """
        [{
            "alias": "Account EUR",
            "currentBalance": {
                "value": 259.29,
                "currency": "EUR"
            },
            "isVisible": true
        },
        {
            "alias": "Account PLN",
            "currentBalance": {
                "value": 259.29,
                "currency": "PLN"
            },
            "isVisible": true
        },
        {
            "alias": "Account USD",
            "currentBalance": {
                "value": 259.29,
                "currency": "USD"
            },
            "isVisible": true
        }
        ]
        """
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let accounts = try decoder.decode([AccountDTO].self, from: jsonData)
            return accounts
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
}

