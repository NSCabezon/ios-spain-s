//
//  GetSavingDetailUsecase.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 25/4/22.
//

import Foundation
import OpenCombine
import CoreDomain

public struct SavingDetailsInfo: SavingDetailsInfoRepresentable {
    public let type: SavingDetailElementTypeRepresentable
    public let action: SavingDetailElementActionRepresentable?
    public init(type: SavingDetailElementTypeRepresentable,
                action: SavingDetailElementActionRepresentable? = nil) {
        self.type = type
        self.action = action
    }
}

public protocol GetSavingDetailsInfoUseCase {
    func fechDetailElementsPublisher(saving: SavingProductRepresentable) -> AnyPublisher<[SavingDetailsInfoRepresentable], Error>
}

struct DefaultGetSavingDetailsInfoUseCase: GetSavingDetailsInfoUseCase {
    func fechDetailElementsPublisher(saving: SavingProductRepresentable) -> AnyPublisher<[SavingDetailsInfoRepresentable], Error> {
        let elements = [SavingDetailsInfo(type: .number, action: .share),
                        SavingDetailsInfo(type: .alias, action: .edit)]
        return Just(elements).tryMap({ output in
            return output
        }).eraseToAnyPublisher()
    }
}

