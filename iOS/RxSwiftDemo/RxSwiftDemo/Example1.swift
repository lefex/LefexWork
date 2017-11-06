//
//  Example1.swift
//  RxSwiftDemo
//
//  Created by WangSuyan on 2017/11/6.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

import Foundation
import RxSwift

class UploadManager{
    public static let shared = UploadManager()
    
    func upload(image: UIImage, complete: (Bool, String)->()) {
        
    }
}

class Exampler1 {
    var imageUrls: [String] = []
    
    func send(images: [UIImage], content: String, complete: (Bool)->()) {
        for image in images {
            UploadManager.shared.upload(image: image, complete: { (isSuccess, url) in
                if (isSuccess) {
                    imageUrls.append(url)
                } else {
                    complete(false)
                }
                if (images.count == imageUrls.count){
                    _sendTrend(urls: imageUrls, content: content)
                }
            })
        }
    }
    
    func _sendTrend(urls: [String], content: String) {
        
    }
    
}
