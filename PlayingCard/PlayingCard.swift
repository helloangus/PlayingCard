//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Angus Lee on 2020/2/6.
//  Copyright © 2020 Angus Lee. All rights reserved.
//

import Foundation

struct PlayingCard: CustomStringConvertible {
    
    //包括前面的CustomStringConvertible，在print时，输出自定义的String
    var description: String { return "Rank = \(rank)\nSuit = \(suit)\n"}
    
    var suit: Suit
    var rank: Rank

    //花色枚举
    enum Suit: String, CustomStringConvertible {
        
        var description: String{return rawValue}
        
        case spades = "♠️"
        case hearts = "♥️"
        case diamonds = "♣️"
        case clubs = "♦️"
        
        //所有的花色
        static var all = [Suit.spades, .hearts, .diamonds, .clubs]
    }
    
    //数字枚举（分A、数字、和字母）
    enum Rank: CustomStringConvertible {
        
        var description: String{
            switch self {
            case .ace:  return "A"
            case .numeric(let pips):    return String(pips)
            case .face(let kind):   return kind
            }
        }
        
        case ace
        case face(String)
        case numeric(Int)
        
        //把三种情况翻译成对应数字
        var order: Int {
            switch self {
            case .ace: return 1
            case .numeric(let pips): return pips
            case .face(let kind) where kind == "J": return 11   //相当于if
            case .face(let kind) where kind == "Q": return 12
            case .face(let kind) where kind == "K": return 13
            default: return 0
            }
        }
        
        //所有的数字
        static var all: [Rank]{
            var allRanks = [Rank.ace]
            for pips in 2...10 {
                allRanks.append(Rank.numeric(pips))
            }
            allRanks += [Rank.face("J"), .face("Q"), .face("K")]
            return allRanks
        }
        
    }
}
