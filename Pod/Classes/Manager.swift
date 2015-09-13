//
//  Manager.swift
//  Pods
//
//  Created by 酒井篤 on 2015/09/13.
//
//

import UIKit
import Version

public class Manager: NSObject {
    
    let kMigratorLastVersionKey = "com.radioboo.migratorLastVersionKey";
    
    override public init() {
        super.init()
    }
    
    public func currentVersion() -> String {
        let currentVersion:String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        return currentVersion;
    }
    
    public func lastMigratedVersion() -> String {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(kMigratorLastVersionKey) ?? ""
    }
    
    public func reset() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(kMigratorLastVersionKey)
        defaults.synchronize()
    }
    
    public func setInitialVersion(version: String) {
        self.setInitialVersionIfEmpty(version)
    }
    
    // MARK: - Private Methods
    private func setLastMigratedVersion(version: String) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(version, forKey:kMigratorLastVersionKey)
        defaults.synchronize()
    }
    
    private func setInitialVersionIfEmpty(version: String) {
        if self.lastMigratedVersion().isEmpty {
           setLastMigratedVersion(version)
        }
    }
    
}
