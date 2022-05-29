//
//  OfferCustomTipViewModel.swift
//  Pods
//
//  Created by Tania Castellano Brasero on 31/05/2021.
//

public struct OfferCustomTipViewModel {
    public var offerEntity: OfferEntity?
    public var title: String?
    private var icon: String?
    private var baseUrl: String?
    
    public init(entity: OfferEntity?, title: String?, icon: String?, baseUrl: String?) {
        self.offerEntity = entity
        self.title = title
        self.icon = icon
        self.baseUrl = baseUrl
    }
    
    public var iconUrl: String? {
        guard let baseUrl = self.baseUrl,
              let icon = self.icon else { return nil }
        return String(format: "%@%@", baseUrl, icon)
    }
    
    public var imageBanner: String? {
        offerEntity?.banner?.url
    }
}
