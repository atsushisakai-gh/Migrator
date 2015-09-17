//
//  ManagerTests.swift
//  Migrator
//
//  Created by 酒井篤 on 2015/09/13.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import Migrator

// Mocking
class ManagerMock : Manager  {
    override func currentVersion() -> String {
        return "1.0.0"
    }
}

class ManagerTests: XCTestCase, MigratorProtocol {
    
    let manager: Manager = Manager()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        manager.reset()
    }

    func testLastMigratedVersionIsEmpty() {
        let lastVer = manager.lastMigratedVersion()
        XCTAssertTrue(lastVer == "")
    }
    
    func testLastMigratedVersionIsSaved() {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("1.0.0", forKey: "com.radioboo.migratorLastVersionKey")
        defaults.synchronize()
        
        XCTAssertTrue(manager.lastMigratedVersion() == "1.0.0")
    }
    
    func testInitialVersionIsSaved() {
        manager.setInitialVersion("2.0.0")
        XCTAssertTrue(manager.lastMigratedVersion() == "2.0.0")

        manager.setInitialVersion("4.0.0")
        XCTAssertTrue(manager.lastMigratedVersion() == "2.0.0")
    }
    
    func testShouldMigrateIsFalseBecauseEqual() {
        let managerMock: ManagerMock = ManagerMock()
        managerMock.setInitialVersion("0.0.9")
        XCTAssertFalse(managerMock.shouldMigrate() == true)
    }

    func testShouldMigrateIsFalseBecauseLess() {
        let managerMock: ManagerMock = ManagerMock()
        managerMock.setInitialVersion("1.0.0")
        XCTAssertFalse(managerMock.shouldMigrate() == true)
    }
    func testShouldMigrate() {
        let managerMock: ManagerMock = ManagerMock()
        managerMock.setInitialVersion("1.0.1")
        XCTAssertTrue(managerMock.shouldMigrate() == true)
    }
    
    // MARK: Migrate Tests

    func testSuccessedMigrate() {
        let managerMock: ManagerMock = ManagerMock()

        managerMock.setInitialVersion("0.9.0")
        
        var migrated: Bool = false;
        
        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.0",
            handler: { () -> () in migrated = true }
        )
        managerMock.registerHandler(handler)
        managerMock.migrate()
        XCTAssertTrue(migrated == true)
        XCTAssertTrue(managerMock.lastMigratedVersion() == "1.0.0")
    }

    func testFailedMigrateReasonThatLastMigratedVersionEqualToTargerVerion() {
        let managerMock: ManagerMock = ManagerMock()

        managerMock.setInitialVersion("1.0.0")
        
        var migrated: Bool = false;
        
        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.0",
            handler: { () -> () in migrated = true }
        )
        managerMock.registerHandler(handler)
        managerMock.migrate()
        XCTAssertTrue(migrated == false)
        XCTAssertTrue(managerMock.lastMigratedVersion() == "1.0.0")
    }

    func testFailedMigratedReasonThatTargetVersionIsLessThanLastMigrated() {
        let managerMock: ManagerMock = ManagerMock()

        managerMock.setInitialVersion("0.9.0")
        
        var migrated: Bool = false;
        
        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "0.8.0",
            handler: { () -> () in migrated = true }
        )
        managerMock.registerHandler(handler)
        managerMock.migrate()
        XCTAssertTrue(migrated == false)
        XCTAssertTrue(managerMock.lastMigratedVersion() == "0.9.0")
    }

    func testFailedMigratedReasonThatTargetVersionIsGreaterThanCurrentVersion() {
        let managerMock: ManagerMock = ManagerMock()

        managerMock.setInitialVersion("1.0.0")

        var migrated: Bool = false;

        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.1",
            handler: { () -> () in migrated = true }
        )
        managerMock.registerHandler(handler)
        managerMock.migrate()
        XCTAssertTrue(migrated == false)

        XCTAssertTrue(managerMock.lastMigratedVersion() == "1.0.0")
    }

    // MARK: Multiple Migrate

    func testMultipleMigration() {
        let managerMock: ManagerMock = ManagerMock()

        managerMock.setInitialVersion("0.8.0")

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

        managerMock.registerHandler(handler_0_8_1)
        managerMock.registerHandler(handler_0_9_0)
        managerMock.registerHandler(handler_1_0_0)
        managerMock.registerHandler(handler_1_0_1)

        managerMock.migrate()

        XCTAssertTrue(migrated_0_8_1 == true)
        XCTAssertTrue(migrated_0_9_0 == true)
        XCTAssertTrue(migrated_1_0_0 == true)
        XCTAssertFalse(migrated_1_0_1 == true)

        XCTAssertTrue(managerMock.lastMigratedVersion() == "1.0.0")
    }

    // MARK: Delegate

    func testSuccessedMigrateDelegate() {
        let managerMock: ManagerMock = ManagerMock()

        managerMock.setInitialVersion("0.9.0")

        var migrated: Bool = false;

        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "1.0.0",
            handler: { () -> () in migrated = true }
        )
        managerMock.registerHandler(handler)
        managerMock.delegate = self
        managerMock.migrate()
        XCTAssertTrue(migrated == true)
        XCTAssertTrue(managerMock.lastMigratedVersion() == "1.0.0")
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
