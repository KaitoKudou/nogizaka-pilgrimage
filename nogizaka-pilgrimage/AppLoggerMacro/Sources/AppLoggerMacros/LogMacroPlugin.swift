//
//  LogMacroPlugin.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/02.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct AppLoggerMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [LogMacro.self]
}

public struct LogMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let levelExpr = node.arguments.first?.expression,
              let messageExpr = node.arguments.dropFirst().first?.expression else {
            fatalError("#log requires two arguments: level and message")
        }

        // ファイル名からカテゴリを自動決定
        var category = "App"
        if let location = context.location(of: node),
           let fileExpr = location.file.as(StringLiteralExprSyntax.self),
           let segment = fileExpr.segments.first?.as(StringSegmentSyntax.self) {
            let filePath = segment.content.text
            let fileName = filePath.split(separator: "/").last.map(String.init) ?? filePath
            if fileName.hasSuffix(".swift") {
                category = String(fileName.dropLast(6))
            } else {
                category = fileName
            }
        }

        // LogLevel → Logger メソッド名
        let levelName: String
        if let memberAccess = levelExpr.as(MemberAccessExprSyntax.self) {
            levelName = memberAccess.declName.baseName.text
        } else {
            levelName = "info"
        }

        return """
        {
            #if DEBUG
            Logger(
                subsystem: Bundle.main.bundleIdentifier ?? "",
                category: "\(raw: category)"
            ).\(raw: levelName)(\(messageExpr))
            #endif
        }()
        """
    }
}
