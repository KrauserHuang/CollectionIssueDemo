//
//  Logger.swift
//  CollectionIssueDemo
//
//  Created by IT-MAC-02 on 2025/3/14.
//

import Foundation

class Logger {
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
    
    static let shared = Logger()
    private let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        #if os(iOS) || os(tvOS) || os(watchOS)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
#else
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
#endif
    }
    
    private func log(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        let timeStamp = dateFormatter.string(from: Date())
        let fileName = URL(fileURLWithFileSystemRepresentation: file, isDirectory: true, relativeTo: nil)
            .lastPathComponent
        print("[\(timeStamp)][\(level.rawValue)][\(fileName):\(function):\(line)] \(message)")
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}
