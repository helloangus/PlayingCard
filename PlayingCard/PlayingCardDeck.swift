//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by Angus Lee on 2020/2/6.
//  Copyright © 2020 Angus Lee. All rights reserved.
//

import Foundation

//生成卡组，每次抽卡就移除对应卡片
struct PlayingCardDeck {
    private(set) var cards = [PlayingCard]()
    
    //初始化
    init(){
        for suit in PlayingCard.Suit.all{
            for rank in PlayingCard.Rank.all{
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
    
    mutating func draw() -> PlayingCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}

//扩展，输出Int型随机数
extension Int{
    var arc4random: Int{
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}
