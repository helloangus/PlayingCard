//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Angus Lee on 2020/2/6.
//  Copyright © 2020 Angus Lee. All rights reserved.
//

import UIKit

//可以在storyboard中直接看到效果
@IBDesignable
class PlayingCardView: UIView {
    
    //以下变量每次变化时都重绘view
    @IBInspectable
    var rank: Int = 13 { didSet { setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var suit: String = "♥️" { didSet { setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var isFaceUp: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout()}}

    //设置rank和suit分两行且中心对齐的函数
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString{
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)     //设置字体
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)             //字体可缩放
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center                                          //对齐
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle, .font:font])
    }
    
    //角落标示（数字和花色）的内容string
    private var cornerString: NSAttributedString{
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    //左上角标示和右下角标示的label
    private lazy var upperLeftCornerLabel: UILabel = createCornerLabel()
    private lazy var lowerRightCornerLabel: UILabel = createCornerLabel()
    
    //生成角标示的函数
    private func createCornerLabel() -> UILabel{
        let label = UILabel()
        label.numberOfLines = 0         //分多少行（为0则无数）
        addSubview(label)               //加一行
        return label
    }
    
    //设置角标参数的函数
    private func configureCornerLabel(_ label: UILabel){
        label.attributedText = cornerString     //设置label的内容string
        label.frame.size = CGSize.zero          //label大小为0
        label.sizeToFit()                       //再fit string的大小
        label.isHidden = !isFaceUp              //face up则不hidden
    }
    
    //当系统字体大小改变时，重绘view
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    //绘制卡牌内部子视图
    override func layoutSubviews() {
        super.layoutSubviews()                  //？？？
        
        //默认原点为左上角
        //设置左上角标label
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)      //角标label的左上角相对于bounds的左上角移动
        
        //设置右下角标label
        configureCornerLabel(lowerRightCornerLabel)
        lowerRightCornerLabel.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height)
            .rotated(by: CGFloat.pi)                                                                                //原点先平移到原右下角位置，再旋转pi
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)    //找到bounds的右下，再做两次平移
    }
    
    //为数字时画出对应数量的花色
    private func drawPips(){
        
        //对应的花色排布
        let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        //得到内部花色的String及其大小
        func creatPipString(thatFits pipRect: CGRect) -> NSAttributedString{
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) {max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) {max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            
            //超过了则进行缩放
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount{
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else{
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank){
            let pipsPerRow = pipsPerRowForRank[rank]        //取出每行pip的数量
            //绘制pips所在的矩形
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height/2)
            //得到对应的花色
            let pipString = creatPipString(thatFits: pipRect)
            //得到各行的间距
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            
            //外框大小同步
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            
            //绘制各行的pips
            for pipCount in pipsPerRow{
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)         //绘制在中心
                case 2:
                    pipString.draw(in: pipRect.leftHalf)    //分左右绘制
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                
                pipRect.origin.y += pipRowSpacing
            }
        }
        
    }
    
    //绘制卡牌外框
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)     //圆角矩形，用view的边界作为圆角矩形的边界
        roundedRect.addClip()
        UIColor.white.setFill()     //白色填充
        roundedRect.fill()
        
        //设置内部和背面填充图案
        if isFaceUp{                //卡牌朝上
            if let faceCardImage = UIImage(named: rankString, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                faceCardImage.draw(in: bounds.zoom(by: SizeRatio.faceCardImageSizeToBoundsSize)) //缩放
            } else{
                drawPips()
            }
        } else{                     //卡牌朝下
            if let cardBackImage = UIImage(named: "back"+"3", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                cardBackImage.draw(in: bounds)
            }
        }
        
    }

}

//扩展PlayingCardView中关于卡牌的一些参数
extension PlayingCardView{
    
    //相关比例
    private struct SizeRatio{
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    
    //外框圆角矩形半径
    private var cornerRadius: CGFloat{
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    //角标距离其他物件的偏移
    private var cornerOffset: CGFloat{
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    
    //角标字符大小
    private var cornerFontSize: CGFloat{
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    
    private var rankString: String{
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect{
    var leftHalf: CGRect{
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    
    var rightHalf: CGRect{
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    
    func inset(by size: CGSize) -> CGRect{
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth), dy: (height - newHeight))
    }
}

//扩展点的移动offset
extension CGPoint{
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
