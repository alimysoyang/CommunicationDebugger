//
//  VCMainRoot.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/9/2.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import UIKit

/// 主页面，通讯的所有数据、操作的界面
class VCMainRoot: VCAYHBase {

    // MARK: - property 属性
    private let kViewTag:Int = 2000;
    private var dayPages:Int = 0;
    private var isDidLoad:Bool = true;
    private var keyboardFrame:CGRect = CGRectZero;
    private var refreshHeader:UIRefreshControl?;
    private var messageTableView:UITableView?;
    private var keyboardInputView:AYHInputView?;
    private var alertController:AYHAlertSheetController?;
    private var popMenuView:AYHPopMenu?;
    
    private var serverManage:AYHServerManage?;
    private var clientManage:AYHClientManage?;
    
    // MARK: - life cycle ViewController生命周期
    deinit
    {
        AYHMessageManage.sharedInstance.delegate = nil;
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.isDidLoad = true;
        AYHMessageManage.sharedInstance.delegate = self;
        self.initViews();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hanlderEnterBackgroundNotification:"), name: UIApplicationDidEnterBackgroundNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlerEnterForegroundNotification:"), name: UIApplicationWillEnterForegroundNotification, object: nil);
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlerKeyboardWillShowNotification:"), name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlerKeyboardWillHideNotification:"), name: UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        if (self.isDidLoad)
        {
            self.isDidLoad = false;
            self.selectedDifferentInitViews();
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal override func reachabilityStatusChanged(notification: NSNotification) {
        super.reachabilityStatusChanged(notification);
        self.title = AYHelper.getIPAddress();
    }
    
    // MARK: - event response
    internal func handlerTableViewPullRefresh(refreshControl:UIRefreshControl)
    {
        AYHDBHelper.sharedInstance.loadMessages(AYHCMParams.sharedInstance.serviceType, socketType: AYHCMParams.sharedInstance.socketType, offSet: self.dayPages, completion: { [weak self] (success:Bool) -> Void in
            if (success)
            {
                self?.dayPages++;
            }
            refreshControl.endRefreshing();
            self?.messageTableView?.reloadData();
        });
    }
    
    internal func hanlderEnterBackgroundNotification(notification:NSNotification)
    {
        self.view.hideLoadAlert();
        self.closedSocket();
    }
    
    internal func handlerEnterForegroundNotification(notification:NSNotification)
    {
        self.closedSocket();
        self.startSocket();
    }
    
    internal func handlerKeyboardWillShowNotification(notification:NSNotification)
    {
        var duration:NSTimeInterval = 0.25;
        if let durationValue = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]
        {
            duration = durationValue.doubleValue;
        }
        self.keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue();
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.keyboardInputView?.transform = CGAffineTransformMakeTranslation(0.0, -self.keyboardFrame.size.height);
        });
    }
    
    internal func handlerKeyboardWillHideNotification(notification:NSNotification)
    {
        var duration:NSTimeInterval = 0.25;
        if let durationValue = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]
        {
            duration = durationValue.doubleValue;
        }
        self.keyboardFrame = CGRectZero;
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.keyboardInputView?.transform = CGAffineTransformIdentity;
        });
    }
    
    internal func handlerBarButtonItemClicked(sender:UIBarButtonItem)
    {
        let index:Int = sender.tag - kViewTag - 2;
        if (index == 0)
        {
            if let _ = self.popMenuView
            {
                self.popMenuView?.animationClose({ () -> Void in
                    self.popMenuView = nil;
                });
            }
            else
            {
                self.popMenuView = AYHPopMenu(frame: CGRectMake(self.view.frame.size.width - 140.0, 0.0, 140, 111.0));//155.0));
                self.popMenuView?.delegate = self;
                self.view.addSubview(self.popMenuView!);
            }
        }
        else
        {
            self.clientManage?.clientClosed();
            self.startSocket();
        }
    }
    
    // MARK: - private methods
    private func initViews()
    {
        self.title = AYHelper.getIPAddress();
        
        let popItems:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("handlerBarButtonItemClicked:"));
        popItems.tag = self.kViewTag + 2;
        self.navigationItem.rightBarButtonItem = popItems;
        
        self.messageTableView = UITableView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 114.0), style: UITableViewStyle.Plain);
        self.messageTableView?.backgroundColor = AYHelper.defaultBackgroundColor;
        self.messageTableView?.delegate = self;
        self.messageTableView?.dataSource = self;
        self.messageTableView?.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.view.addSubview(self.messageTableView!);
        
        self.refreshHeader = UIRefreshControl();
        self.refreshHeader?.tintColor = UIColor.blueColor();
        self.refreshHeader?.addTarget(self, action: Selector("handlerTableViewPullRefresh:"), forControlEvents: UIControlEvents.ValueChanged);
        self.messageTableView?.addSubview(self.refreshHeader!);
        
        self.keyboardInputView = AYHInputView(frame: CGRectMake(0.0, self.view.frame.size.height - 114.0, self.view.frame.size.width, 50.0));
        self.keyboardInputView?.delegate = self;
        self.view.addSubview(self.keyboardInputView!);
    }
    
    private func initRefreshBarButtonItem()
    {
        guard let _ = self.navigationItem.leftBarButtonItem else
        {
            let refreshItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("handlerBarButtonItemClicked:"));
            refreshItem.tag = self.kViewTag + 3;
            self.navigationItem.leftBarButtonItem = refreshItem;
            return;
        }
    }
    
    private func selectedDifferentInitViews()
    {
        if (AYHCMParams.sharedInstance.noConfigFile)
        {
            self.selectedServiceType();
        }
        else
        {
            self.selectedResetServiceType();
        }
    }
    
    private func selectedServiceType()
    {
        if let _ = self.alertController
        {
            self.alertController = nil;
        }
        
        self.alertController = AYHAlertSheetController(title: NSLocalizedString("TitleServiceType", comment: ""), message: nil, delegate: self, parentController: self, buttonTitles: NSLocalizedString("Server", comment: ""), NSLocalizedString("Client", comment: ""));
        self.alertController?.tag = self.kViewTag;
        self.alertController?.showView();
    }
    
    private func selectedResetServiceType()
    {
        if let _ = self.alertController
        {
            self.alertController = nil;
        }
        
        self.alertController = AYHAlertSheetController(title: NSLocalizedString("TitleLatestSettings", comment: ""), message: nil, delegate: self, parentController: self, buttonTitles: NSLocalizedString("YES", comment: ""), NSLocalizedString("Reset", comment: ""));
        self.alertController?.tag = self.kViewTag + 1;
        self.alertController?.showView();
    }
    
    private func toParamsSettingViewController()
    {
        let paramsSettingViewController:VCParamsSetting = VCParamsSetting(completion: { () -> Void in
            self.dayPages = 0;
            AYHDBHelper.sharedInstance.loadMessages(AYHCMParams.sharedInstance.serviceType, socketType: AYHCMParams.sharedInstance.socketType, offSet: self.dayPages, completion: { [weak self] (success:Bool) -> Void in
                self?.startSocket();
                if (success)
                {
                    self?.dayPages++;
                }
            });
        });
        let navigationController:UINavigationController = UINavigationController(rootViewController: paramsSettingViewController);
        self.presentViewController(navigationController, animated: true, completion: { () -> Void in
        });
    }
    
    private func startSocket()
    {
        if (AYHCMParams.sharedInstance.serviceType == .kCMSTServer)
        {
            if let _ = self.serverManage
            {
                self.serverManage?.serverClosed();
                self.serverManage = nil;
            }
            
            self.serverManage = AYHServerManage(delegate: self);
            self.serverManage?.serverReadied();
        }
        else
        {
            if let _ = self.clientManage
            {
                self.clientManage?.clientClosed();
                self.clientManage = nil;
            }
            
            self.clientManage = AYHClientManage(delegate: self);
            self.clientManage?.clientConnecting();
        }
    }
    
    private func closedSocket()
    {
        if (AYHCMParams.sharedInstance.serviceType == .kCMSTServer)
        {
            if let _ = self.serverManage
            {
                self.serverManage?.serverClosed();
                self.serverManage = nil;
            }
        }
        else
        {
            if let _ = self.clientManage
            {
                self.clientManage?.clientClosed();
                self.clientManage = nil;
            }
        }
    }
    
    private func scrollToTableViewBottom()
    {
        let index:Int = self.messageTableView!.numberOfRowsInSection(0) - 1;
        if (index >= 0)
        {
            let indexPath:NSIndexPath = NSIndexPath(forRow: index, inSection: 0);
            self.messageTableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true);
        }
    }
}

