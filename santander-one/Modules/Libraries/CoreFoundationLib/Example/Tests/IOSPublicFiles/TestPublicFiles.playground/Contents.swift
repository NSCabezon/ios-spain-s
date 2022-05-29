//: Playground - noun: a place where people can play

import UIKit
import CoreFoundationLib



public struct AppConfigDTO {
    
    fileprivate var defaultConfig: [String:String]?
    fileprivate var versions: [String:[String:String]]?
    
    
    public var getDefaultConfig: [String:String]? {
        return defaultConfig
    }
    
    public var getVersions: [String:[String:String]]? {
        return versions
    }
    
    public var getStringRepresentation: String {
        return "\(defaultConfig?.description ?? "")\(versions?.description ?? "")}"
    }
}

public struct AppConfigRepository: Repository {
    
    private let path = "app_config.json"
    private let relativeURL = "/apps/newArq/android/app_config.json"
    private let appConfigName = "savedAppConfig"
    
    let assetsClient: AssetsClient
    let netClient: NetClient
    let fileClient: FileClient
    let parser : AppConfigParser
    var appConfigDTO: AppConfigDTO?
    
    
    init(netClient: NetClient, assetsClient: AssetsClient, parser: AppConfigParser, fileClient: FileClient) {
        self.netClient = netClient
        self.assetsClient = assetsClient
        self.fileClient = fileClient
        self.parser = parser
    }
    
    public mutating func get() -> AppConfigDTO? {
        
        if appConfigDTO != nil {
            return appConfigDTO
        }
        
        if let savedAppConfig = fileClient.get(appConfigName) {
            appConfigDTO = parser.serialize(savedAppConfig)
        }
        if appConfigDTO == nil {
            print("load from assets")
            loadFromAssets()
        }
        
        return appConfigDTO
    }
    
    public mutating func load(withBaseUrl url: String) {
        //Load AppConfig
        loadFromAssets()
        
        //Online AppConfig
        if let data: String = netClient.loadURL("\(url)\(relativeURL)") {
            //print("DATA:\(data)")
            appConfigDTO = parser.serialize(data)
        }
        
        //Versions parser
        //parserVersion()
        //Persist AppConfig in disk
        if let appConfig = appConfigDTO, let deserializeAppConfig = parser.deserialize(appConfig) {
            do {
                print("✅ File saved succesfully \(deserializeAppConfig)")
                try fileClient.set(deserializeAppConfig, fileName: appConfigName)
            } catch {
                print("❌ Error saving file")
            }
        }
        
        
    }
    
    public func set(genericType: AppConfigDTO) {
        
    }
    
    public func remove() {
        
    }
    
    //Load Assets
    private mutating func loadFromAssets() {
        if let data = assetsClient.get(pathToFile: path, type: "json") {
            appConfigDTO = parser.serialize(data)
        }
    }
}

public class AppConfigParser : Parser {
    
    let configKey = "defaultConfig"
    let versionKey = "versions"
    
    public func deserialize(_ parseable: AppConfigDTO) -> String? {
        
        guard let defaultConfig = parseable.getDefaultConfig, let versions = parseable.getVersions else { print("❌ Fail to get AppConfigDTO")
            return nil }
        return "{\"\(configKey)\":\(defaultConfig.description.replacingOccurrences(of: "[", with: "{").replacingOccurrences(of: "]", with: "}")),\"\(versionKey)\":\(versions.description.replacingOccurrences(of: "[", with: "{").replacingOccurrences(of: "]", with: "}"))}"
        
    }
    
    public func serialize<T>(_ responseString: String) -> T? {
        
        guard let data = responseString.data(using: .utf8) else { return nil }
        
        do {
            
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            guard let config = json[configKey] as? [String : String] else {return nil}
            guard let versions = json[versionKey] as? [String: [String:String]] else { return nil }
            let configDTO = AppConfigDTO(defaultConfig: config, versions: versions)
            
            return configDTO as? T 
        } catch {
            print("❌ Fail to serialize JSON ➡️ \(String(describing: AppConfigParser.self))")
        }
        
        return nil
    }
}

var dto = AppConfigRepository(netClient: NetClient(), assetsClient: AssetsClient(), parser : AppConfigParser(), fileClient: FileClient())
dto.load(withBaseUrl: "http://serverftp.ciber-es.com:82/movilidad/files_dev")
FileManager.documentDirectoryURL

if let appConfig = dto.get() {
    
    print("version \n \(String(describing: appConfig.getVersions))\n\n")
    print("Default version \n \(String(describing: appConfig.getDefaultConfig))\n\n")
    print("String version \n \(appConfig.getStringRepresentation)")
}


