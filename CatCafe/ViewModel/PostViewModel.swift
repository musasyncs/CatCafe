//
//  PostViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import Foundation

struct PostViewModel {
    
    private let post: Post
    
    var mediaUrl: URL? {
        return URL(string: post.mediaUrlString)
    }
    
    var caption: String {
        return post.caption
    }
    
    init(post: Post) {
        self.post = post
    }
}