// MARK: - UITableView DataSource
extension VCMainRoot:UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AYHMessageManage.sharedInstance.count();
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100.0;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label:UILabel = UILabel(frame: CGRectZero);
        label.backgroundColor = UIColor.init(hexColor: "EFEFEF");
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        label.numberOfLines = 6;
        label.text = AYHCMParams.sharedInstance.decription();
        label.font = AYHelper.p15Font;
        label.sizeToFit();
        return label;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifer:String = "Cell";
        var cell:AYHMessageCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifer) as? AYHMessageCell;
        if (cell == nil)
        {
            cell = AYHMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifer);
        }
        
        cell?.index = indexPath.row;
        cell?.message = AYHMessageManage.sharedInstance[indexPath.row];
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

// MARK: - UITableView Delegate
extension VCMainRoot:UITableViewDelegate
{
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        UIApplication.sharedApplication().keyWindow?.endEditing(true);
        if let _ = self.popMenuView
        {
            self.popMenuView?.animationClose({ () -> Void in
                self.popMenuView = nil;
            });
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message:AYHMessage? = AYHMessageManage.sharedInstance[indexPath.row];
        guard let _ = message else
        {
            return 0.0;
        }
        return message!.msgCellHeight;
    }
}

// MARK: - AYHAlertSheetController Delegate
extension VCMainRoot : AYHAlertSheetControllerDelegate
{
    func alertController(alertController: AYHAlertSheetController, clickedButtonAtIndex buttonIndex: Int) {
        let index = alertController.tag - self.kViewTag;
        if (index == 0)// Server or Client
        {
            AYHCMParams.sharedInstance.serviceType = ServiceType(rawValue: buttonIndex)!;
            self.toParamsSettingViewController();
        }
        else // OK or Reset
        {
            if (buttonIndex == 0)
            {
                self.startSocket();
            }
            else if (buttonIndex == 1)// Reset
            {
                self.selectedServiceType();
            }
        }
    }
}

