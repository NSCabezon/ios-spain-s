import Foundation

/// Class to extract XML nodes as Dictionaries, just for test purposes
class TestXML: NSObject, XMLParserDelegate {
    
    var results: [[String: String]]!
    private var currentDictionary: [String: String]!
    private var currentValue: String?
    private var recordKey: String
    private var childKeys: [String]
    
    init(recordKey: String, childKeys: [String]) {
        self.recordKey = recordKey
        self.childKeys = childKeys
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        results = []
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == recordKey {
            currentDictionary = [String : String]()
        } else if childKeys.contains(elementName) {
            currentValue = String()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == self.recordKey {
            results.append(currentDictionary)
            currentDictionary = nil
            
        } else if childKeys.contains(elementName) {
            currentDictionary[elementName] = currentValue
            currentValue = nil
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        currentValue = nil
        currentDictionary = nil
        results = nil
    }
    
}
