//
//  GetOptionConfigUsecase.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/8/21.
//

import Foundation
import OpenCombine
import CoreFoundationLib
import CoreDomain

public protocol GetLoanOptionsUsecase {
    func fetchOptionsPublisher() -> AnyPublisher<[LoanOptionRepresentable], Never>
    func fetchOptionsPublisher(loanDetail: LoanDetailRepresentable) -> AnyPublisher<[LoanOptionRepresentable], Never>
}

struct DefaultGetLoanOptionsUsecase {
    private let repository: AppConfigRepositoryProtocol
    
    init(dependencies: LoanHomeExternalDependenciesResolver) {
        repository = dependencies.resolve()
    }
}

extension DefaultGetLoanOptionsUsecase: GetLoanOptionsUsecase {
    func fetchOptionsPublisher() -> AnyPublisher<[LoanOptionRepresentable], Never> {
        return Publishers.Zip(
            repository.value(for: "enableLoanRepayment", defaultValue: false),
            repository.value(for: "enableChangeLoanLinkedAccount", defaultValue: false)
        )
        .map(buildOptions)
        .eraseToAnyPublisher()
    }
    
    func fetchOptionsPublisher(loanDetail: LoanDetailRepresentable) -> AnyPublisher<[LoanOptionRepresentable], Never> {
        return Just([]).eraseToAnyPublisher()
    }
}

private extension DefaultGetLoanOptionsUsecase {
    struct LoanOption: LoanOptionRepresentable {
        let title: String
        let imageName: String
        let accessibilityIdentifier: String
        let type: LoanOptionType
        var hash: String
        let titleIdentifier: String?
        let imageIdentifier: String?
        
        init(title: String,
             imageName: String,
             accessibilityIdentifier: String,
             type: LoanOptionType,
             titleIdentifier: String?,
             imageIdentifier: String?) {
            self.title = title
            self.imageName = imageName
            self.accessibilityIdentifier = accessibilityIdentifier
            self.type = type
            self.hash = title
            self.titleIdentifier = titleIdentifier
            self.imageIdentifier = imageIdentifier
        }
    }
    
    func buildOptions(isEnabledLoanRepayment: Bool, isEnabledChangeLoanLinkedAccount: Bool) -> [LoanOptionRepresentable] {
        var options: [LoanOptionRepresentable] = []
        options.append(
            LoanOption(title: "loansOption_button_anticipatedAmortization",
                       imageName: "icnEarlyRepayment",
                       accessibilityIdentifier: AccessibilityIDLoansHome.optionRepaymentContainer.rawValue,
                       type: .repayment,
                       titleIdentifier: AccessibilityIDLoansHome.optionRepaymentTitleLabel.rawValue,
                       imageIdentifier: AccessibilityIDLoansHome.optionRepaymentImage.rawValue),
            conditionedBy: isEnabledLoanRepayment
        )
        options.append(
            LoanOption(title: "loansOption_button_changeAccount",
                       imageName: "icnChangeAssociatedAccount",
                       accessibilityIdentifier: AccessibilityIDLoansHome.optionChangeAccountContainer.rawValue,
                       type: .changeLoanLinkedAccount,
                       titleIdentifier: AccessibilityIDLoansHome.optionChangeAccountTitleLabel.rawValue,
                       imageIdentifier: AccessibilityIDLoansHome.optionChangeAccountImage.rawValue),
            conditionedBy: isEnabledChangeLoanLinkedAccount
        )
        options.append(
            LoanOption(title: "loansOption_button_detailLoan",
                       imageName: "icnDetail",
                       accessibilityIdentifier: AccessibilityIDLoansHome.optionDetailContainer.rawValue,
                       type: .detail,
                       titleIdentifier: AccessibilityIDLoansHome.optionDetailTitleLabel.rawValue,
                       imageIdentifier: AccessibilityIDLoansHome.optionDetailImage.rawValue)
        )
        return options
    }
}
