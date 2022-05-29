//
//  TripViewModel.swift
//  PersonalArea
//
//  Created by alvola on 16/03/2020.
//

import CoreDomain
import CoreFoundationLib

struct CountriesListViewModel {
    var countries: [CountryDropdownModel]
    var reasons: [String]
}

struct TripViewModel {
    let tripEntity: TripEntity
    let timeManager: TimeManager
    init(from tripEntity: TripEntity, timeManager: TimeManager) {
        self.tripEntity = tripEntity
        self.timeManager = timeManager
    }
    
    var tripDateString: String {
        let fromDateString = timeManager
            .toString(date: tripEntity.fromDate, outputFormat: .EEE_dd_MM_yy) ?? ""
        let toDateString = timeManager
            .toString(date: tripEntity.toDate, outputFormat: .EEE_dd_MM_yy) ?? ""
        return String(format: "%@ - %@", fromDateString, toDateString).uppercased()
    }
    
    var country: String {
        return tripEntity.country.name
    }
    
    var currency: LocalizedStylableText {
        return localized(
            "yourTrips_item_currency",
            [StringPlaceholder(.value, tripEntity.currencies)]
        )
    }
    
    var tripReason: String {
        switch tripEntity.tripReason {
        case .business:
            return localized("yourTrips_label_business").uppercased()
        case .pleasure:
            return localized("yourTrips_label_pleasure").uppercased()
        }
    }
    
    static func reasonToString(_ reason: TripReason) -> String {
        switch reason {
        case .business:
            return "yourTrips_label_business"
        case .pleasure:
            return "yourTrips_label_pleasure"
        }
    }
}

// MARK: - Private Methods
fileprivate extension TripViewModel {
    
    func createAttributedCurrency() -> NSAttributedString {
        
        let currencyText: String = localized("sendMoney_label_currency") + ": "
        let attributedCurrencyText = NSMutableAttributedString(string: currencyText, attributes: [
          .font: UIFont.santander(family: .text, type: .regular, size: 16),
          .foregroundColor: UIColor.gray
        ])
        
        let attributedCurrencyValue = NSMutableAttributedString(string: currencyText, attributes: [
          .font: UIFont.santander(family: .text, type: .bold, size: 18),
          .foregroundColor: UIColor.gray
        ])
        
        attributedCurrencyText.append(attributedCurrencyValue)
        return attributedCurrencyText
    }
}

extension TripViewModel: TripDetailHeaderViewModelProtocol {
    var countryText: String {
        return country
    }
    
    var reasonText: String {
        return tripReason
    }
    
    var currencyText: LocalizedStylableText {
        return currency
    }
    
    var tripDates: String {
        return tripDateString
    }
}
