//
//  SettingsViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/6/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tosPpContainerView: UIView!
    @IBOutlet weak var ourBlogContainerView: UIView!
    @IBOutlet weak var feedbackContainerView: UIView!
    @IBOutlet weak var inviteFriendsContainerView: UIView!
    @IBOutlet weak var rateThisAppContainerView: UIView!
    @IBOutlet weak var setupKeyboardContainerView: UIView!
    @IBOutlet weak var urlSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addGestureRecognizers()
        urlSwitch.setOn(!MethodHelper.shouldNotAddURLToMessages(), animated: true)
    }
    
    func addGestureRecognizers () {
        ourBlogContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.ourBlogContainerViewTapped(_:))))
        tosPpContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.tosPpContainerViewTapped(_:))))
        feedbackContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.feedbackContainerViewTapped(_:))))
        inviteFriendsContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.inviteFriendsContainerViewTapped(_:))))
        rateThisAppContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.rateThisAppContainerViewTapped(_:))))
        setupKeyboardContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.setupKeyboardContainerViewTapped(_:))))
        
    }
    
    //MARK: - Tap Gesture Recognizers
    
    func ourBlogContainerViewTapped (tap:UITapGestureRecognizer) {
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SettingsWebViewController) as! SettingsWebViewController
        nextView.loadURL = SettingsWebViewController.URLs.ourBlog
        presentViewController(nextView, animated: true, completion: nil)
    }
    
    func tosPpContainerViewTapped (tap:UITapGestureRecognizer) {
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SettingsWebViewController) as! SettingsWebViewController
        nextView.loadURL = SettingsWebViewController.URLs.tosPP
        presentViewController(nextView, animated: true, completion: nil)
    }
    
    func feedbackContainerViewTapped (tap:UITapGestureRecognizer) {
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SettingsWebViewController) as! SettingsWebViewController
        nextView.loadURL = SettingsWebViewController.URLs.feedback
        presentViewController(nextView, animated: true, completion: nil)
    }
    
    func inviteFriendsContainerViewTapped (tap:UITapGestureRecognizer) {
        let string = "Check out Morphii Keyboard: \(Config.getCurrentConfig().appStoreUrl)"
        let activityViewController = UIActivityViewController(activityItems: [string], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func rateThisAppContainerViewTapped (tap:UITapGestureRecognizer) {
        MethodHelper.openURLInDefaultBrowser(Config.getCurrentConfig().appStoreUrl)
    }
    
    func setupKeyboardContainerViewTapped (tap:UITapGestureRecognizer) {
        TutorialViewController.presenTutorialViewController(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: tosPpContainerView.frame.origin.y + tosPpContainerView.frame.size.height + 30)
        scrollView.scrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchFlipped(sender: UISwitch) {
        MethodHelper.setShouldNotAddURLToMessages(!sender.on)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}