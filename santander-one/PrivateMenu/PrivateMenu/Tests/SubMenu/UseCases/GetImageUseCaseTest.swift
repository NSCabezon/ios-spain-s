//
//  GetImageUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

@testable import PrivateMenu
import XCTest

class GetImageUseCaseTest: XCTestCase {
    func test_When_fetchImageFromUrl_dataReturned() throws {
        let sut = DefaultGetOfferImageUseCase()
        
        let url = URL(string: "https://serverftp.ciber-es.com/movilidad/files_dev/RWD/entidades/pfm/es_0049.png")!
        let data = try sut.fetchImageFromUrl(url).sinkAwait()
        XCTAssertNotNil(data)
    }
}
