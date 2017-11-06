//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by WangSuyan on 2017/11/6.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func registerRx() {
        let nickNameValid = nickNameTextField.rx.text.orEmpty
            .map { (text) -> Bool in
            let tLength = text.characters.count
            print(text)
            return tLength >= 3 && tLength <= 10
            }
            .share(replay: 1)
        
        nickNameValid
            .bind(to: alertLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        nickNameValid
            .bind(to: changeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        changeButton.rx.tap
            .subscribe { (next) in
            let alert = UIAlertController(title: "修改昵称成功!", message: "本Demo由Lefe_x提供", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}

