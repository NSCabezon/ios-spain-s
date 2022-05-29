//
//  GetLoanPDFInfoUseCase.swift
//  Loans
//
//  Created by alvola on 2/3/22.
//

import Foundation
import OpenCombine

public protocol GetLoanPDFInfoUseCase {
    func fetchLoanPDFInfo(receiptId: String) -> AnyPublisher<Data?, Never>
}
