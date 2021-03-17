//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/15/21.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private let loadFeed: () -> Void
    
    private(set) lazy var view = makeView()
        
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    @objc
    func refresh() {
        loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func makeView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
