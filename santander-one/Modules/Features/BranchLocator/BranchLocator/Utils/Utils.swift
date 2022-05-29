//
//  Utils.swift
//  LocatorApp
//
//  Created by vectoradmin on 28/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit
import MapKit

func getLanguageOption(from dict: [String: Any]) -> String {
    if let region = Locale.current.languageCode?.lowercased(),
        let str = dict[region] as? String {
        return str
    } else if let str = dict["default"] as? String {
        return str
    } else {
        return ""
    }
}
public enum Maps {
    case googleMaps
    case waze
    case appleMaps
}

// [.googleMaps,.AppleMaps]
public func navigateToDestination(latitude: Double, longitude: Double, urlLauncher: URLLauncher, navigationMaps: [Maps]) {
    
    var navigationMapsToOpen = navigationMaps
    
    switch navigationMapsToOpen.first {
        
    case .googleMaps:
        if !openWithGoogleMaps(latitude: latitude, longitude: longitude, urlLauncher: urlLauncher){
            navigationMapsToOpen.removeFirst()
            navigateToDestination(latitude: latitude, longitude: longitude, urlLauncher: urlLauncher, navigationMaps: navigationMapsToOpen)
        }
    case .waze:
        if !openWithWazeMaps(latitude: latitude, longitude: longitude, urlLauncher: urlLauncher){
            navigationMapsToOpen.removeFirst()
            navigateToDestination(latitude: latitude, longitude: longitude, urlLauncher: urlLauncher, navigationMaps: navigationMapsToOpen)
        }
    case .appleMaps:
        openWithAppleMaps(latitude: latitude, longitude: longitude, urlLauncher: urlLauncher)
    case .none:
        openWithAppleMaps(latitude: latitude, longitude: longitude, urlLauncher: urlLauncher)
    }
    
}

private func openWithGoogleMaps(latitude: Double, longitude: Double, urlLauncher: URLLauncher) -> Bool{
    //    https://developers.google.com/maps/documentation/urls/ios-urlscheme
    if urlLauncher.canOpen(url: URL(string: "comgooglemaps://")!) {
        urlLauncher.open(url: URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)")!)
        //AnalyticsHandler.track(event: .navigateTurnByTurnGoogle, isScreen: false)
        return true
    }
    return false
}

private func openWithWazeMaps(latitude: Double, longitude: Double, urlLauncher: URLLauncher) -> Bool{
    //    https://developers.google.com/maps/documentation/urls/ios-urlscheme
    if urlLauncher.canOpen(url: URL(string: "waze://")!) {
        urlLauncher.open(url: URL(string: "waze://?ll=\(latitude),\(longitude)&navigate=yes")!)
        //AnalyticsHandler.track(event: .navigateTurnByTurnWaze, isScreen: false)
        return true
    }
    return false
}

private func openWithAppleMaps(latitude: Double, longitude: Double, urlLauncher: URLLauncher){
    // https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html#//apple_ref/doc/uid/TP40007899-CH5-SW1
    if urlLauncher.canOpen(url: URL(string: "http://maps.apple.com/")!) {
        urlLauncher.open(url: URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)")!)
        //AnalyticsHandler.track(event: .navigateTurnByTurnApple, isScreen: false)
    }
}
