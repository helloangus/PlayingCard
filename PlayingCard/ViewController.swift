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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 1...10{
            if let card = deck.draw(){
                print("\(card)")
            }
        }
    }


}