// MARK: - AYHInputView Delegate
extension VCMainRoot : AYHInputViewDelegate
{
    func inputViewDidViewHeightChange(inputView: AYHInputView) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            var frame:CGRect = self.keyboardInputView!.frame;
            frame.origin.y = self.view.frame.size.height - self.keyboardFrame.size.height - frame.size.height;
            self.keyboardInputView?.frame = frame;
        });
    }
    
    func inputView(inputView: AYHInputView, didSendData data: String?) {
        if let _ = data
        {
            if (AYHCMParams.sharedInstance.serviceType == .kCMSTServer)
            {
                self.serverManage?.serverSendData(data!);
            }
            else
            {
                self.clientManage?.clientSendData(data!);
            }
        }
    }
}

// MARK: - AYHPopMenu Delegate
extension VCMainRoot : AYHPopMenuDelegate
{
    func popMenu(popMenu: AYHPopMenu, selectedIndex index: Int) {
        switch (index)
        {
//        case 0:
//            if (self.messageTableView!.allowsMultipleSelectionDuringEditing)
//            {
//                self.messageTableView?.allowsMultipleSelectionDuringEditing = false;
//                self.messageTableView?.setEditing(false, animated: true);
//                AYHMessageManage.sharedInstance.updateEdit(false);
//            }
//            else
//            {
//                self.messageTableView?.allowsMultipleSelectionDuringEditing = true;
//                self.messageTableView?.setEditing(true, animated: true);
//                AYHMessageManage.sharedInstance.updateEdit(true);
//            }
        case 0:
            self.view.hideLoadAlert();
            self.navigationItem.leftBarButtonItem = nil;
            if (AYHCMParams.sharedInstance.serviceType == .kCMSTServer)
            {
                self.serverManage?.serverClosed();
            }
            else
            {
                self.clientManage?.clientClosed();
            }
            self.selectedServiceType();
        case 1:
            let settingsViewController:VCSettings = VCSettings();
            settingsViewController.delegate = self;
            self.navigationController?.pushViewController(settingsViewController, animated: true);
        default:
            break;
        }
        self.popMenuView = nil;
    }
}

