//
//  LogMacroTests.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/02.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(AppLoggerMacros)
import AppLoggerMacros

final class LogMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "log": LogMacro.self,
    ]

    func testLogErrorExpansion() throws {
        assertMacroExpansion(
            """
            #log(.error, "Something failed")
            """,
            expandedSource: """
            Logger(
                subsystem: Bundle.main.bundleIdentifier ?? "",
                category: "test"
            ).error("Something failed")
            """,
            macros: testMacros
        )
    }

    func testLogDebugExpansion() throws {
        assertMacroExpansion(
            """
            #log(.debug, "Debug message")
            """,
            expandedSource: """
            Logger(
                subsystem: Bundle.main.bundleIdentifier ?? "",
                category: "test"
            ).debug("Debug message")
            """,
            macros: testMacros
        )
    }
}
#endif
