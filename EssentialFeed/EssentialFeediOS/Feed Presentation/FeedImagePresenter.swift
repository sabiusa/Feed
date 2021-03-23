//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/17/21.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewData<Image>)
}

struct FeedImageViewData<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private enum Error: Swift.Error {
        case invalidImageData
    }
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(
        view: View,
        imageTransformer: @escaping (Data) -> Image?
    ) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewData(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: Error.invalidImageData, for: model)
        }
        
        view.display(
            FeedImageViewData(
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                shouldRetry: false
            )
        )
    }
    
    func didFinishLoadingImageData(with error: Swift.Error, for model: FeedImage) {
        view.display(
            FeedImageViewData(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}
