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
    
    func upload(image: UIImage) -> Observable<String> {
        // 这里自己实现一下
        return Observable.create { (observer) -> Disposable in
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request = URLRequest(url: URL(string: "http://test.lefe_x")!)
            let uploadTask = session.uploadTask(with: request, from: UIImagePNGRepresentation(image), completionHandler: { (data, response, error) in
                if let aError = error {
                    observer.onError(aError)
                } else {
                    observer.onNext("")
                    observer.onCompleted()
                }
            })
            uploadTask.resume()
            return Disposables.create()
        }
    }
}

class Exampler1 {
    var imageUrls: [String] = []
    
    var observes = [Observable<String>]()
    
    func send(images: [UIImage], content: String, complete: (Bool)->()) {
        let firstImage = images.first
        if let image = firstImage {
            UploadManager.shared.upload(image: image).subscribe(onNext: { (url) in
                
            }, onError: { (error) in
                
            })
        }
    }
    
    func _sendTrend(urls: [String], content: String) {
        
    }
    
}
