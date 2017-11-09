//
//  Creater.swift
//  RxSwiftDemo
//
//  Created by wsy on 2017/11/6.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class Creater {
    let disposeBag = DisposeBag()
    func never() {
        Observable<String>.never()
            .subscribe { (event) in
                print("Never")
                print(event)
            }.disposed(by: disposeBag)
    }
    
    func from() {
        Observable.from(["Lefe", "Lefe_x", "lefex", "wsy", "RxSwift", "RxJava", "iOS", "Node"])
            .filter({ (text) -> Bool in
                return text.contains("Lefe")
            })
            .map({ (text) -> String in
                return "My web name is: " + text
            })
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func of() {
        Observable.of("Lefe_x", "lefe").subscribe(onNext: { (text) in
            print(text)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("completed!")
        }).disposed(by: disposeBag)
    }
    
    func create() {
       let observable = Observable<String>.create { (observer) -> Disposable in
        observer.onNext("Hello lefe, I am here!")
        observer.onCompleted()
            return Disposables.create()
        }
        
        observable.subscribe(onNext: { (text) in
            print(text)
        }, onError: nil, onCompleted: {
            print("complete!")
        }, onDisposed: nil).disposed(by: disposeBag)
    }
}
