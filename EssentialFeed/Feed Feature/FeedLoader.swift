//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 2/17/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
