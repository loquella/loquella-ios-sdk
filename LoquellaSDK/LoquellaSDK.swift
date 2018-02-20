//
//  LoquellaSDK.swift
//  LoquellaSDK
//
//  Created by Rasmus Styrk on 19/02/2018.
//  Copyright © 2018 House of Code ApS. All rights reserved.
//

import Foundation


public class LoquellaSDK {
    
    public static let sharedInstance: LoquellaSDK = LoquellaSDK()
    
    private var apiKey: String?
    
    private var currentLocale: String = "en-en"
    private var currentRevision: Int = 0
    private var currentTranslations: Dictionary<String, Any> = [:]
    
    public func setApiKey(_ key: String) {
        print("[LoquellaSDK/setApiKey]: New api set: \(key)")
        
        self.apiKey = key
        
        self.updateCurrentLocale()
        self.loadPreloadedTranslations()
        self.fetchLatestTranslations()
    }

    private func updateCurrentLocale() {
        self.currentLocale = Locale.current.identifier.replacingOccurrences(of: "_", with: "-").lowercased()
        print("[LoquellaSDK/updateCurrentLocale]: Setting current locale based on device settings to: \(self.currentLocale)")
    }
    
    private func loadPreloadedTranslations() {
        print("[LoquellaSDK/loadPreloadedTranslations]: Loading translations from disc (looking for loquella.json)")
        
        guard let path = Bundle.main.path(forResource: "loquella", ofType: "json") else {
            print("[LoquellaSDK/loadPreloadedTranslations]: Unable toload loquella.json")
            return
        }
        
        print("[LoquellaSDK/loadPreloadedTranslations]: Found loquella.json at path \(path)")
        
        let url = URL(fileURLWithPath: path)
        
        guard let jsonData = try? Data(contentsOf: url),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments),
            let jsonDict = jsonObject as? Dictionary<String, Any>,
            let revString = jsonDict["number"] as? String,
            let rev = Int(revString),
            let translations = jsonDict["translations"] as? Dictionary<String, Any> else {
            print("[LoquellaSDK/loadPreloadedTranslations]: Unable to load loquella.json (bad format?)")
            return
        }
        
        if rev > self.currentRevision {
            print("[LoquellaSDK/loadPreloadedTranslations]: Loaded loquella.json with revision: \(rev)")
            self.currentTranslations = translations
        } else {
            print("[LoquellaSDK/loadPreloadedTranslations]: Revision found in loquella.json is \(rev) but the the current revision is \(self.currentRevision) - skipping loquella.json")
        }
    }
    
    private func fetchLatestTranslations() {
        print("[LoquellaSDK/fetchLatestTranslations]: Checking API for new translations")
        // Fetch new loquella.json from api
    }
    
    private func markMissingTranslation(key: String, comment: String?) {
        // Send missing key to webservice
    }
    
    public func translate(key: String, comment: String?) -> String {

        if let source = self.currentTranslations[key] as? Dictionary<String, Any> {
            if let target = source[self.currentLocale] as? String {
                return target
            }
        }
        
        self.markMissingTranslation(key: key, comment: comment)
        
        return key
    }
    
}
