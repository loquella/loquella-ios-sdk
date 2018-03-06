//
//  LoquellaSDK.swift
//  LoquellaSDK
//
//  Created by Rasmus Styrk on 19/02/2018.
//  Copyright © 2018 House of Code ApS. All rights reserved.
//

import Foundation


@objc public class LoquellaSDK : NSObject {
    
    public enum LogLevel {
        case none
        case verbose
        case all
    }
    
    public static let sharedInstance: LoquellaSDK = LoquellaSDK()
    
    private var apiKey: String?
    
    public var logLevel: LogLevel = .none
    
    private var currentLocale: String = "en-us"
    private var currentRevision: Int = 0
    private var currentTranslations: Dictionary<String, Any> = [:]
    
    let urlSession = URLSession(configuration: .default)
    var latestDataTask: URLSessionDataTask?
    
    public func setApiKey(_ key: String) {
        self.log("[LoquellaSDK/setApiKey]: New api key set: \(key)")
        
        self.apiKey = key
        
        if (self.hasRevisionInDocuments()) {
            self.restoreRevisionFromDocuments()
        } else {
            self.loadPreloadedTranslationsFromBundle()
        }
        
        self.fetchLatestTranslations()
        self.updateCurrentLocale()
    }

    private func updateCurrentLocale() {
        
        let userLocale = Locale.preferredLanguages[0].replacingOccurrences(of: "_", with: "-").lowercased()
        
        if (self.currentTranslations.count > 0) {
            self.log("[LoquellaSDK/updateCurrentLocale]: Finding available locales inside translations")

            if let first = self.currentTranslations.first {
                if let targets = first.value as? Dictionary<String, Any> {
                    
                    // Do we have a direct match?
                    if targets.index(forKey: userLocale) != nil {
                        self.log("[LoquellaSDK/updateCurrentLocale]: Found direct match")

                        self.currentLocale = userLocale
                    } else {
                        self.log("[LoquellaSDK/updateCurrentLocale]: Unable to find direct match, looking for most suitable locale")

                        // If not we try to find the most suitable
                        targets.forEach({ (key, value) in
                            if key.contains(userLocale) {
                                self.currentLocale = key
                            }
                        })
                    }
                }
            }
        } else {
            self.log("[LoquellaSDK/updateCurrentLocale]: Translations not loaded yet - setting locale to default")
            self.currentLocale = "en-us"
        }
 
        self.log("[LoquellaSDK/updateCurrentLocale]: Setting current locale based on device settings to: \(self.currentLocale)")
    }
    
    private func loadPreloadedTranslationsFromBundle() {
        self.log("[LoquellaSDK/loadPreloadedTranslations]: Loading translations from bundle (looking for loquella.json)")
        
        guard let path = Bundle.main.path(forResource: "loquella", ofType: "json") else {
            self.log("[LoquellaSDK/loadPreloadedTranslations]: Unable to load loquella.json from bundle")
            return
        }
        
        self.log("[LoquellaSDK/loadPreloadedTranslations]: Found loquella.json at path \(path) in bundle")
        
        let url = URL(fileURLWithPath: path)
        
        guard let jsonData = try? Data(contentsOf: url) else {
            self.log("[LoquellaSDK/loadPreloadedTranslations]: Unable to load loquella.json from bundle")
            return
        }
        
        self.log("[LoquellaSDK/loadPreloadedTranslations]: Got new data - trying to extract revision")
        self.extractRevisionFromData(data: jsonData)
        self.saveCurrentRevisionToDocuments()
    }
    
    
    private func fetchLatestTranslations() {
        self.log("[LoquellaSDK/fetchLatestTranslations]: Checking API for new translations")
        
        self.latestDataTask?.cancel()
        
        guard
            let key = self.apiKey,
            let url = URL(string: "http://api.loquella.io/v1/projects/\(key)/revisions/latest?ref=\(self.currentRevision)") else {
                return
        }
        
        self.latestDataTask = self.urlSession.dataTask(with: url, completionHandler: { (data, response, error) in
            defer { self.latestDataTask = nil }
            
            if let error = error {
                self.log("[LoquellaSDK/fetchLatestTranslations]: Failed to get latest translations: \(error.localizedDescription)")
            } else {
                if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self.log("[LoquellaSDK/fetchLatestTranslations]: Got new data - trying to extract revision");
                    
                    DispatchQueue.main.async {
                        self.extractRevisionFromData(data: data)
                        self.saveCurrentRevisionToDocuments()
                        self.updateCurrentLocale()
                    }
                } else {
                    self.log("[LoquellaSDK/fetchLatestTranslations]: Downloaded data but unable to parse it")
                }
            }
        })
     
