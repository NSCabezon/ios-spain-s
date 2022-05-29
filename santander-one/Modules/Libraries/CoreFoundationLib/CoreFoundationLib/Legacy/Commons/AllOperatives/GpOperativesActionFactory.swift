//
//  GpOperativesActionFactory.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 08/01/2020.
//


public final class GpOperativesActionFactory {
    public func getOtherOperativesButtons(frequentOperatives: [PGFrequentOperativeOptionProtocol],
                                          disabledOptions: [PGFrequentOperativeOptionProtocol],
                                          offerImageUrls: [String: String] = [:],
                                          highlightedInfo: [String: HighlightedInfo] = [:],
                                          isSmartGP: Bool,
                                          valuesProvider: PGFrequentOperativeOptionValueProviderProtocol?,
                                          action: ((PGFrequentOperativeOptionProtocol, Void) -> Void)?) -> [GpOperativesViewModel] {
        let allCasesFiltered = frequentOperatives.filter { (option: PGFrequentOperativeOptionProtocol) -> Bool in
            return !disabledOptions.contains { (disabledOption: PGFrequentOperativeOptionProtocol) -> Bool in
                return disabledOption.rawValue == option.rawValue
            }
        }
        let allValues: [GpOperativesViewModel] = allCasesFiltered.map { (option) in
            let rawValue: String = option.rawValue
            let viewType: ActionButtonFillViewType = {
                let coreOption: PGFrequentOperativeOption? = PGFrequentOperativeOption(rawValue: rawValue)
                switch coreOption {
                case .contract, .shortcut, .correosCash:
                    if let contractOfferImage = offerImageUrls[rawValue] {
                        return .offer(OfferImageViewActionButtonViewModel(url: contractOfferImage, identifier: "image_actionBtn_\(rawValue)"))
                    } else {
                        return option.getViewType(isSmartGP: isSmartGP, valuesProvider: valuesProvider)
                    }
                default:
                    return option.getViewType(isSmartGP: isSmartGP, valuesProvider: valuesProvider)
                }
            }()
            return GpOperativesViewModel(
                type: option,
                viewType: viewType,
                action: action,
                highlightedInfo: highlightedInfo[rawValue],
                isDragDisabled: highlightedInfo[rawValue]?.isDragDisabled ?? false
            )
        }
        return allValues
    }
}
