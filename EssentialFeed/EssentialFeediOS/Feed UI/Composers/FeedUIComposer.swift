//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/15/21.
//

import EssentialFeed

public final class FeedUIComposer {
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                return FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return feedController
    }
}