        self.latestDataTask?.resume()
    }
    
    private func markMissingTranslation(key: String, comment: String?) {
        self.log("[LoquellaSDK/markMissingTranslation]: Marking translation: \(key)", logLevel: .all)

        guard
            let apiKey = self.apiKey,
            let url = URL(string: "http://api.loquella.io/v1/translations/\(apiKey)/mark_missing"),
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else {
                return
        }
        
        var urlRequest = URLRequest(url: url)
    
        let postParams = "source=\(escapedKey)"
        let postData = postParams.data(using: .utf8)
        
        // Set the httpMethod and assign httpBody
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        let task =  self.urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let error = error {
                self.log("[LoquellaSDK/markMissingTranslation]: Failed to mark missing translation: \(error.localizedDescription)", logLevel: .all)
            } else {
                if let _ = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self.log("[LoquellaSDK/fetchLatestTranslations]: Mark missing translation succeeded", logLevel: .all);

                } else {
                    self.log("[LoquellaSDK/fetchLatestTranslations]: Failed to mark missing translation", logLevel: .all)
                }
            }
        })
        
        task.resume()
    }
    
    private func saveCurrentRevisionToDocuments() {
        self.log("[LoquellaSDK/saveCurrentRevisionToDocuments]: Saving revision \(self.currentRevision) to documents")
        
        let path = self.documentsPath()
        
        let jsonObject = ["number": "\(self.currentRevision)", "translations": self.currentTranslations] as [String : Any]

        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
            let jsonString = String(bytes: jsonData, encoding: .utf8) else {
            self.log("[LoquellaSDK/saveCurrentRevisionToDocuments]: Unable to convert revision \(self.currentRevision) to json")
            return
        }
        
        do {
            try jsonString.write(to: path, atomically: true, encoding: .utf8)
            self.log("[LoquellaSDK/saveCurrentRevisionToDocuments]: Saved revision \(self.currentRevision) to documents folder (\(path.absoluteString))")
        } catch {
            self.log("[LoquellaSDK/saveCurrentRevisionToDocuments]: Failed to save revision \(self.currentRevision) to documents folder (\(path.absoluteString))")
        }
    }
    
    private func restoreRevisionFromDocuments() {
        let path = self.documentsPath()

        guard let jsonData = try? Data(contentsOf: path) else {
            self.log("[LoquellaSDK/restoreRevisionFromDocuments]: Unable to load loquella.json from documents")
            return
        }
        
        self.log("[LoquellaSDK/restoreRevisionFromDocuments]: Got new data - trying to extract revision")
        self.extractRevisionFromData(data: jsonData)
    }
    
    private func documentsPath() -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("No document directory found in application bundle.")
        }
        
        return documentsDirectory.appendingPathComponent("loquella.json")
    }
    
    private func hasRevisionInDocuments() -> Bool {
        return (try? documentsPath().checkResourceIsReachable()) != nil
    }
    
    private func extractRevisionFromData(data: Data) {
        self.log("[LoquellaSDK/extractRevisionFromData]: Looking for new revision in data: \(data)")

        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let jsonDict = jsonObject as? Dictionary<String, Any>,
            let revString = jsonDict["number"] as? String,
            let rev = Int(revString),
            let translations = jsonDict["translations"] as? Dictionary<String, Any> else {
                self.log("[LoquellaSDK/extractRevisionFromData]: Unable to load data (bad format?)")
                return
        }
        
        if rev > self.currentRevision {
            self.log("[LoquellaSDK/extractRevisionFromData]: Loaded data with revision: \(rev)")
            self.currentRevision = rev
            self.currentTranslations = translations
        } else {
            self.log("[LoquellaSDK/extractRevisionFromData]: Revision found in data is \(rev) but the the current revision is \(self.currentRevision) - skipping data")
        }
    }
    
    public func translate(key: String, comment: String?) -> String {
    
        self.log("[LoquellaSDK/translate]: Translating key: \(key)", logLevel: .all)

        if let source = self.currentTranslations[key] as? Dictionary<String, Any> {
            if let target = source[self.currentLocale] as? String {
                self.log("[LoquellaSDK/translate]: -> Found target: \(target)", logLevel: .all)
                return target
            }
        }
        
        #if DEBUG
        self.markMissingTranslation(key: key, comment: comment)
        #endif
        
        return key
    }
    
    private func log(_ msg: String, logLevel: LogLevel = .verbose) {
        if self.logLevel == .none {
            return
        }
        
        if self.logLevel == .all || self.logLevel == logLevel {
            print(msg)
        }
    }
    
}
