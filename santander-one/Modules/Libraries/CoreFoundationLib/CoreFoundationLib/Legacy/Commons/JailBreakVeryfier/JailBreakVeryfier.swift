//
//  JailBreakVeryfier.swift
//  JailBreak
//
//  Created by Jorge Ouahbi Martin on 13/8/21.
//
// This software follows the App Store review guidelines, and has been designed with two typical jailbreak cases in mind,
// one in which the user has voluntarily installed one of the public jailbreak distributions,
// such as the one published by the Unc0ver Team (https://twitter.com/unc0verTeam).
// The other case is more compromising. When for multiple reasons the sandbox has been subverted, among them: spying,
// impersonation or theft. This case usually goes unnoticed by the user, since the jailbreak installation is usually
// inadvertent by the user and leaves no visible trace on the system, for example systems like
// Pegasus (https://en.wikipedia.org/wiki/Pegasus_(spyware)).
//
// App Store Review Guidelines
//
// https://developer.apple.com/app-store/review/guidelines/
//
//
// URLSchemes
//
//
// http://www.macstories.net/linked/ios-9-bringing-changes-to-url-schemes/
//
// Starting on iOS 9, apps will have to declare what URL schemes they would like to be able to check for and open
// in the configuration files of the app as it is submitted to Apple.
// This is essentially a whitelist that can only be changed or added to by submitting an update to Apple.
// openURL / canOpenURL has changed in iOS9 due to user privacy.
// I suggest you read http://awkwardhare.com/post/121196006730/quick-take-on-ios-9-url-scheme-changes
//
// The user will now see this prompt the first time you ask for permission as per other permission requests.
// This is an OS change and apps, including core applications such as messages now ask for permission when opening a
// custom URL scheme for the first time.
//
// You also may be able to achieve what you are trying to do using Universal Links
//
// https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html#//apple_ref/doc/uid/TP40016308-CH12
//
// For query the url schemes of 3party apps with ´UIApplication.canOpenURL()' (>IOS9)
// add to you app plist the next array at the key ´LSApplicationQueriesSchemes'
//
// <key>LSApplicationQueriesSchemes</key>
// <array>
//    <string>undecimus</string>
//    <string>cydia</string>
//    <string>sileo</string>
//    <string>zbra</string>
//    <string>filza</string>
//    <string>activator</string>
//    <string>installer</string>
// </array>
//
// For testing the url schemes to open.
//
// <key>CFBundleURLTypes</key>
// <array>
//  <dict>
//    <key>CFBundleTypeRole</key>
//    <string>Viewer</string>
//    <key>CFBundleURLName</key>
//    <string>com.jailbreak.verifier</string>
//    <key>CFBundleURLSchemes</key>
//    <array>
//        <string>undecimus</string>
//        <string>cydia</string>
//        <string>sileo</string>
//        <string>zbra</string>
//        <string>filza</string>
//        <string>activator</string>
//        <string>installer</string>
//    </array>
//  </dict>
// </array>

import Darwin // fork
import Foundation
import MachO // dyld
import zlib // crc/adler

private extension UIApplication {
    ///
    /// Get the external applications schemes that the application is allowed to open it
    ///
    /// - Returns: [String]
    /// - Note:
    ///
    ///   guard Bundle().urlSchemesAllowedToOpen.contains(URLScheme) else {
    ///     return
    ///   }
    ///
    var urlSchemesAllowedToOpen: [String]? {
        guard let urlTypes = Bundle.main.infoDictionary?["LSApplicationQueriesSchemes"] as? [String] else {
            return Bundle(for: Self.self).infoDictionary?["LSApplicationQueriesSchemes"] as? [String]
        }
        return urlTypes
    }
}

///
/// POSIXRunnable
///
/// Protocol that implement the runners of shell
///

protocol POSIXRunnable {
    func runInShell(_ args: [String]) -> Int32
}

// MARK: - Protocol POSIXRunnable Implementation

extension POSIXRunnable {

    func runInShell(_ args: [String]) -> Int32 {
        var pid: pid_t = 0
        let argv = args.map {
            $0.withCString(strdup)
        }
        defer { argv.forEach { free($0) } }
        let envp = ProcessInfo.processInfo.environment.map {
            "\($0.0)=\($0.1)".withCString(strdup)
        }
        defer { envp.forEach { free($0) } }
        // return a 0 on success
        let result = posix_spawn(&pid, argv[0], nil, nil, argv+[nil], envp+[nil])
        debugPrint("posix_spawn result \(result)")
        if result != 0 { return -1 }

        var stat: Int32 = 0
        waitpid(pid, &stat, 0) // WAIT till child gets over
        debugPrint("waitpid stat \(stat)")
        return stat
    }
}

// MARK: - Protocol JailBreakVeryfier

