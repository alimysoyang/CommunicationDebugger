//
//  VCParamsSetting.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/24.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import UIKit
import Foundation

typealias settingCompletionClosure = () -> Void;

class VCParamsSetting: VCAYHBase 
{
    // MARK: - property 属性
    private let kViewTag:Int = 1000;
    private let cellRowHeight:CGFloat = 56.0;
    private let paramsTitles:[String] = {
        var titles:[String] = [String]();
        titles.append(NSLocalizedString("SendedDataType", comment: "SendedDataType"));
        titles.append(NSLocalizedString("ReceivedDataType", comment: "ReceivedDataType"));
        if (AYHCMParams.sharedInstance.serviceType == .kCMSTServer)
        {
            titles.append(NSLocalizedString("LocalPort", comment: "LocalPort"));
        }
        else
        {
            titles.append(NSLocalizedString("RemoteIP", comment: "RemoteIP"));
            titles.append(NSLocalizedString("RemotePort", comment: "RemotePort"));
        }
        return titles;
    }();

    private var completionClosure:settingCompletionClosure?;
    
    private var tvParams:UITableView?;
    private var scSCharacterSet:UISegmentedControl?;
    private var scRCharacterSet:UISegmentedControl?;
    private var swSHexData:UISwitch?;
    private var swRHexData:UISwitch?;
    private var tfLocalPort:UITextField?;
    private var tfRemoteIP:UITextField?;
    private var tfRemotePort:UITextField?;
    private var btnDone:UIButton?;
    
    // MARK: - life cycle ViewController生命周期
    init(completion:settingCompletionClosure)
    {
        super.init(nibName: nil, bundle: nil);
        self.completionClosure = completion;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.initViews();
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        let phoneSizeType:PhoneSizeType = AYHelper.currentDevicePhoneSizeType();
        if (phoneSizeType == .kPST_3_5)
        {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlerKeyboardWillShowNotification:"), name: UIKeyboardWillShowNotification, object: nil);
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlerKeyboardWillHideNotification:"), name: UIKeyboardWillHideNotification, object: nil);
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - event response
    internal func barButtonItemClicked(sender:UIBarButtonItem)
    {
        self.view.endEditing(true);
        if (AYHCMParams.sharedInstance.serviceType == .kCMSTServer)
        {
            if (AYHCMParams.sharedInstance.localPort == 0)
            {
                self.showAlertTip(NSLocalizedString("TipPort", comment: ""));
                return;
            }
        }
        else
        {
            if (!AYHCMParams.sharedInstance.remoteIP.isValideIPAddress())
            {
                self.showAlertTip(NSLocalizedString("TipIPAddress", comment: ""));
                return;
            }
            
            if (AYHCMParams.sharedInstance.remotePort == 0)
            {
                self.showAlertTip(NSLocalizedString("TipPort", comment: ""));
                return;
            }
        }
        
        AYHCMParams.sharedInstance.toSave();
        if let _ = self.completionClosure
        {
            self.completionClosure!();
        }
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
        });
    }
    
    internal func segmentedControlValueChanged(sender:UISegmentedControl)
    {
        let index = sender.tag - self.kViewTag;
        if (index == 0)
        {
            AYHCMParams.sharedInstance.socketType = SocketType(rawValue: sender.selectedSegmentIndex)!;
        }
        else if (index == 1)
        {
            AYHCMParams.sharedInstance.sCharacterSet = SocketCharacetSet(rawValue: sender.selectedSegmentIndex)!;
        }
        else if (index == 2)
        {
            AYHCMParams.sharedInstance.rCharacterSet = SocketCharacetSet(rawValue: sender.selectedSegmentIndex)!;
        }
    }
    
