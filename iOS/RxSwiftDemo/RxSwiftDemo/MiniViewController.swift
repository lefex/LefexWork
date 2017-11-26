//
//  MiniViewController.swift
//  RxSwiftDemo
//
//  Created by wsy on 2017/11/13.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MiniViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var nickName = "Hello world"
    var nickNameObserver: Observable<String>!

    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    override func viewDidLoad() {
        title = "修改昵称"
        super.viewDidLoad()
        
        nickNameObserver = Observable.just(nickName)
        nickNameObserver.bind(to: nickNameLabel.rx.text).disposed(by: disposeBag)

        nickNameTextField.rx.text.bind(to: nickNameLabel.rx.text).disposed(by: disposeBag)
        
        Observable<String>.create { (observer) -> Disposable in
            observer.onNext("Hello")
            return Disposables.create()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
