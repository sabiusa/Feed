//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Saba Khutsishvili on 3/3/21.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "Any Error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
