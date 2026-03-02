//
//  LogMacro.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/02.
//

@_exported import os

@freestanding(expression)
public macro log(_ level: LogLevel, _ message: String) = #externalMacro(
    module: "AppLoggerMacros",
    type: "LogMacro"
)
