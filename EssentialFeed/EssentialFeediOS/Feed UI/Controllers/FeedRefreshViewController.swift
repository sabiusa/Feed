//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/15/21.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private let presenter: FeedPresenter
    
    private(set) lazy var view = makeView()
        
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    @objc
    func refresh() {
        presenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
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
