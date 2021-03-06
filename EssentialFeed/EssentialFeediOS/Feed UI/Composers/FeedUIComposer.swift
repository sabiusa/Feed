//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/15/21.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(for: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(
        for controller: FeedViewController,
        loader: FeedImageDataLoader
    ) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                return FeedImageCellController(
                    viewModel: FeedImageViewModel(
                        model: model,
                        imageLoader: loader,
                        imageTransformer: UIImage.init
                    )
                )
            }
        }
    }
}