    internal func switchValueChanged(sender:UISwitch)
    {
        let index = sender.tag - self.kViewTag;
        if (index == 3)
        {
            AYHCMParams.sharedInstance.sHexData = sender.on;
        }
        else if (index == 4)
        {
            AYHCMParams.sharedInstance.rHexData = sender.on;
        }
        
        let indexPath:NSIndexPath = NSIndexPath(forRow: index - 3, inSection: 0);
        self.tvParams?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None);
    }
    
    internal func textFieldEditingValueChanged(sender:UITextField)
    {
        let index = sender.tag - self.kViewTag;
        if (index == 5)
        {
            guard let text = sender.text else
            {
                AYHCMParams.sharedInstance.localPort = 0;
                return;
            }
            
            if (text.isEmpty)
            {
                AYHCMParams.sharedInstance.localPort = 0;
            }
            else
            {
                AYHCMParams.sharedInstance.localPort = UInt(text)!;
            }
        }
        else if (index == 6)
        {
            guard let text = sender.text else
            {
                AYHCMParams.sharedInstance.remoteIP = "";
                return;
            }
            
            AYHCMParams.sharedInstance.remoteIP = text;
        }
        else if (index == 7)
        {
            guard let text = sender.text else
            {
                AYHCMParams.sharedInstance.remotePort = 0;
                return;
            }
            
            if (text.isEmpty)
            {
                AYHCMParams.sharedInstance.remotePort = 0;
            }
            else
            {
                AYHCMParams.sharedInstance.remotePort = UInt(text)!;
            }
        }
    }
    
    internal func handlerKeyboardWillShowNotification(notification:NSNotification)
    {
        var duration:NSTimeInterval = 0.25;
        if let durationValue = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]
        {
            duration = durationValue.doubleValue;
        }
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            if (AYHCMParams.sharedInstance.serviceType == .kCMSTClient)
            {
                self.tvParams?.transform = CGAffineTransformMakeTranslation(0.0, -26.0);
            }
        });
    }
    
    internal func handlerKeyboardWillHideNotification(notification:NSNotification)
    {
        var duration:NSTimeInterval = 0.25;
        if let durationValue = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]
        {
            duration = durationValue.doubleValue;
        }
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.tvParams?.transform = CGAffineTransformIdentity;
        });
    }
    
    // MARK: - public methods
    
    // MARK: - private methods
    private func initViews()
    {
        self.navigationItem.titleView = {
            let segmentedControl:UISegmentedControl = UISegmentedControl(items: ["UDP", "TCP"]);
            segmentedControl.frame = CGRectMake(0.0, 0.0, 150.0, 30.0);
            segmentedControl.tag = self.kViewTag;
            segmentedControl.addTarget(self, action: Selector("segmentedControlValueChanged:"), forControlEvents: UIControlEvents.ValueChanged);
            segmentedControl.selectedSegmentIndex = AYHCMParams.sharedInstance.socketType.rawValue;
            return segmentedControl;
        }();
        self.navigationItem.rightBarButtonItem = {
            let okItem:UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("OK", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: Selector("barButtonItemClicked:"));
            return okItem;
        }();
        
        self.tvParams = UITableView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 64.0), style: UITableViewStyle.Plain);
        self.tvParams?.delegate = self;
        self.tvParams?.dataSource = self;
        self.tvParams?.tableFooterView = UIView();
        self.view.addSubview(self.tvParams!);
    }
    
    private func buildCellSended(parentCell:UITableViewCell?)
    {
        guard let cell = parentCell else
        {
            return;
        }
        
        defer
        {
            cell.contentView.addSubview(self.scSCharacterSet!);
            cell.contentView.addSubview(self.swSHexData!);
            self.swSHexData?.on = AYHCMParams.sharedInstance.sHexData;
            self.scSCharacterSet?.hidden = self.swSHexData!.on;
            self.scSCharacterSet?.selectedSegmentIndex = AYHCMParams.sharedInstance.sCharacterSet.rawValue;
        }
        
        guard let _ = self.scSCharacterSet, _ = self.swSHexData else
        {
            self.scSCharacterSet = UISegmentedControl(items: ["GBK", "UTF-8"]);
            self.scSCharacterSet?.frame = CGRectMake(self.view.frame.size.width - 175.0, self.cellRowHeight / 2.0 - 15.0, 115.0, 30.0);
            self.scSCharacterSet?.tag = self.kViewTag + 1;
            self.scSCharacterSet?.addTarget(self, action: Selector("segmentedControlValueChanged:"), forControlEvents: UIControlEvents.ValueChanged);
            
            self.swSHexData = UISwitch(frame: CGRectMake(self.view.frame.size.width - 55.0, self.cellRowHeight / 2.0 - 15.0, 30.0, 30.0));
            self.swSHexData?.tag = self.kViewTag + 3;
            self.swSHexData?.addTarget(self, action: Selector("switchValueChanged:"), forControlEvents: UIControlEvents.ValueChanged);
            return;
        }
    }
    
    private func buildCellReceived(parentCell:UITableViewCell?)
    {
        guard let cell = parentCell else
        {
            return;
        }
        
        defer
        {
            cell.contentView.addSubview(self.scRCharacterSet!);
            cell.contentView.addSubview(self.swRHexData!);
            self.swRHexData?.on = AYHCMParams.sharedInstance.rHexData;
            self.scRCharacterSet?.hidden = self.swRHexData!.on;
            self.scRCharacterSet?.selectedSegmentIndex = AYHCMParams.sharedInstance.rCharacterSet.rawValue;
        }
        
        guard let _ = self.scRCharacterSet, _ = self.swRHexData else
        {
            self.scRCharacterSet = UISegmentedControl(items: ["GBK", "UTF-8"]);
            self.scRCharacterSet?.frame = CGRectMake(self.view.frame.size.width - 175.0, self.cellRowHeight / 2.0 - 15.0, 115.0, 30.0);
            self.scRCharacterSet?.tag = self.kViewTag + 2;
            self.scRCharacterSet?.addTarget(self, action: Selector("segmentedControlValueChanged:"), forControlEvents: UIControlEvents.ValueChanged);
            
            self.swRHexData = UISwitch(frame: CGRectMake(self.view.frame.size.width - 55.0, self.cellRowHeight / 2.0 - 15.0, 30.0, 30.0));
            self.swRHexData?.tag = self.kViewTag + 4;
            self.swRHexData?.addTarget(self, action: Selector("switchValueChanged:"), forControlEvents: UIControlEvents.ValueChanged);
            return;
        }
    }
    
    private func buildCellLocalPort(parentCell:UITableViewCell?)
    {
        guard let cell = parentCell else
        {
            return;
        }
        
        defer
        {
            if (AYHCMParams.sharedInstance.localPort == 0)
            {
                self.tfLocalPort?.text = "";
            }
            else
            {
                self.tfLocalPort?.text = "\(AYHCMParams.sharedInstance.localPort)";
            }
        }
        
        guard let _ = self.tfLocalPort else
        {
            self.tfLocalPort = UITextField(frame: CGRectMake(self.view.frame.size.width - 155.0, 0.0, 150.0, self.cellRowHeight));
            self.tfLocalPort?.placeholder = "1-65535";
            self.tfLocalPort?.clearButtonMode = UITextFieldViewMode.WhileEditing;
            self.tfLocalPort?.keyboardType = UIKeyboardType.NumberPad;
            self.tfLocalPort?.textAlignment = NSTextAlignment.Right;
            self.tfLocalPort?.tag = self.kViewTag + 5;
            self.tfLocalPort?.delegate = self;
            self.tfLocalPort?.addTarget(self, action: Selector("textFieldEditingValueChanged:"), forControlEvents: UIControlEvents.EditingChanged);
            cell.contentView.addSubview(self.tfLocalPort!);
            return;
        }
    }
    
    private func buildCellRemoteIP(parentCell:UITableViewCell?)
    {
        guard let cell = parentCell else
        {
            return;
        }
        
        defer
        {
            self.tfRemoteIP?.text = AYHCMParams.sharedInstance.remoteIP;
        }
        
        guard let _ = self.tfRemoteIP else
        {
            self.tfRemoteIP = UITextField(frame: CGRectMake(self.view.frame.size.width - 155.0, 0.0, 150.0, self.cellRowHeight));
            self.tfRemoteIP?.placeholder = "xxx.xxx.xxx.xxx";
            self.tfRemoteIP?.clearButtonMode = UITextFieldViewMode.WhileEditing;
            self.tfRemoteIP?.keyboardType = UIKeyboardType.DecimalPad;
            self.tfRemoteIP?.textAlignment = NSTextAlignment.Right;
            self.tfRemoteIP?.tag = self.kViewTag + 6;
            self.tfRemoteIP?.delegate = self;
            self.tfRemoteIP?.addTarget(self, action: Selector("textFieldEditingValueChanged:"), forControlEvents: UIControlEvents.EditingChanged);
            cell.contentView.addSubview(self.tfRemoteIP!);
            return;
        }
    }
    
    private func buildCellRemotePort(parentCell:UITableViewCell?)
    {
        guard let cell = parentCell else
        {
            return;
        }
        
        defer
        {
            if (AYHCMParams.sharedInstance.remotePort == 0)
            {
                self.tfRemotePort?.text = "";
            }
            else
            {
                self.tfRemotePort?.text = "\(AYHCMParams.sharedInstance.remotePort)";
            }
        }
        
        guard let _ = self.tfRemotePort else
        {
            self.tfRemotePort = UITextField(frame: CGRectMake(self.view.frame.size.width - 155.0, 0.0, 150.0, self.cellRowHeight));
            self.tfRemotePort?.placeholder = "1-65535";
            self.tfRemotePort?.clearButtonMode = UITextFieldViewMode.WhileEditing;
            self.tfRemotePort?.keyboardType = UIKeyboardType.NumberPad;
            self.tfRemotePort?.textAlignment = NSTextAlignment.Right;
            self.tfRemotePort?.tag = self.kViewTag + 7;
            self.tfRemotePort?.delegate = self;
            self.tfRemotePort?.addTarget(self, action: Selector("textFieldEditingValueChanged:"), forControlEvents: UIControlEvents.EditingChanged);
            cell.contentView.addSubview(self.tfRemotePort!);
            return;
        }
    }
}

