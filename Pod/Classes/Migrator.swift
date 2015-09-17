//
//  Migrator.swift
//  Pods
//
//  Created by 酒井篤 on 2015/09/13.
//
//

import UIKit
import EDSemver

@objc public protocol MigratorProtocol : class {

    optional func didSucceededMigration(migratedVersion: String) -> ()

    optional func didFailedMigration(migratedVersion: String) -> ()

    optional func didCompletedAllMigration() -> ()

}

public class Migrator: NSObject {

    var migrationHandlers: [MigrationHandler] = []

    public var delegate: MigratorProtocol?

    let kMigratorLastVersionKey = "com.radioboo.migratorLastVersionKey";

    public func migrate() {
        if self.migrationHandlers.count == 0 {
            print("[Migrator ERROR] Completed Soon, Empty Handlers.");
            return;
        }
        for handler: MigrationHandler in self.migrationHandlers {
            migrate(handler)
        }
        self.delegate?.didCompletedAllMigration!()
    }

    public func registerHandler(targetVersion: String, migration: () throws -> Void) {
        let handler: MigrationHandler = MigrationHandler(targetVersion: targetVersion, handler: migration)
        registerHandler(handler)
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

    private func registerHandler(handler: MigrationHandler) {
        migrationHandlers.append(handler)
    }

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

        if targetVersion.isLessThan(lastMigratedVersion)
            || targetVersion.isEqualTo(lastMigratedVersion) {
            return
        }
        
        if targetVersion.isGreaterThan(currentVersion) {
            return
        }

        do {
            try handler.migrate()
        } catch {
            self.delegate?.didFailedMigration!(handler.targetVersion)
        }

        setLastMigratedVersion(handler.targetVersion)

        self.delegate?.didSucceededMigration!(handler.targetVersion)
    }

}
