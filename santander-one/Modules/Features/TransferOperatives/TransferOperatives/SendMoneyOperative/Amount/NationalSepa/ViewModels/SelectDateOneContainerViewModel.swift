//
//  SelectDateOneContainerViewModel.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 13/10/21.
//

import Foundation
import CoreFoundationLib

struct SelectDateOneContainerViewModel {
    let selectionDateOneFilterViewModel: SelectionDateOneFilterViewModel
    let oneInputSelectFrequencyViewModel: OneInputSelectViewModel
    let frequencyDeadlineOneSelectDateViewModel: FrequencyDeadlineOneSelectDateViewModel
    let oneInputSelectViewModel: OneInputSelectViewModel?
    let oneInputDateViewModel: OneInputDateViewModel
    let dependenciesResolver: DependenciesResolver
    
    init(selectionDateOneFilterViewModel: SelectionDateOneFilterViewModel,oneInputSelectFrequencyViewModel: OneInputSelectViewModel, frequencyDeadlineOneSelectDateViewModel: FrequencyDeadlineOneSelectDateViewModel, oneInputSelectViewModel: OneInputSelectViewModel?, oneInputDateViewModel: OneInputDateViewModel, dependenciesResolver: DependenciesResolver) {
        self.selectionDateOneFilterViewModel = selectionDateOneFilterViewModel
        self.oneInputSelectFrequencyViewModel = oneInputSelectFrequencyViewModel
        self.frequencyDeadlineOneSelectDateViewModel = frequencyDeadlineOneSelectDateViewModel
        self.oneInputSelectViewModel = oneInputSelectViewModel
        self.oneInputDateViewModel = oneInputDateViewModel
        self.dependenciesResolver = dependenciesResolver
    }
}
