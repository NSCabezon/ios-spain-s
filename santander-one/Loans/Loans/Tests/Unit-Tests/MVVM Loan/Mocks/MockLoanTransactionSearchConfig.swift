//
//  MockLoanDetailConfig.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 25/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreDomain

struct MockLoanTransactionSearchConfig: LoanTransactionSearchConfigRepresentable {
    var isFiltersEnabled: Bool = true
    var isEnabledConceptFilter: Bool = false
    var isEnabledOperationTypeFilter: Bool = false
    var isEnabledAmountRangeFilter: Bool = true
    var isEnabledDateFilter: Bool = true
    var isDetailsCarouselEnabled: Bool = true
}
