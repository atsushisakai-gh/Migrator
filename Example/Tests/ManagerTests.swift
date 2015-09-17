//
//  MigratorTests.swift
//  Migrator
//
//  Created by 酒井篤 on 2015/09/13.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import Migrator

// Mocking
class MigratorMock : Migrator  {
    override func currentVersion() -> String {
        return "1.0.0"
    }
}

class MigratorTests: XCTestCase, MigratorProtocol {
    
    let migrator: Migrator = Migrator()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        migrator.reset()
    }

    func testLastMigratedVersionIsEmpty() {
        let lastVer = migrator.lastMigratedVersion()
        XCTAssertTrue(lastVer == "")
    }
    
    func testLastMigratedVersionIsSaved() {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("1.0.0", forKey: "com.radioboo.migratorLastVersionKey")
        defaults.synchronize()
        
        XCTAssertTrue(migrator.lastMigratedVersion() == "1.0.0")
    }
    
    func testInitialVersionIsSaved() {
        migrator.setInitialVersion("2.0.0")
        XCTAssertTrue(migrator.lastMigratedVersion() == "2.0.0")

        migrator.setInitialVersion("4.0.0")
        XCTAssertTrue(migrator.lastMigratedVersion() == "2.0.0")
    }
    
    func testShouldMigrateIsFalseBecauseEqual() {
        let migratorMock: MigratorMock = MigratorMock()
        migratorMock.setInitialVersion("0.0.9")
        XCTAssertFalse(migratorMock.shouldMigrate() == true)
    }

    func testShouldMigrateIsFalseBecauseLess() {
        let migratorMock: MigratorMock = MigratorMock()
        migratorMock.setInitialVersion("1.0.0")
        XCTAssertFalse(migratorMock.shouldMigrate() == true)
    }
    func testShouldMigrate() {
        let migratorMock: MigratorMock = MigratorMock()
        migratorMock.setInitialVersion("1.0.1")
        XCTAssertTrue(migratorMock.shouldMigrate() == true)
    }
    
    // MARK: Migrate Tests

    func testSuccessedMigrate() {
        let migratorMock: MigratorMock = MigratorMock()

        migratorMock.setInitialVersion("0.9.0")
        
        var migrated: Bool = false;
        
        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.0",
            handler: { () -> () in migrated = true }
        )
        migratorMock.registerHandler(handler)
        migratorMock.migrate()
        XCTAssertTrue(migrated == true)
        XCTAssertTrue(migratorMock.lastMigratedVersion() == "1.0.0")
    }

    func testFailedMigrateReasonThatLastMigratedVersionEqualToTargerVerion() {
        let migratorMock: MigratorMock = MigratorMock()

        migratorMock.setInitialVersion("1.0.0")
        
        var migrated: Bool = false;
        
        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.0",
            handler: { () -> () in migrated = true }
        )
        migratorMock.registerHandler(handler)
        migratorMock.migrate()
        XCTAssertTrue(migrated == false)
        XCTAssertTrue(migratorMock.lastMigratedVersion() == "1.0.0")
    }

    func testFailedMigratedReasonThatTargetVersionIsLessThanLastMigrated() {
        let migratorMock: MigratorMock = MigratorMock()

        migratorMock.setInitialVersion("0.9.0")
        
        var migrated: Bool = false;
        
        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "0.8.0",
            handler: { () -> () in migrated = true }
        )
        migratorMock.registerHandler(handler)
        migratorMock.migrate()
        XCTAssertTrue(migrated == false)
        XCTAssertTrue(migratorMock.lastMigratedVersion() == "0.9.0")
    }

    func testFailedMigratedReasonThatTargetVersionIsGreaterThanCurrentVersion() {
        let migratorMock: MigratorMock = MigratorMock()

        migratorMock.setInitialVersion("1.0.0")

        var migrated: Bool = false;

        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.1",
            handler: { () -> () in migrated = true }
        )
        migratorMock.registerHandler(handler)
        migratorMock.migrate()
        XCTAssertTrue(migrated == false)

        XCTAssertTrue(migratorMock.lastMigratedVersion() == "1.0.0")
    }

    // MARK: Multiple Migrate

    func testMultipleMigration() {
        let migratorMock: MigratorMock = MigratorMock()

        migratorMock.setInitialVersion("0.8.0")

        var migrated_0_8_1: Bool = false;
        var migrated_0_9_0: Bool = false;
        var migrated_1_0_0: Bool = false;
        var migrated_1_0_1: Bool = false;

        let handler_0_8_1: MigrationHandler =  MigrationHandler(
            targetVersion: "0.8.1",
            handler: { () -> () in migrated_0_8_1 = true }
        )

        let handler_0_9_0: MigrationHandler =  MigrationHandler(
            targetVersion: "0.9.0",
            handler: { () -> () in migrated_0_9_0 = true }
        )

        let handler_1_0_0: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.0",
            handler: { () -> () in migrated_1_0_0 = true }
        )

        let handler_1_0_1: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.1",
            handler: { () -> () in migrated_1_0_1 = true }
        )

        migratorMock.registerHandler(handler_0_8_1)
        migratorMock.registerHandler(handler_0_9_0)
        migratorMock.registerHandler(handler_1_0_0)
        migratorMock.registerHandler(handler_1_0_1)

        migratorMock.migrate()

        XCTAssertTrue(migrated_0_8_1 == true)
        XCTAssertTrue(migrated_0_9_0 == true)
        XCTAssertTrue(migrated_1_0_0 == true)
        XCTAssertFalse(migrated_1_0_1 == true)

        XCTAssertTrue(migratorMock.lastMigratedVersion() == "1.0.0")
    }

    // MARK: Delegate

    func testSuccessedMigrateDelegate() {
        let migratorMock: MigratorMock = MigratorMock()

        migratorMock.setInitialVersion("0.9.0")

        var migrated: Bool = false;

        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.0",
            handler: { () -> () in migrated = true }
        )
        migratorMock.registerHandler(handler)
        migratorMock.delegate = self
        migratorMock.migrate()
        XCTAssertTrue(migrated == true)
        XCTAssertTrue(migratorMock.lastMigratedVersion() == "1.0.0")
    }

    func didSucceededMigration(migratedVersion: String) {
        XCTAssertTrue(migratedVersion == "1.0.0")
    }

    func didFailedMigration(migratedVersion: String) {
        XCTAssertTrue(migratedVersion == "1.0.0")
    }

    func didCompletedAllMigration() {
    }
}
