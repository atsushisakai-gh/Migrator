//
//  Manager.swift
//  Pods
//
//  Created by 酒井篤 on 2015/09/13.
//
//

import UIKit
import EDSemver

public class Manager: NSObject {
    
    let kMigratorLastVersionKey = "com.radioboo.migratorLastVersionKey";
    
    var migrationHandlers: [MigrationHandler] = []
    
    public func migrate() {
        if self.migrationHandlers.count == 0 {
            print("[Migrator ERROR] Completed Soon, Empty Handlers.");
            return;
        }
        for handler: MigrationHandler in self.migrationHandlers {
            migrate(handler)
        }
    }
    
    public func registerHandler(handler: MigrationHandler) {
        migrationHandlers.append(handler)
    }
    
    public func currentVersion() -> String {
        let currentVersion:String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        return currentVersion;
    }
    
    public func lastMigratedVersion() -> String {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(kMigratorLastVersionKey) ?? ""
    }
    
    public func shouldMigrate() -> Bool {
        let last: EDSemver = EDSemver(string: lastMigratedVersion())
        let current: EDSemver = EDSemver(string: currentVersion())
        if last.isGreaterThan(current) {
            return true
        }
        return false
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

    private func migrate(handler: MigrationHandler) {
        let targetVersion: EDSemver = EDSemver(string: handler.targetVersion)
        let lastMigratedVersion: EDSemver = EDSemver(string: self.lastMigratedVersion())
        let currentVersion: EDSemver = EDSemver(string: self.currentVersion())
        
        if lastMigratedVersion.isGreaterThan(targetVersion) {
            return
        }
        
        if targetVersion.isGreaterThan(currentVersion) {
            return
        }
        
        handler.migrate()
        
        // TODO: exec Delegate Method
        
        setLastMigratedVersion(handler.targetVersion)
    }

}
