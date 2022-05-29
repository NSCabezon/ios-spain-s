//
//  AmountTextFieldFormatterTests.swift
//  UI_ExampleTests
//
//  Created by José María Jiménez Pérez on 23/6/21.
//
// swiftlint:disable all
import XCTest
@testable import UI
@testable import CoreFoundationLib

class MockChangeTestFieldDelegate: ChangeTextFieldDelegate {
    var lastObservedText: String!
    
    func willChangeText(textField: UITextField, text: String) {
        lastObservedText = text
    }
}

class AmountTextFieldFormatterNoDecimalsTests: XCTestCase {
    var sut: UIAmountTextFieldFormatter!
    var textField: UITextField!
    var inspector: MockChangeTestFieldDelegate!
    
    override func setUp() {
        sut = UIAmountTextFieldFormatter(maximumIntegerDigits: 12, maximumFractionDigits: 0)
        inspector = MockChangeTestFieldDelegate()
        sut.customDelegate = inspector
        textField = UITextField()
        textField.delegate = sut
        let dependencies = DependenciesDefault()
        NumberFormattingHandler.shared.setup(dependenciesResolver: dependencies)
    }
    
    func test_thousandValue() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        XCTAssertTrue(textField.text == "1.000")
        XCTAssertTrue(inspector.lastObservedText == "1000")
    }
    
    func test_thousandValueNoPoint() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        XCTAssertTrue(textField.text == "1.000")
        XCTAssertTrue(inspector.lastObservedText == "1000")
    }
    
    func test_tenThousandValue() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        XCTAssertTrue(textField.text == "10.000")
        XCTAssertTrue(inspector.lastObservedText == "10000")
    }
    
    func test_tenThousandValueNoPoint() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        XCTAssertTrue(textField.text == "10.000")
        XCTAssertTrue(inspector.lastObservedText == "10000")
    }
    
    func test_1M() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        XCTAssertTrue(textField.text == "1.000.000")
        XCTAssertTrue(inspector.lastObservedText == "1000000")
    }
}

class AmountTextFieldFormatterTwoDecimalsTests: XCTestCase {
    var sut: UIAmountTextFieldFormatter!
    var textField: UITextField!
    var inspector: MockChangeTestFieldDelegate!
    
    override func setUp() {
        sut = UIAmountTextFieldFormatter(maximumIntegerDigits: 12, maximumFractionDigits: 2)
        inspector = MockChangeTestFieldDelegate()
        sut.customDelegate = inspector
        textField = UITextField()
        textField.delegate = sut
        let dependencies = DependenciesDefault()
        NumberFormattingHandler.shared.setup(dependenciesResolver: dependencies)
    }
    
    func test_thousandValue() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "0")
        XCTAssertTrue(textField.text == "1.000")
        XCTAssertTrue(inspector.lastObservedText == "1000")
    }
    
    func test_DecimalInputOnlyDecimalSeparatorWithDot() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        XCTAssertTrue(textField.text == "0,")
        XCTAssertTrue(inspector.lastObservedText == "0.")
    }
    
    func test_DecimalInputOnlyDecimalSeparatorWithComma() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        XCTAssertTrue(textField.text == "0,")
        XCTAssertTrue(inspector.lastObservedText == "0.")
    }
    
    func test_DecimalOnlySeparatorAndFractionWithDot() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "0,13")
        XCTAssertTrue(inspector.lastObservedText == "0.13")
    }
    
    func test_DecimalOnlySeparatorAndFractionWithComma() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "0,13")
        XCTAssertTrue(inspector.lastObservedText == "0.13")
    }
    
    func test_DecimalWithDot() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "14,13")
        XCTAssertTrue(inspector.lastObservedText == "14.13")
    }
    
    func test_DecimalWithComma() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "14,13")
        XCTAssertTrue(inspector.lastObservedText == "14.13")
    }
    
    func test_multipleDecimalSeparatorWithComma() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "14,13")
        XCTAssertTrue(inspector.lastObservedText == "14.13")
    }
    
    func test_multipleDecimalSeparatorWithDot() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "14,13")
        XCTAssertTrue(inspector.lastObservedText == "14.13")
    }
    
    func test_multipleDecimalSeparatorMixed() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "14,13")
        XCTAssertTrue(inspector.lastObservedText == "14.13")
    }
    
    func test_multipleDecimalSeparatorMixedReverse() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "14,13")
        XCTAssertTrue(inspector.lastObservedText == "14.13")
    }
    
    func test_thousandsAndDecialsWithComma() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "5")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "6")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ",")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "1.456,34")
        XCTAssertTrue(inspector.lastObservedText == "1456.34")
    }
    
    func test_thousandsAndDecialsWithDot() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "5")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "6")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == "1.456,34")
        XCTAssertTrue(inspector.lastObservedText == "1456.34")
    }
}

class AmountTextFieldFormatterPolandTests: XCTestCase {
    var sut: UIAmountTextFieldFormatter!
    var textField: UITextField!
    var inspector: MockChangeTestFieldDelegate!
    
    override func setUp() {
        sut = UIAmountTextFieldFormatter(maximumIntegerDigits: 12, maximumFractionDigits: 2)
        inspector = MockChangeTestFieldDelegate()
        sut.customDelegate = inspector
        textField = UITextField()
        textField.delegate = sut
        let dependencies = DependenciesDefault()
        dependencies.register(for: AmountFormatterProvider.self) { _ in
            return PolandTestFormatter()
        }
        NumberFormattingHandler.shared.setup(dependenciesResolver: dependencies)
    }
    
    func test_Poland() {
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "1")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "5")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "6")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "7")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "7")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "7")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "7")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "7")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "7")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: ".")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "3")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSMakeRange(textField.text!.count, 0), replacementString: "4")
        XCTAssertTrue(textField.text == formatterForRepresentation(.amountTextField(maximumFractionDigits: 2, maximumIntegerDigits: 12)).string(from: Decimal(string: "1456777777.34")! as NSNumber))
        XCTAssertTrue(inspector.lastObservedText == "1456777777.34")
    }
}


class PolandTestFormatter: AmountFormatterProvider {
    func formatterForRepresentation(_ amountRepresentation: AmountRepresentation) -> NumberFormatter? {
        if case let .amountTextField(maximumFractionDigits, maximumIntegerDigits) = amountRepresentation {
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "pl_PL")
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = maximumFractionDigits
            formatter.maximumIntegerDigits = maximumIntegerDigits
            return formatter
        }
        return nil
    }
}
// swiftlint:enable all
