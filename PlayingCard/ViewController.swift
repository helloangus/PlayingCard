//
//  ViewController.swift
//  PlayingCard
//
//  Created by Angus Lee on 2020/2/6.
//  Copyright © 2020 Angus Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    //需要接收到具体的内容playingCardView用Outlet
    @IBOutlet weak var playingCardView: PlayingCardView!{
        didSet{
            //左右滑动下一张牌
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left, .right]
            playingCardView.addGestureRecognizer(swipe)
            
            //双指缩放图片
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(adjustFaceCardScale(byHandlingGestureRecognizedBy:)))  //target即对应函数所在的class中，若在PlayingCardView中，则为Outlet中的playingCardView
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    
    //检测有按下手势，翻转卡牌
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            playingCardView.isFaceUp = !playingCardView.isFaceUp
        default:
            break
        }
    }
    
    //被#selector调用加@objc前缀，deck中随机抽一张卡
    @objc func nextCard(){
        if let card = deck.draw(){
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    //获取手指缩放比例映射到faceCardScale中
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .changed,.ended:
            playingCardView.faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


}

