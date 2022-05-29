//
//  TextsEngineTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import FinantialTimeline

class TextsEngineTests: XCTestCase {
    
    var textsEngine: TextsEngine!
    var ctaEngine: CTAEngine!
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        TimeLine.setup(configuration: TestHelpers.stubPublicConfiguration())
        textsEngine = TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es"))
        ctaEngine = CTAEngine(locale: Locale(identifier: "es"))
    }
    
    override func tearDown() {
        textsEngine = nil
        ctaEngine = nil
        super.tearDown()
    }
    
//    func test_textsEngine_shouldAddAllTexts_ifAllVariablesInEventExists() {
//        // G
//        let text = TimeLineConfiguration.Text(
//            transactionType: "100",
//            transactionName: [:],
//            disclaimer: [:],
//            coming: [
//                "en": [
//                    [
//                        ["text": "Esto es una transferencia"],
//                        ["amount": "de %amount%"],
//                        ["transactionDescription": "de un %transactionDescription%"],
//                        ["remainingDays": "que se te va a cobrar en %remainingDays% día/s"],
//                        ["merchantName": "tu subscripción a %merchantName%"],
//                        ["productDisplayNumber": "en tu cuenta %productDisplayNumber%"],
//                        ["calculation": "en %calculation%"],
//                        ["text": "final"]
//                    ]
//                ]
//            ],
//            previous: [:],
//            CTA: ["001", "002", "003"],
//            analyticsReference: "testing"
//        )
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
//        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event", type: "json"))
//        // W
//        textsEngine.setupTexts([text], productCodes: ["en": ["1": "cuenta"]], calculationUnits: ["en": ["001": "día"]])
//        ctaEngine.setupCTAs([text], CTAs: getCTAs())
//        // T
//        expect(self.textsEngine.getText(for: event).string.trimmingCharacters(in: .whitespacesAndNewlines)) == "Esto es una transferencia de 1235 $* de un pago que se te va a cobrar en 3 día/s tu subscripción a Netflix en tu cuenta 00***384 en 6 día final"
//    }
    
    func test_textsEngine_shouldAddNotAmountText_whenTheEventDoesntHaveAmount() {
        // G
        let text = TimeLineConfiguration.Text(
            transactionType: "100",
            transactionName: [:],
            disclaimer: [:],
            coming: [
                "en": [
                    [
                        ["text": "Esto es una transferencia"],
                        ["amount": "de %amount%"],
                        ["!amount": "sin cantidad conocida"]
                    ]
                ]
            ],
            previous: [:],
            CTA: ["001", "002", "003"],
            analyticsReference: "testing"
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_without_amount", type: "json"))
        // W
        textsEngine.setupTexts([text], productCodes: [:], calculationUnits: [:], groupedMonthsDisclaimer: [:])
        ctaEngine.setupCTAs([text], CTAs: getCTAs())
        // T
//        expect(self.textsEngine.getText(for: event).string.trimmingCharacters(in: .whitespacesAndNewlines)) == "Esto es una transferencia sin cantidad conocida"
    }
    
    func test_textsEngine_getTextUnitlAmount_shouldLoadTextUntilAmount() {
        // G
        let text = TimeLineConfiguration.Text(
            transactionType: "100",
            transactionName: [:],
            disclaimer: [:],
            coming: [
                "en": [
                    [
                        ["text": "Esto es una transferencia"],
                        ["transactionDescription": "de un %transactionDescription%"],
                        ["remainingDays": "que se te va a cobrar en %remainingDays% día/s"],
                        ["amount": "de %amount%"],
                        ["merchantName": "tu subscripción a %merchantName%"],
                        ["productDisplayNumber": "en tu cuenta %productDisplayNumber%"],
                        ["calculation": "en %calculation%"],
                        ["text": "final"]
                    ]
                ]
            ],
            previous: [:],
            CTA: ["001", "002", "003"],
            analyticsReference: "testing"
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event", type: "json"))
        // W
        textsEngine.setupTexts([text], productCodes: ["en": ["1": "cuenta"]], calculationUnits: ["en": ["001": "día"]], groupedMonthsDisclaimer: [:])
        ctaEngine.setupCTAs([text], CTAs: getCTAs())
        // T
//        expect(self.textsEngine.getTextWithoutAmount(for: event).trimmingCharacters(in: .whitespacesAndNewlines)) == "Esto es una transferencia de un pago que se te va a cobrar en 3 día/s tu subscripción a Netflix en tu cuenta 00***384 en 6 día final"
    }
}

extension TimeLineEvent: DateParseable {
    
    public static var formats: [String : String] {
        let timeLineEventsFormats = TimeLineEvents.formats.map({ ($0.key.replacingOccurrences(of: "events.", with: ""), $0.value) })
        return Dictionary(uniqueKeysWithValues: timeLineEventsFormats)
    }
}

extension TextsEngineTests {
    func getCTAs() -> [String: CTAStructure] {
        let icon = Icon(URL: "", svg: "")
        let action = Action(type: "REMINDER", destinationURL: nil, delegateReference: nil, composedDescription: nil)
        return ["001": .init(name: ["es" : "Add reminder"], icon: icon, action: action, analyticsReference: "testing")]
    }
}