///
/// JailBreakVeryfierProtocol
///

protocol JailBreakVeryfierProtocol {
    func isJailBreaked() -> Bool
    func isSandboxIntegritySubverted() -> Bool
    func isProtocolHandlerInstalled() -> Bool
    func isAccessToPrivateFileSystem() -> Bool
    func isDylibsInBlacklist() -> Bool
    func isProcessForkeable() -> Bool
    func verify() -> Bool
}

// MARK: - Protocol JailBreakVeryfier optional methods

///
/// JailBreakVeryfierProtocol extension optional method
///

extension JailBreakVeryfierProtocol {
    // Don't implements, dont respect the App Store Review Guidelines
    func isAccessToPrivateFileSystem() -> Bool {
        return false
    }
}

// MARK: - JailBreakVeryfier class

///
/// JailBreakVeryfier final class.
///

public final class JailBreakVeryfier: JailBreakVeryfierProtocol, POSIXRunnable {
    var cachedIsJailBreaked: Bool?
    // MARK: init
    public init() {
        var isJailBreakedResult: Bool = false
        #if targetEnvironment(simulator)
        debugPrint("Running on simulator. Assuming sandboxed...")
        cachedIsJailBreaked = false
        #else
        /// Save the computation to a cache variable.
        if let value = cachedIsJailBreaked {
            isJailBreakedResult = value
        } else {
            let value = verify()
            cachedIsJailBreaked = value
            isJailBreakedResult = value
        }
        #endif

        debugPrint("The device is \(isJailBreakedResult ? "Jailbreaked" : "Sandboxed")")
    }

    // MARK: VeryfierProtocol
    ///
    /// Verify that the protocol verification is correct
    ///
    /// - Returns: Bool
    ///
    func verify() -> Bool {
        // Swift compiler is a lazy compiler, if the first condition its true,
        // the seconds condition is not evaluated ...etc
        isProtocolHandlerInstalled() ||
            isSandboxIntegritySubverted() ||
            isDylibsInBlacklist() ||
            isProcessForkeable()
    }

    ///
    /// Check for devices running in jailbreak
    ///
    /// - Returns: Bool
    ///
    public func isJailBreaked() -> Bool {
        return cachedIsJailBreaked ?? false
    }

    // MARK: JailBreakVeryfierProtocol

    ///
    /// We dynamically load the `fork' function, making it accessible to Swift and try to create a new process.
    ///
    /// - Returns: Bool
    ///
    func isProcessForkeable() -> Bool {
        let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(rtldDefault, "fork")
        typealias ForkType = @convention(c) () -> pid_t
        let fork = unsafeBitCast(forkPtr, to: ForkType.self)
        let forkResult = fork()
        debugPrint("fork pid \(forkResult)")
        if forkResult >= 0 {
            if forkResult > 0 {
                kill(forkResult, SIGTERM)
            }
            #if targetEnvironment(simulator)
            return false
            #else
            debugPrint("Fork was able to create a new process (sandbox violation)")
            return true
            #endif
        }
        return false
    }

    ///
    /// Check Sandbox Integrity trying executing the ls shell command in a denied directory: /bin
    ///
    /// - Returns: Bool
    ///

    func isSandboxIntegritySubverted() -> Bool {
        // Try to run shell thru a system call posix_spawn
        let cmd = "ls /bin"
        let args = ["/bin/sh", "sh", "-c", cmd]
        let result = runInShell(args)
        debugPrint("runInShell result \(result)")
        // the command was executed sucessfuly
        #if targetEnvironment(simulator)
        return false
        #else
        return result == 0
        #endif
    }

    ///
    /// isDylibsInBlacklist
    ///
    /// - Returns: Bool
    ///

    func isDylibsInBlacklist() -> Bool {
        let imageCounter = _dyld_image_count()
        for libraryIndex in 0 ..< imageCounter {
            // _dyld_get_image_name returns const char * that needs to be casted to Swift String
            guard let loadedLibrary = String(validatingUTF8: _dyld_get_image_name(libraryIndex)) else { continue }
            debugPrint("Verifing \(libraryIndex) of \(imageCounter) - \(loadedLibrary).")
            if isLibraryBlacklisted(loadedLibrary) {
                debugPrint("Suspicious library loaded: \(loadedLibrary) found.")
                return true
            }
        }
        return false
    }

    // MARK: - Package Managers URL Schemes -

