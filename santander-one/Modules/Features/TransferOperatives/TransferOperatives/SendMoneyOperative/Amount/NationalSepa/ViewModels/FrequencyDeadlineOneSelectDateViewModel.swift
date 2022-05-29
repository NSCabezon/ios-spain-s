//
//  FrequencyDeadlineOneSelectDateViewModel.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 1/10/21.
//

import Foundation
import CoreFoundationLib

struct FrequencyDeadlineOneSelectDateViewModel {
    let deadlineCheckBoxViewModel: OneCheckboxViewModel?
    let startDateViewModel: OneInputDateViewModel?
    let endDateViewModel: OneInputDateViewModel?
    
    init(startDateViewModel: OneInputDateViewModel? = nil,
         endDateViewModel: OneInputDateViewModel? = nil,
         deadlineCheckBoxViewModel: OneCheckboxViewModel? = nil) {
        self.startDateViewModel = startDateViewModel
        self.endDateViewModel = endDateViewModel
        self.deadlineCheckBoxViewModel = deadlineCheckBoxViewModel
    }
}
