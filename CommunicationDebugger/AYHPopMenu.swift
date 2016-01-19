//
//  AYHPopMenu.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/12/4.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

typealias completionClosure = ()->Void;

@objc protocol AYHPopMenuDelegate
{
    func popMenu(popMenu:AYHPopMenu, selectedIndex index:Int);
}

//暂不提供编辑功能
class AYHPopMenu: UIView 
{
    // MARK: - properties
    weak var delegate:AYHPopMenuDelegate?;
    private let menuTitles:[String] = [NSLocalizedString("Reset", comment: ""), NSLocalizedString("Settings", comment: "")];//[NSLocalizedString("Edit", comment: ""), NSLocalizedString("Reset", comment: ""), NSLocalizedString("Settings", comment: "")];
    private var menuTableView:UITableView?;
    
    // MARK: - life cycle
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        self.initViews();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
	
    deinit
    {
        delegate = nil;
    }

    // MARK: - public methods
    func animationClose(completion:completionClosure?)
    {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.alpha = 0.0;
            }, completion:{ (finished:Bool) -> Void in
                self.removeFromSuperview();
                if let _ = completion
                {
                    completion!();
                }
        });
    }
    
    // MARK: - event response

    // MARK: - delegate

    // MARK: - private methods
    private func initViews()
    {
        let bgView:UIImageView = UIImageView(image: UIImage(named: "MoreFunctionFrame")!.stretchableImageWithLeftCapWidth(10, topCapHeight: 20));
        bgView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        self.addSubview(bgView);
        
        self.menuTableView = UITableView(frame: CGRectMake(6.0, 13.0, self.frame.size.width - 12.0, self.frame.size.height - 20.0), style: UITableViewStyle.Plain);
        self.menuTableView?.backgroundColor = UIColor.clearColor();
        self.menuTableView?.dataSource = self;
        self.menuTableView?.delegate = self;
        self.menuTableView?.scrollEnabled = false;
        self.menuTableView?.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.addSubview(self.menuTableView!);
    }
}

// MARK: - UITableView DataSource
extension AYHPopMenu:UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuTitles.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifer:String = "Cell";
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifer);
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifer);
            cell?.backgroundColor = UIColor.clearColor();
            let selectedView:UIView = UIView();
            selectedView.backgroundColor = UIColor(white: 0.0, alpha: 0.2);
            cell?.selectedBackgroundView = selectedView;
        }
        
        cell?.textLabel?.font = AYHelper.p15Font;
        cell?.textLabel?.textColor = UIColor.whiteColor();
        cell?.textLabel?.textAlignment = NSTextAlignment.Center;
        cell?.textLabel?.text = self.menuTitles[indexPath.row];
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        self.animationClose(nil);
        guard let _ = self.delegate?.popMenu(self, selectedIndex: indexPath.row) else
        {
            return;
        }
    }
}

// MARK: - UITableView Delegate
extension AYHPopMenu:UITableViewDelegate
{
    
}
