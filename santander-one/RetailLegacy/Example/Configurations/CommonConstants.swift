struct CommonConstants {
    // MARK: App Groups
    let appGroupsIdentifier: String
    
    // MARK: Sharing Keychain
    let sharedKeychainIdentifier: String
}

extension CommonConstants {
    static var development: CommonConstants {
        return CommonConstants(appGroupsIdentifier: "group.es.bancosantander.mobility.ios.retail", sharedKeychainIdentifier: "JFX6PVNK48.es.santander.sso")
    }
    
    static var production: CommonConstants {
        return CommonConstants(appGroupsIdentifier: "group.es.santander.sso", sharedKeychainIdentifier: "6YVLU6LV9S.es.santander.sso")
    }
}
