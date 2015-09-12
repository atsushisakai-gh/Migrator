//
//  Manager.swift
//  Pods
//
//  Created by 酒井篤 on 2015/09/13.
//
//

import UIKit

public class Manager: NSObject {
    
    let kMigratorLastVersionKey = "com.radioboo.migratorLastVersionKey";
    
    public func currentVersion() -> String {
        let currentVersion:String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
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

}
