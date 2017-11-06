//
//  Protocol.swift
//  RxSwiftDemo
//
//  Created by WangSuyan on 2017/11/6.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

import Foundation


/// 协议实现范型
public protocol Atypeable {
    associatedtype E
    mutating func next() -> E?
}