// MARK: - VCSettings Delegate
extension VCMainRoot : VCSettingsDelegate
{
    func settingsDidStartClearCache() {
        self.closedSocket();
    }
    
    func settingsDidEndClearCache() {
        self.startSocket();
    }
}

// MARK: - AYHMessageManage Delegate
extension VCMainRoot : AYHMessageManageDelegate
{
    func messageManageDidAdded() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.messageTableView?.reloadData();
            self.scrollToTableViewBottom();
//            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(1) * NSEC_PER_SEC));
//            dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
//                self.scrollToTableViewBottom();
//            });
        });
    }
    
    func messageManageDidUpdate() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.messageTableView?.reloadData();
        });
    }
    
    func messageManageDidRemoved() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.messageTableView?.reloadData();
            //self.scrollToTableViewBottom();
        });
    }
    
    func messageManageDidRemoveAll() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.messageTableView?.reloadData();
        });
    }
}

// MARK: - AYHServerManage Delegate
extension VCMainRoot : AYHServerManageDelegate
{
    func serverManage(serverManage: AYHServerManage, didReadied info: String) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
//    func udpServerManage(serverManage: AYHServerManage, receivedThenSaveSuccess success: Bool) {
//        self.messageTableView?.reloadData();
//        self.scrollToTableViewBottom();
//    }
//    
//    func tcpServerManage(serverManage: AYHServerManage, didAcceptNewSocket info: String) {
//        //这个比较特殊，应该走的是子线程，不是主线程
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.messageTableView?.reloadData();
//            self.scrollToTableViewBottom();
//        });
//    }
//    
//    func tcpServerManage(serverManage: AYHServerManage, receivedThenSaveSuccess success: Bool) {
//        self.messageTableView?.reloadData();
//        self.scrollToTableViewBottom();
//    }
//    
//    func serverManage(serverManage: AYHServerManage, sendedThenSaveSuccess success: Bool) {
//        self.messageTableView?.reloadData();
//        self.scrollToTableViewBottom();
//    }
//}

// MARK: - AYHClientManage Delegate
extension VCMainRoot : AYHClientManageDelegate
{
    func udpClientManage(clientManage: AYHClientManage, didConnected info: String) {

    }
    
    func udpClientManage(clientManage: AYHClientManage, receivedThenSaveSuccess success: Bool) {

    }
    
    func tcpClientManage(clientManage: AYHClientManage, didNotConnected error: String) {
        self.view.hideLoadAlert();
        self.initRefreshBarButtonItem();
    }
    
    func tcpClientManageDidConnecting(clientManage: AYHClientManage) {
        self.view.showLoadAlert(String(format: NSLocalizedString("ServerConnecting", comment: ""), "TCP"));
    }
    
    func tcpClientManage(clientManage: AYHClientManage, didConnected connectInfo: String) {
        self.view.hideLoadAlert();
        if let _ = self.navigationItem.leftBarButtonItem
        {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    
    func tcpClientManage(clientManage: AYHClientManage, didDisConnected error: String) {
        self.view.hideLoadAlert();
        
        self.initRefreshBarButtonItem();
    }
    
    func tcpClientManage(clientManage: AYHClientManage, receivedThenSaveSuccess success: Bool) {

    }
    
    func clientManage(clientManage: AYHClientManage, sendedThenSaveSuccess success: Bool) {

    }
}
