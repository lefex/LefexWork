//
//  NickNameViewController.swift
//  RxSwiftDemo
//
//  Created by WangSuyan on 2017/11/7.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

import UIKit
import RxSwift

class NickNameViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var nickNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "昵称"
        
        DispatchQueue.global().async {
            self.from()
        }
    }
    
    func from() {
        Observable.from(["Lefe", "Lefe_x", "lefex", "wsy", "Rx"])
            .subscribeOn(MainScheduler.instance)
            .filter({ (text) -> Bool in
                return text == "Lefe_x"
            })
            .map({ (text) -> String in
                return "我的新浪微博是: " + text
            })
            .subscribe(onNext: { [weak self] (text) in
                self?.nickNameLabel.text = text
            })
            .disposed(by: disposeBag)
    }

}
