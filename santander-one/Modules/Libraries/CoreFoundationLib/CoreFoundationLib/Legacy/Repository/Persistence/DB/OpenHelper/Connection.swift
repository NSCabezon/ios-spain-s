import SQLite

public extension Connection {
    /// the database version
    var version: Int {
        get {
            do {
                let statement = try self.run("PRAGMA user_version;")
                for row in statement {
                    if let element = row[0] as? Int64 {
                        return Int(element)
                    } else {
                        return -1
                    }
                    
                }
            } catch {
                fatalError("Error during the get of the database version")
            }
            fatalError("PRAGMA user_version not available")
        }
        
        set {
            do {
                try self.execute("PRAGMA user_version = \(newValue);")
            } catch {
                fatalError("Error during the set of the database new version")
            }
        }
    }
}