    var schemesURL: [String] {
        let schemes = ["u"+"n"+"d"+"e"+"c"+"i"+"m"+"u"+"s"+":"+"/"+"/",
                       "c"+"y"+"d"+"i"+"a"+":"+"/"+"/",
                       "s"+"i"+"l"+"e"+"o"+":"+"/"+"/",
                       "z"+"b"+"r"+"a"+":"+"/"+"/",
                       "f"+"i"+"l"+"z"+"a"+":"+"/"+"/",
                       "a"+"c"+"t"+"i"+"v"+"a"+"t"+"o"+"r"+":"+"/"+"/",
                       "i"+"n"+"s"+"t"+"a"+"l"+"l"+"e"+"r"+":"+"/"+"/"]

        return schemes
    }

    func allowedURLSchemeProtocolHandlerInstalled() -> [String] {
        if let schemesRegistered = UIApplication.shared.urlSchemesAllowedToOpen {
            let cleanSchemesURL: [String] = schemesURL.map { String($0.prefix(while: { $0 != ":" })) }
            if cleanSchemesURL.count > 0 {
                return Array(Set(cleanSchemesURL).intersection(schemesRegistered)).map { $0+"://" }
            }
        }
        return []
    }

    ///
    /// openURLSchemes
    ///
    /// - Parameters:
    ///   - urlSchemes: [String]
    ///   - forceOpen: Bool
    ///
    /// - Returns: Bool
    ///
    /// - Note
    ///
    ///    We can open an app by calling openURL: or openURL:options:completionHandler: (iOS 10 onwards)
    ///    directly without making the conditional check canOpenURL:.
    ///    Please read the discussion section in Apple doc for canOpenURL: method which says:
    ///
    ///    the openURL: method is not constrained by the LSApplicationQueriesSchemes requirement.
    ///
    ///    TODO:  kLSApplicationNotFoundErr
    ///

    func openURLSchemes(_ urlSchemes: [String], forceOpen: Bool = false) -> Bool {
        assert(!urlSchemes.isEmpty, "empty url schemes")
        for url in urlSchemes {
            if let rurl = URL(string: url) {
                if forceOpen == false || UIApplication.shared.canOpenURL(rurl) {
                    if UIApplication.shared.openURL(rurl) {
                        // Device is jailbroken with a public distribution
                        debugPrint("Open scheme url sucessfuly. (\(url)")
                        return true
                    }
                }
            }
        }
        return false
    }

    ///
    /// Are the protocol handlers of any package manager installed?
    ///
    /// - Returns: Bool
    ///

    func isProtocolHandlerInstalled() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let validSchemes = allowedURLSchemeProtocolHandlerInstalled()
        guard validSchemes.count > 0 else { return false }
        return self.openURLSchemes(validSchemes)
        #endif
    }

    /// isLibraryBlacklisted
    ///
    /// Check that the hash of the dynamic library is not in the blacklist
    ///
    /// - Parameter libraryPath: String
    /// - Returns: Bool

    func isLibraryBlacklisted(_ libraryPath: String) -> Bool {
        if libraryPath.count == 0 {
            debugPrint("Library path is empty.")
            return false
        }
        let libraryUrl = URL(string: libraryPath)
        guard let libraryName = libraryUrl?.lastPathComponent.lowercased() else { return false }
        let crc3 = crc32(uLong(0), libraryName, uInt(libraryName.count))
        for curCrc32 in blackList {
            guard curCrc32 != crc3 else { return true }
        }
        return false
    }

    ///
    /// Precalculated hash/crc for blacklisted dynamic libraries
    ///

    var blackList: [uLong] = {
        //        let array = [
        //            "substrateloader.dylib",
        //            "sslkillswitch2.dylib",
        //            "sslkillswitch.dylib",
        //            "mobilesubstrate.dylib",
        //            "tweakinject.dylib",
        //            "cydiasubstrate",
        //            "cynject",
        //            "customwidgeticons",
        //            "preferenceloader",
        //            "rocketbootstrap",
        //            "weeloader",
        //            "/.file", // hidejb (2.1.1) changes full paths of the suspicious libraries to "/.file"
        //            "libhooker",
        //            "substrateinserter",
        //            "substratebootstrap",
        //            "abypass",
        //            "flyjb",
        //            "substitute",
        //            "cephei",
        //            "electra",
        //            "fridagadget",
        //            "frida",       // needle injects frida-somerandom.dylib
        //            "libcycript"]
        //
        //        let hashes:[uLong] = array.map{
        //            var item = $0.bytes
        //            // TODO: adler32_z (OS11)
        //             return crc32(uLong(0), &item, uInt(item.count))
        //        }
        //        return hashes

        let array: [uLong] = [
            3181837564,
            117757581,
            1377084764,
            792884359,
            1172042545,
            1819660720,
            774016974,
            2467096328,
            130319697,
            540172501,
            1038034170,
            2484235817,
            4048593295,
            293528882,
            690804164,
            3999776760,
            3324964301,
            3488830393,
            1869568112,
            936466939,
            2942800116,
            1833177637,
            4242100022
        ]
        return array
    }()
}