// MARK: - UITableView DataSource
extension VCParamsSetting : UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paramsTitles.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifer:String = "Cell";
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifer);
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CellIdentifer);
            cell?.selectionStyle = UITableViewCellSelectionStyle.None;
        }
        
        cell?.textLabel?.text = self.paramsTitles[indexPath.row];
        cell?.textLabel?.font = UIFont.systemFontOfSize(14.0);
        switch (indexPath.row)
        {
        case 0:
            self.buildCellSended(cell);
        case 1:
            self.buildCellReceived(cell);
        case 2:
            if (AYHCMParams.sharedInstance.serviceType == .kCMSTServer)
            {
                self.buildCellLocalPort(cell);
            }
            else
            {
                self.buildCellRemoteIP(cell);
            }
        case 3:
            self.buildCellRemotePort(cell);
        default:
            break;
        }
        return cell!;
    }
}

// MARK: - UITableView Delegate
extension VCParamsSetting : UITableViewDelegate
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellRowHeight;
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true);
    }
}

// MARK: - UITextField Delegate
extension VCParamsSetting : UITextFieldDelegate
{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let index = textField.tag - kViewTag;
        if (index == 5 || index == 7)
        {
            if (range.location >= 5)
            {
                return false;
            }
        }
        else if (index == 6)
        {
            if (range.location >= 15)
            {
                return false;
            }
        }
        return true;
    }
}