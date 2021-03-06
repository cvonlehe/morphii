//
//  RecentView.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/19/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class RecentView: ExtraView {

    @IBOutlet weak var noMorphiisLabel: UILabel!
    @IBOutlet weak var noMorphiisView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var morphiiScrollView: UIScrollView!
    var morphiis:[Morphii] = []
    var fetchType = MorphiiFetchType.Recents
    var morphiiOverlay:KeyboardMorphiiOverlayView?

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.loadNib()
         titleLabel.addSpacing(1.6)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("loading from nib not supported")
    }
    
    func loadMorphiis (fetchType:MorphiiFetchType) {
        morphiis.removeAll()
        self.fetchType = fetchType
        for subview in morphiiScrollView.subviews {
            subview.removeFromSuperview()
        }
        switch fetchType {
        case .Home:
            self.noMorphiisView.hidden = true
            self.morphiiScrollView.hidden = false
            titleLabel.text = "All Morphiis"
            morphiis = Morphii.getNonfavoriteMorphiis()
            if morphiis.count <= 0 {
                getMorphiisFromJSONFile()
                print("GOT_MORPHIIS_FROM_JSON:",morphiis)
            }
            break
        case .Recents:
            morphiis = Morphii.getMostRecentlyUsedMorphiis()
            if morphiis.count <= 0 {
                self.noMorphiisView.hidden = false
                self.morphiiScrollView.hidden = true
                self.noMorphiisLabel.text = "No Recently Sent Morphiis"
            }else {
                self.morphiiScrollView.hidden = false
                self.noMorphiisView.hidden = true
            }
            titleLabel.text = "Recently Sent Morphiis"
            break
        case .Favorites:
            morphiis = Morphii.getFavoriteMorphiis()
            if morphiis.count <= 0 {
                self.noMorphiisView.hidden = false
                self.morphiiScrollView.hidden = true
                self.noMorphiisLabel.text = "No Favorite Morphiis"
            }else {
                self.morphiiScrollView.hidden = false
                self.noMorphiisView.hidden = true
            }
            titleLabel.text = "Your Saved Morphiis"
            titleLabel.font = UIFont(name: "SFUIDisplay-Light" , size: 15)
            titleLabel.addTextSpacing(1.5)
            break
        }
        performSelector(#selector(RecentView.loadMorphiis as (RecentView) -> () -> ()), withObject: nil, afterDelay: 0.5)
    }
    
    func getMorphiisFromJSONFile () {
        guard let path = NSBundle.mainBundle().pathForResource("kb-app-morphiis", ofType: "json") else {return}
        do {
            let string = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else {return}
            morphiis = MorphiiAPI.convertJSONToMorphiis(data)
        }catch {
            
        }
    }
    
    func loadMorphiis () {
        let morphiiSideLength = frame.size.height / 2 - 10
        var x = CGFloat(0)
        var y = CGFloat(0)
        for morphii in morphiis {
            print("MOST_RECENTLY_USED:",morphii.lastUsedIntensity)
            let morphiiView = MorphiiSelectionView(frame: CGRect(x: x, y: y, width: morphiiSideLength, height: morphiiSideLength), morphii: morphii, delegate: nil, showName: fetchType != .Recents, useRecentIntensity: fetchType == .Recents)
            morphiiView.morphiiView.backgroundColor = UIColor.clearColor()
            morphiiView.backgroundColor = UIColor.clearColor()
            morphiiView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RecentView.morphiiSelectionViewTapped(_:))))
            morphiiScrollView.addSubview(morphiiView)
            if y > 0 {
                y = 0
                x += morphiiSideLength
            }else {
                y = morphiiSideLength
            }
        }
        morphiiScrollView.contentSize = CGSize(width: x + morphiiSideLength, height: (morphiiSideLength * 2))
        morphiiScrollView.scrollEnabled = true
    }
    
    func morphiiSelectionViewTapped (tap:UITapGestureRecognizer) {
        guard let morphiiSelectionView = tap.view as? MorphiiSelectionView else {return}
        switch self.fetchType {
        case .Home:
            MorphiiAPI.sendMorphiiSelectedToAWS(morphiiSelectionView.morphiiView.morphii, area: MorphiiAreas.keyboardHome)

            displayMorphiiOverylay(morphiiSelectionView.morphiiView.morphii, emoodl: nil)
            break
        case .Recents:
            MorphiiAPI.sendMorphiiSelectedToAWS(morphiiSelectionView.morphiiView.morphii, area: MorphiiAreas.keyboardRecent)

            displayMorphiiOverylay(morphiiSelectionView.morphiiView.morphii, emoodl: morphiiSelectionView.morphiiView.emoodl)
            break
        case .Favorites:
            MorphiiAPI.sendMorphiiSelectedToAWS(morphiiSelectionView.morphiiView.morphii, area: MorphiiAreas.keyboardFavorites)
            favoriteMorphiiTapped(morphiiSelectionView)
            break
        }

    }
    
    func favoriteMorphiiTapped (morphiiSelectionView:MorphiiSelectionView) {
        if MethodHelper.openAccessIsGranted() {
            print("GRANTED")
        }else {
            MethodHelper.showSuccessErrorHUD(false, message: "Full Access Required", inView: self)
            return
        }
        
        var newMorphiiView:MorphiiView? = MorphiiView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        newMorphiiView?.setUpMorphii(morphiiSelectionView.morphiiView.morphii, emoodl: morphiiSelectionView.morphiiView.emoodl)
        newMorphiiView?.backgroundColor = UIColor.clearColor()
        if newMorphiiView!.copyMorphyToClipboard(MorphiiAreas.keyboardFavorites) {
            MethodHelper.showSuccessErrorHUD(true, message: "Copied to Clipboard", inView: self)
            morphiiSelectionView.morphiiView.morphii.lastUsedIntensity = NSNumber(double: morphiiSelectionView.morphiiView.emoodl)
            CDHelper.sharedInstance.saveContext(nil)
        }else {
            MethodHelper.showSuccessErrorHUD(false, message: "Error Copying. Try again", inView: self)
        }
        newMorphiiView = nil
    }
    
    func loadNib() {
        let assets = NSBundle(forClass: self.dynamicType).loadNibNamed("RecentView", owner: self, options: nil)
        
        if assets.count > 0 {
            if let rootView = assets.first as? UIView {
                rootView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(rootView)
                
                let left = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
                let right = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
                let top = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
                let bottom = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
                
                self.addConstraint(left)
                self.addConstraint(right)
                self.addConstraint(top)
                self.addConstraint(bottom)
            }
        }
        
    }
    
    func addToSuperView (superView:UIView) {
        superView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -40)
        
        superView.addConstraint(widthConstraint)
        superView.addConstraint(top)
        superView.addConstraint(centerXConstraint)
        superView.addConstraint(bottom)

    }
   
    func displayMorphiiOverylay (morphii:Morphii, emoodl:Double?) {
        if morphiiOverlay == nil {
            var area = ""
            switch fetchType {
            case .Favorites:
                area = MorphiiAreas.keyboardFavorites
                break
            case .Home:
                area = MorphiiAreas.keyboardHome
                break
            case .Recents:
                area = MorphiiAreas.keyboardRecent
                break
            }
            morphiiOverlay = KeyboardMorphiiOverlayView(globalColors: globalColors, darkMode: false, solidColorMode: solidColorMode)

            morphiiOverlay?.addToSuperView(self, morphii: morphii, area: area, emoodl: emoodl)
        }
        
    }

}

extension RecentView:KeyboardMorphiiOverlayViewDelegate {
    func backButtonPressed() {
        morphiiOverlay?.removeFromSuperview()
        morphiiOverlay = nil
    }
    
}

extension UILabel{
   func addSpacing(spacing: CGFloat){
      let attributedString = NSMutableAttributedString(string: self.text!)
      attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: self.text!.characters.count))
      self.attributedText = attributedString
   }
}

enum MorphiiFetchType {
    case Recents
    case Favorites
    case Home
}
