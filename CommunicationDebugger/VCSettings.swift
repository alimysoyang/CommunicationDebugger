//
//  VCSettings.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/12/7.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import UIKit
import Foundation

@objc protocol  VCSettingsDelegate
{
    func settingsDidStartClearCache();
    func settingsDidEndClearCache();
}


class VCSettings: VCAYHBase
{
    // MARK: - property 属性
    weak var delegate:VCSettingsDelegate?;
    private let appstorepath:String = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=682270868";
    private let group0Titles:[String] = [NSLocalizedString("ClearCache", comment: ""), NSLocalizedString("SaveLogs", comment: "")];
    private let group1Titles:[String] = [NSLocalizedString("Version", comment: ""), NSLocalizedString("Email", comment: ""), NSLocalizedString("About", comment: "")];
    private let group2Titles:[String] = [NSLocalizedString("OpenSource", comment: "")];
    
    private var settingsTableView:UITableView?;
    private var swSaveLogs:UISwitch?;
    
    // MARK: - life cycle ViewController生命周期
    override func viewDidLoad() {
        super.viewDidLoad();
        self.initViews();
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - event response
    internal func switchValueChanged(sender:UISwitch)
    {
        AYHParams.sharedInstance.isSaveLogs = sender.on;
        AYHParams.sharedInstance.toSave();
    }
    
    // MARK: - public methods
    
    // MARK: - private methods
    private func initViews()
    {
        self.title = NSLocalizedString("Settings", comment: "");
        
        self.settingsTableView = UITableView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 64.0), style: UITableViewStyle.Grouped);
        self.settingsTableView?.delegate = self;
        self.settingsTableView?.dataSource = self;
        self.view.addSubview(self.settingsTableView!);
    }
    
    private func buildCellSaveLogs(parentCell:UITableViewCell?)
    {
        guard let cell = parentCell else
        {
            return;
        }
        
        defer
        {
            cell.contentView.addSubview(self.swSaveLogs!);
        }
        
        guard let _ = self.swSaveLogs else
        {
            self.swSaveLogs = UISwitch(frame: CGRectMake(self.view.frame.size.width - 55.0, 6.0, 30.0, 30.0));
            self.swSaveLogs?.on = AYHParams.sharedInstance.isSaveLogs;
            self.swSaveLogs?.addTarget(self, action: Selector("switchValueChanged:"), forControlEvents: UIControlEvents.ValueChanged);
            return;
        }
    }
    
    private func removeFile(filePath:String)
    {
        var isDir:ObjCBool = ObjCBool(true);
        let fm:NSFileManager = NSFileManager();
        if (fm.fileExistsAtPath(filePath, isDirectory: &isDir))
        {
            if (isDir.boolValue)
            {
                do
                {
                    let files:[String] = try fm.contentsOfDirectoryAtPath(filePath);
                    for file in files
                    {
                        self.removeFile(String(format: "%@/%@", filePath, file));
                    }
                } catch let error as NSError
                {
                    debugPrint(error);
                }
            }
            else
            {
                do
                {
                    try fm.removeItemAtPath(filePath);
                } catch let error as NSError
                {
                    debugPrint(error);
                }
            }
        }
    }
    
    private func removeAllCacheFiles()
    {
        let cachePath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0];
        self.removeFile(cachePath);
    }
    
    private func clearCache()
    {
        self.delegate?.settingsDidStartClearCache();
        self.view.showLoadAlert("\(NSLocalizedString("ClearCache", comment: ""))...");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            AYHDBHelper.sharedInstance.deleteDbFile();
            self.removeAllCacheFiles();
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.hideLoadAlert();
                self.view.alert(NSLocalizedString("Cleanup", comment: ""), alertType: UIView.AlertViewType.kAVTSuccess);
                guard let _ = self.delegate?.settingsDidEndClearCache() else
                {
                    return;
                }
            });
        });
    }
}

// MARK: - UITableView DataSource
extension VCSettings : UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0)
        {
            return self.group0Titles.count;
        }
        else if (section == 1)
        {
            return self.group1Titles.count;
        }
        return self.group2Titles.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifer:String = "Cell";
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifer);
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CellIdentifer);
            
        }
        
        if (indexPath.section == 0)
        {
            cell?.textLabel?.text = self.group0Titles[indexPath.row];
            if (indexPath.row == 1)
            {
                cell?.selectionStyle = UITableViewCellSelectionStyle.None;
                self.buildCellSaveLogs(cell);
            }
        }
        else if (indexPath.section == 1)
        {
            cell?.textLabel?.text = self.group1Titles[indexPath.row];
            switch (indexPath.row)
            {
            case 0:
                cell?.detailTextLabel?.text = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String;
            case 1:
                cell?.detailTextLabel?.text = "alimyso@gmail.com";
            default:
                break;
            }
        }
        else
        {
            cell?.textLabel?.text = self.group2Titles[indexPath.row];
        }
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                let alertController:AYHAlertViewController = AYHAlertViewController(title: NSLocalizedString("Information", comment: ""), message: NSLocalizedString("DeleteMessage", comment: ""), delegate: self, parentController: self, buttonTitles: NSLocalizedString("OK", comment: ""), NSLocalizedString("Cancel", comment: ""));
                alertController.showView();
            }
        }
        else if (indexPath.section == 1)
        {
            switch (indexPath.row)
            {
            case 0:
                UIApplication.sharedApplication().openURL(NSURL(string: self.appstorepath)!);
            case 1:
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:alimyso@gmail.com")!);
            case 2:
                let helpViewController:VCAppHelp = VCAppHelp();
                self.navigationController?.pushViewController(helpViewController, animated: true);
            default:
                break;
            }
        }
        else
        {
            let openSourceLibrariesViewController:VCOpenSourceLibraries = VCOpenSourceLibraries();
            self.navigationController?.pushViewController(openSourceLibrariesViewController, animated: true);
        }
    }
}

// MARK: - UITableView Delegate
extension VCSettings : UITableViewDelegate
{
    
}

extension VCSettings : AYHAlertViewControllerDelegate
{
    func alertController(alertController: AYHAlertViewController, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0)
        {
            self.clearCache();
        }
    }
}