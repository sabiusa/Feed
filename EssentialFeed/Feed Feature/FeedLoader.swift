//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 2/17/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
