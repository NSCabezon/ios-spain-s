//
//  DigitalProfileElem.swift
//  PersonalArea
//
//  Created by alvola on 13/08/2020.
//

import CoreDomain

public enum DigitalProfileElem: String, CaseIterable, DigitalProfileElemProtocol {
    case languageSelection
    case pgView
    case pgCustomization
    case pgDirectAccess
    case address
    case email
    case phoneNumber
    case mobilePayment
    case touchID
    case faceID
    case GDPR
    case geolocalization
    case safeDevice
    case operativity
    case notificationPermissions
    case alias
    case profilePicture
    
    public init?(digitalProfileElemProtocol: DigitalProfileElemProtocol) {
        switch digitalProfileElemProtocol.identifier {
        case "languageSelection": self = .languageSelection
        case "pgView": self = .pgView
        case "pgCustomization": self = .pgCustomization
        case "pgDirectAccess": self = .pgDirectAccess
        case "address": self = .address
        case "email": self = .email
        case "phoneNumber": self = .phoneNumber
        case "mobilePayment": self = .mobilePayment
        case "touchID": self = .touchID
        case "faceID": self = .faceID
        case "GDPR": self = .GDPR
        case "geolocalization": self = .geolocalization
        case "safeDevice": self = .safeDevice
        case "operativity": self = .operativity
        case "notificationPermissions": self = .notificationPermissions
        case "alias": self = .alias
        case "profilePicture": self = .profilePicture
        default: return nil
        }
    }
    
    public var identifier: String {
        return self.rawValue
    }
    
    public func value() -> Int {
        return valueMap[self] ?? 0
    }
    
    public func title() -> String {
        return titleMap[self] ?? ""
    }
    
    public func desc() -> String {
        return descriptionMap[self] ?? ""
    }
    
    public func trackName() -> String {
        switch self {
        case .GDPR: return "gdpr"
        case .pgView: return "vista_posicion_global"
        case .pgCustomization: return "personalizar_posicion_global"
        case .pgDirectAccess: return "configurar_accesos_directos"
        case .email: return "email"
        case .phoneNumber: return "telefono_movil"
        case .mobilePayment: return "pago_movil"
        case .touchID: return "touch_id"
        case .faceID: return "face_id"
        case .geolocalization: return "geolocalizacion"
        case .safeDevice: return "dispositivo_seguro"
        case .operativity: return "operatividad"
        case .notificationPermissions: return "permiso_notificaciones"
        case .alias: return "alias"
        case .profilePicture: return "foto_perfil"
        case .address: return "direccion"
        case .languageSelection: return "seleccion_idioma"
        }
    }
    
    public func accessibilityIdentifier(state: String) -> String {
        switch self {
        case .GDPR: return "\(state)_digitalProfile_label_gdpr"
        case .pgView: return "\(state)_digitalProfile_label_chooseSubject"
        case .pgCustomization: return "\(state)_digitalProfile_label_displayOptions"
        case .pgDirectAccess: return "\(state)_digitalProfile_label_shortcuts"
        case .email: return "\(state)_digitalProfile_label_email"
        case .phoneNumber: return "\(state)_digitalProfile_label_phone"
        case .mobilePayment: return "\(state)_digitalProfile_label_mobilePay"
        case .touchID: return "\(state)_personalArea_label_touchId"
        case .faceID: return "\(state)_personalArea_label_faceId"
        case .geolocalization: return "\(state)_personalArea_label_geolocation"
        case .safeDevice: return "\(state)_personalArea_label_secureDevice"
        case .operativity: return "\(state)_digitalProfile_label_operability"
        case .notificationPermissions: return "\(state)_personalArea_label_notificationPermission"
        case .alias: return "\(state)_digitalProfile_label_alias"
        case .profilePicture: return "\(state)_digitalProfile_label_photo"
        case .address: return "\(state)_digitalProfile_label_address"
        case .languageSelection: return "\(state)_personalArea_label_language"
        }
    }

    private var valueMap: [DigitalProfileElem: Int] {
        return [
            DigitalProfileElem.languageSelection: 3,
            DigitalProfileElem.pgView: 3,
            DigitalProfileElem.pgCustomization: 3,
            DigitalProfileElem.pgDirectAccess: 3,
            DigitalProfileElem.address: 6,
            DigitalProfileElem.email: 10,
            DigitalProfileElem.phoneNumber: 10,
            DigitalProfileElem.mobilePayment: 10,
            DigitalProfileElem.touchID: 5,
            DigitalProfileElem.faceID: 5,
            DigitalProfileElem.GDPR: 6,
            DigitalProfileElem.geolocalization: 10,
            DigitalProfileElem.safeDevice: 16,
            DigitalProfileElem.operativity: 5,
            DigitalProfileElem.notificationPermissions: 10,
            DigitalProfileElem.alias: 3,
            DigitalProfileElem.profilePicture: 3
        ]
    }
    
    private var titleMap: [DigitalProfileElem: String] {
        return [
            DigitalProfileElem.languageSelection: "digitalProfile_label_language",
            DigitalProfileElem.pgView: "digitalProfile_label_chooseSubject",
            DigitalProfileElem.pgCustomization: "digitalProfile_label_displayOptions",
            DigitalProfileElem.pgDirectAccess: "digitalProfile_label_directAccess",
            DigitalProfileElem.address: "digitalProfile_label_address",
            DigitalProfileElem.email: "digitalProfile_label_email",
            DigitalProfileElem.phoneNumber: "digitalProfile_label_phone",
            DigitalProfileElem.mobilePayment: "digitalProfile_label_mobilePay",
            DigitalProfileElem.touchID: "digitalProfile_label_touchId",
            DigitalProfileElem.faceID: "digitalProfile_label_faceId",
            DigitalProfileElem.GDPR: "digitalProfile_label_consentManagement",
            DigitalProfileElem.geolocalization: "digitalProfile_label_geolocation",
            DigitalProfileElem.safeDevice: "digitalProfile_label_secureDevice",
            DigitalProfileElem.operativity: "digitalProfile_label_operability",
            DigitalProfileElem.notificationPermissions: "digitalProfile_label_notificationPermission",
            DigitalProfileElem.alias: "digitalProfile_label_alias",
            DigitalProfileElem.profilePicture: "digitalProfile_label_photo"
        ]
    }

    private var descriptionMap: [DigitalProfileElem: String] {
        return [
            DigitalProfileElem.languageSelection: "",
            DigitalProfileElem.pgView: "",
            DigitalProfileElem.pgCustomization: "",
            DigitalProfileElem.pgDirectAccess: "",
            DigitalProfileElem.address: "",
            DigitalProfileElem.email: "digitalProfile_carousel_email",
            DigitalProfileElem.phoneNumber: "digitalProfile_carousel_phone",
            DigitalProfileElem.mobilePayment: "digitalProfile_carousel_mobilePay",
            DigitalProfileElem.touchID: "digitalProfile_carousel_touchId",
            DigitalProfileElem.faceID: "digitalProfile_carousel_faceId",
            DigitalProfileElem.GDPR: "digitalProfile_carousel_consentManagement",
            DigitalProfileElem.geolocalization: "digitalProfile_carousel_geolocation",
            DigitalProfileElem.safeDevice: "digitalProfile_carousel_secureDevice",
            DigitalProfileElem.operativity: "digitalProfile_carousel_operability",
            DigitalProfileElem.notificationPermissions: "digitalProfile_carousel_notificationPermission",
            DigitalProfileElem.alias: "digitalProfile_carousel_alias",
            DigitalProfileElem.profilePicture: "digitalProfile_carousel_photo"
        ]
    }
}
