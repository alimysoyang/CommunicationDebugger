//
//  VCOpenSourceLibraries.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 16/1/7.
//  Copyright © 2016年 alimysoyang. All rights reserved.
//

import UIKit
import Foundation

class VCOpenSourceLibraries: VCAYHBase 
{

    /*
    MBProgressHUD
    Copyright (c) 2009-2015 Matej Bukovinski
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.*/
    
    /*
    The MIT License (MIT)
    
    Copyright (c) 2015 Ryan Fowler
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    */
    
    
    // MARK: - property 属性
    
    private var dataTableView:UITableView?;
    private let librariesNames:[String] = ["MBProgressHUD", "CocoaAsyncSocket", "SSASwiftReachability", "SwiftData"];
    private let librariesUrlPath:[String] = ["https://github.com/jdg/MBProgressHUD", "https://github.com/robbiehanson/CocoaAsyncSocket", "https://github.com/SSA111/SSASwiftReachability", "https://github.com/ryanfowler/SwiftData"];
    
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

    // MARK: - public methods
    
    // MARK: - private methods
    private func initViews()
    {
        self.title = NSLocalizedString("OpenSource", comment: "");
        
        self.dataTableView = UITableView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 64.0), style: UITableViewStyle.Plain);
        self.dataTableView?.delegate = self;
        self.dataTableView?.dataSource = self;
        self.dataTableView?.tableFooterView = UIView();
        self.view.addSubview(self.dataTableView!);
    }
}

// MARK: - UITableView DataSource
extension VCOpenSourceLibraries : UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.librariesNames.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifer:String = "Cell";
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifer);
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifer);
            
        }
        
        cell?.textLabel?.font = UIFont.boldSystemFontOfSize(20);
        cell?.textLabel?.text = self.librariesNames[indexPath.row];
        cell?.detailTextLabel?.font = UIFont.systemFontOfSize(14);
        cell?.detailTextLabel?.textColor = UIColor.grayColor();
        cell?.detailTextLabel?.text = self.librariesUrlPath[indexPath.row];
        cell?.detailTextLabel?.numberOfLines = 2;
        cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        UIApplication.sharedApplication().openURL(NSURL(string: self.librariesUrlPath[indexPath.row])!);
    }
}

// MARK: - UITableView Delegate
extension VCOpenSourceLibraries : UITableViewDelegate
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0;
    }
}