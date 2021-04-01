//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Saba Khutsishvili on 4/1/21.
//

import Foundation
import XCTest
import EssentialFeediOS

extension FeedUIIntegrationTests {
    
    func localized(
        _ key: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localization string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
}
