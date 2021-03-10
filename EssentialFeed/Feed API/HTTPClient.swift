//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 2/23/21.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    /// The completion handler can be invoked on any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
