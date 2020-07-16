//
//  IndexSegmentView.swift
//  XEsports
//
//  Created by Zhu on 2020/5/7.
//  Copyright © 2020 xianyu. All rights reserved.
//

import UIKit

private let marginLR:CGFloat = 15
private var titleH: CGFloat = 22 //根据页签高度变化
private let lineH : CGFloat = 2

protocol IndexSegmentViewDelegate : class {
    func indexSegmentSelectItemAtIndex(_ index: NSInteger, titleStr : String) ->()
}

class IndexSegmentView: UIView, UIScrollViewDelegate {
    
    weak var delegate: IndexSegmentViewDelegate? //代理
    private var oldSel: NSInteger?
    //字体大小
    var fontSize : CGFloat?
    //字体颜色
    var defauleTitleColor : UIColor?{
        didSet{
            if titleStrArr?.count ?? 0 > 5 {
                segmentSetAutoTitles()
            }else{
                segmentSetTitles() //在数据源之后设置的话也要生效
            }
            
        }
    }
    //选中字体颜色
    var selTitileColor : UIColor?{
        didSet{
             if titleStrArr?.count ?? 0 > 5 {
                 segmentSetAutoTitles()
             }else{
                 segmentSetTitles() //在数据源之后设置的话也要生效
             }
        }
    }
    //线条color
    var lineColor : UIColor?{
        didSet{
            moveLine.backgroundColor = lineColor
        }
    }
 //titleArr
    var titleStrArr : [String]? {
        didSet{
            if titleStrArr?.count ?? 0 > 5 {
                segmentSetAutoTitles()
            }else{
                segmentSetTitles() //在数据源之后设置的话也要生效
            }
        }
    }
    ///动态高度的titleArr
//    var autoTitleArr : [String]? {
//        didSet{
//            
//        }
//    }
    //用于刷新位置
    var scrollSelIndex : NSInteger? {
        didSet{
                let oldBtn : UIButton = scrollview.viewWithTag(oldSel!) as! UIButton
                oldBtn.setTitleColor(defauleTitleColor ?? UIColor.appLightGrayColor , for: .normal)
                let selBtn : UIButton = scrollview.viewWithTag( scrollSelIndex! + 3000) as! UIButton
                selBtn.setTitleColor(selTitileColor ?? UIColor.appBlackColor, for: .normal)
                var maxIndex = 5
                if kWidth < 375 {
                    maxIndex = 3
                }
                //控制翻屏页数
//                let temp = (scrollSelIndex! / maxIndex)
                //line的宽度
                let size : CGSize = boundingRect(text: selBtn.titleLabel?.text ?? "", size: CGSize(width: CGFloat(MAXFLOAT), height: selBtn.height), font: UIFont.boldSystemFont(ofSize: 13)).size
                moveLine.frame = CGRect(x: moveLine.x, y: moveLine.y, width: size.width, height: moveLine.height)
                UIView.animate(withDuration: 0.2) {
                    self.moveLine.center = CGPoint(x: selBtn.center.x, y: self.moveLine.center.y)
                    //流畅滚动的重要逻辑
                    var scrollX = (selBtn.center.x - self.scrollview.width*0.5)
                    if scrollX < 0 {
                        scrollX = 0
                    }
                    if scrollX > (self.scrollview.contentSize.width - self.scrollview.width) {
                        scrollX = (self.scrollview.contentSize.width - self.scrollview.width)
                    }
                    self.scrollview.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
                    
                }
                oldSel = scrollSelIndex! + 3000
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollview)
        scrollview.addSubview(moveLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///MARK:-----lazy
    lazy var moveLine: UIView = {
        let moveLine = UIView(frame: CGRect(x: marginLR, y: scrollview.bounds.size.height - lineH, width: 40, height: lineH))//40随便指定一个初值
        return moveLine
    }()
    //scrollView
    lazy var scrollview : UIScrollView = {
        let scrollview = UIScrollView(frame: CGRect(x: marginLR, y: 0, width: bounds.size.width-2*marginLR, height: bounds.size.height))
        scrollview.isPagingEnabled = false
        scrollview.delegate = self
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.isDirectionalLockEnabled = true
        return scrollview
    }()
    //collection
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView.init(frame: CGRect(x: marginLR, y: 0, width:bounds.size.width-2*marginLR , height: bounds.size.height), collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.dataSource = self
        collection.delegate = self
        collection.register(UINib.init(nibName: "IndexSelectCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "IndexSelectCollectionCellId")
        return collection
    }()
    
}

extension IndexSegmentView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //布局子视图
    func segmentSetTitles()->Void{
        
        for view in scrollview.subviews {
            if view.isKind(of: UIButton.self ){
                view.removeFromSuperview()
            }
        }
        scrollview.contentSize = .zero
        
        guard titleStrArr?.isEmpty == false else {
           return
        }
        var  w : CGFloat = 0
        var  margin0 : CGFloat = 0
        var itemNum : Int = 5 //一屏最多放置的个数
        
        if kWidth >= 375 {//考虑比5s大的这种屏 ---最多一屏放5个
            itemNum = 5
            if titleStrArr?.count ?? 0 > (itemNum-1) {
                
                w  = (scrollview.bounds.size.width-marginLR*2)/CGFloat(itemNum)
                margin0 = marginLR
                scrollview.contentSize = CGSize(width: scrollview.width + (CGFloat(titleStrArr!.count)-CGFloat(itemNum))*w, height: scrollview.height)
            }else{ //不足五个的居中放
                margin0 = marginLR*(CGFloat(itemNum)-CGFloat(titleStrArr!.count)) //间距
                w = (scrollview.bounds.size.width-margin0*2)/CGFloat(titleStrArr!.count)
                scrollview.contentSize = CGSize(width: scrollview.width, height: scrollview.height)
            }
            
        }else{//考虑5s这种小屏---最多一屏放3个
            itemNum = 3
            if titleStrArr?.count ?? 0 > (itemNum-1) {
                scrollview.contentSize = CGSize(width: scrollview.width + (CGFloat(titleStrArr!.count)-CGFloat(itemNum))*w, height: scrollview.height)
                w  = (scrollview.bounds.size.width-marginLR*2)/CGFloat(itemNum)
                margin0 = marginLR
                scrollview.contentSize = CGSize(width: scrollview.width + (CGFloat(titleStrArr!.count)-CGFloat(itemNum))*w, height: scrollview.height)
                
            }else{ //不足3个的居中放,两侧间距适当留大。以保证居中
                margin0 = marginLR*(CGFloat(itemNum)-CGFloat(titleStrArr!.count)) //间距
                
                w = (scrollview.bounds.size.width-margin0*2)/CGFloat(titleStrArr!.count)
                scrollview.contentSize = CGSize(width: scrollview.width, height: scrollview.height)
            }
        }
        //文字居中放置
        titleH = self.height-lineH
        
        for index  in 0...titleStrArr!.count-1 {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: margin0+CGFloat(index)*w, y: moveLine.frame.minY-titleH, width: w, height: titleH)
            let titleStr : String = titleStrArr![index]
            btn.tag = 3000+index
            btn.setTitle(titleStr, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            btn.titleLabel?.textAlignment = .center
            btn.setTitleColor(defauleTitleColor ?? UIColor.appLightGrayColor , for: .normal)
            if index == 0 {
                btn.setTitleColor(selTitileColor ?? UIColor.appBlackColor , for: .normal)
                
                let size : CGSize = boundingRect(text: btn.titleLabel?.text ?? "", size: CGSize(width: CGFloat(MAXFLOAT), height: btn.height), font: UIFont.boldSystemFont(ofSize: 13)).size
                moveLine.frame = CGRect(x: moveLine.x, y: moveLine.y, width: size.width, height: moveLine.height)
                moveLine.center = CGPoint(x: btn.center.x, y: moveLine.center.y)
                oldSel = btn.tag
            }
            print("-----\(btn.titleLabel?.text)")
            btn.addTarget(self, action: #selector(clickBtn(_:)), for: .touchUpInside)
            scrollview.addSubview(btn)
        }
    }
    //点击事件
    @objc func clickBtn(_  sender: UIButton){
           let oldBtn : UIButton = scrollview.viewWithTag(oldSel!) as! UIButton
           oldBtn.setTitleColor(defauleTitleColor ?? UIColor.appLightGrayColor , for: .normal)
           //设置新选中的btn
           sender.setTitleColor(selTitileColor ?? UIColor.appBlackColor , for: .normal)
           
            let size : CGSize = boundingRect(text: sender.titleLabel?.text ?? "", size: CGSize(width: CGFloat(MAXFLOAT), height: sender.height), font: UIFont.boldSystemFont(ofSize: 13)).size
            moveLine.frame = CGRect(x: moveLine.x, y: moveLine.y, width: size.width, height: moveLine.height)
           UIView.animate(withDuration: 0.2) {
               self.moveLine.center = CGPoint(x: sender.center.x, y: self.moveLine.center.y)
           }
           delegate?.indexSegmentSelectItemAtIndex(sender.tag-3000, titleStr: titleStrArr![sender.tag - 3000])
           oldSel = sender.tag
       }
    //动态布局子视图
       func segmentSetAutoTitles()->Void{ //>5
           
           for view in scrollview.subviews {
               if view.isKind(of: UIButton.self ){
                   view.removeFromSuperview()
               }
           }
        scrollview.contentSize = CGSize(width: CGFloat(MAXFLOAT), height: (titleH + moveLine.height))
           
           guard titleStrArr?.isEmpty == false else {
              return
           }
           let  margin0 : CGFloat = 20
           var contentW : CGFloat = 0.0
           var widthTemp : CGFloat = 0.0
           //文字居中放置
           titleH = self.height-lineH
//        var buttonX : CGFloat = 0
           for i  in 0...titleStrArr!.count-1 {
            let titleStr = titleStrArr?[i]
             let size : CGSize = boundingRect(text: titleStr ?? "", size: CGSize(width: CGFloat(MAXFLOAT), height: titleH), font: UIFont.boldSystemFont(ofSize: 13)).size
                widthTemp = (size.width < 60 ? 60 : size.width)
               
               let btn = UIButton(type: .custom)
              
               btn.frame = CGRect(x: (margin0 + contentW), y: moveLine.frame.minY-titleH, width: widthTemp, height: titleH)
               btn.tag = 3000+i
               print("========\(btn.frame)")
               btn.setTitle(titleStr, for: .normal)
               btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
               btn.titleLabel?.textAlignment = .center
               btn.setTitleColor(defauleTitleColor ?? UIColor.appLightGrayColor , for: .normal)
               if i == 0 {
                   btn.setTitleColor(selTitileColor ?? UIColor.appBlackColor , for: .normal)
                   moveLine.frame = CGRect(x: moveLine.x, y: moveLine.y, width: size.width, height: moveLine.height)
                   moveLine.center = CGPoint(x: btn.center.x, y: moveLine.center.y)
                   oldSel = btn.tag
               }
               contentW += (widthTemp + margin0)
               
               btn.addTarget(self, action: #selector(clickBtn(_:)), for: .touchUpInside)
               scrollview.addSubview(btn)
           }
           scrollview.contentSize = CGSize(width: contentW, height: (titleH + moveLine.height))
       }
    
//    //点击事件
//       @objc func clickAutoBtn(_  sender: UIButton){
//              let oldBtn : UIButton = scrollview.viewWithTag(oldSel!) as! UIButton
//              oldBtn.setTitleColor(defauleTitleColor ?? UIColor.appLightGrayColor , for: .normal)
//              //设置新选中的btn
//              sender.setTitleColor(selTitileColor ?? UIColor.appBlackColor , for: .normal)
//
//               let size : CGSize = boundingRect(text: sender.titleLabel?.text ?? "", size: CGSize(width: CGFloat(MAXFLOAT), height: sender.height), font: UIFont.font(fontSize ?? 13, weight: .semibold)).size
//               moveLine.frame = CGRect(x: moveLine.x, y: moveLine.y, width: size.width, height: moveLine.height)
//              UIView.animate(withDuration: 0.2) {
//                  self.moveLine.center = CGPoint(x: sender.center.x, y: self.moveLine.center.y)
//                self.scrollview.contentOffset = CGPoint(x: self.moveLine.x, y: 0)
//              }
//              delegate?.indexSegmentSelectItemAtIndex(sender.tag-3000, titleStr: titleStrArr![sender.tag - 3000])
//              oldSel = sender.tag
//          }
    
//collection delegate / dataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleStrArr?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexSelectCollectionCellId", for: indexPath)
        
        return cell
    }
}

extension IndexSegmentView {
   //文字计算
    func boundingRect(text: String , size : CGSize, font : UIFont) -> CGRect{

        return text.boundingRect(with: size, options: [.usesLineFragmentOrigin ], attributes: [NSAttributedString.Key.font : font],context:nil)
    }
}



