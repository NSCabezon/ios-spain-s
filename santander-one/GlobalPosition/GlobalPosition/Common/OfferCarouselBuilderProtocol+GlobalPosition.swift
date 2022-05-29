//
//  OfferCarouselBuilderProtocol+GlobalPosition.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 23/7/21.
//

import Foundation
import OfferCarousel

extension OfferCarouselBuilderProtocol {
    func isOnlyGPTop(cellsCount: Int, cellInfos: [PGCellInfo]?, isValid: Bool) -> Bool {
        guard
            cellsCount == 1,
            isValid,
            let firstArrayWithSectionInfo = cellInfos,
            firstArrayWithSectionInfo.count == 1,
            firstArrayWithSectionInfo.first != nil
            else { return false }
        return true
    }
}
