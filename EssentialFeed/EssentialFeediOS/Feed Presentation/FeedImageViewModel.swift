//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/23/21.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
