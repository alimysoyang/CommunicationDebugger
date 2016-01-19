//
//  AYHButton.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

class AYHButton: UIButton 
{
    // MARK: - properties
    private let defaultBackgroundColor:UIColor = UIColor(red: 49.0 / 255.0, green: 182.0 / 255.0, blue: 9.0 / 255.0, alpha: 1.0);
    private let disabledBackgroundColor:UIColor = UIColor(red: 91.0 / 255.0, green: 213.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0);
    private let titleDefaultColor:UIColor = UIColor.whiteColor();
    private let titleDisabledColor:UIColor = UIColor(red: 150.0 / 255.0, green: 230.0 / 255.0, blue: 146.0 / 255.0, alpha: 1.0);
    private let titleHighlightedColor:UIColor = UIColor(red: 85.0 / 255.0, green: 197.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0);
    private let borderDefaultColor:UIColor = UIColor(red: 39.0 / 255.0, green: 144.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0);
    private let borderDisabledColor:UIColor = UIColor(red: 102.0 / 255.0, green: 188.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0);
    private let borderHighlightedColor:UIColor = UIColor(red: 34.0 / 255.0, green: 128.0 / 255.0, blue: 18.0 / 255.0, alpha: 1.0);
    private let touchLayerBackgroundColor:UIColor = UIColor(red: 43.0 / 255.0, green: 160.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0);
    
    private var touchLayer:CALayer?;
    
    override var enabled:Bool {
        didSet {
            if enabled
            {
                self.backgroundColor = self.defaultBackgroundColor;
                self.layer.borderColor = self.borderDefaultColor.CGColor;
            }
            else
            {
                self.backgroundColor = self.disabledBackgroundColor;
                self.layer.borderColor = self.borderDisabledColor.CGColor;
            }
        }
    }
    
    // MARK: - life cycle
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 1.0;
        self.enabled = false;
        
        self.setTitleColor(self.titleDefaultColor, forState: UIControlState.Normal);
        self.setTitleColor(self.titleDisabledColor, forState: UIControlState.Disabled);
        self.setTitleColor(self.titleHighlightedColor, forState: UIControlState.Highlighted);
        
        self.touchLayer = CALayer();
        self.touchLayer?.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        self.touchLayer?.cornerRadius = 5.0;
        self.touchLayer?.backgroundColor = self.touchLayerBackgroundColor.CGColor;
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event);
        self.interfaceHighlighted();
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event);
        self.interfaceNormal();
    }
    
    // MARK: - private methods
    private func interfaceNormal()
    {
        self.layer.borderColor = self.borderDefaultColor.CGColor;
        self.touchLayer?.removeFromSuperlayer();
    }
    
    private func interfaceHighlighted()
    {
        self.layer.borderColor = self.borderHighlightedColor.CGColor;
        self.layer.addSublayer(self.touchLayer!);
        self.bringSubviewToFront(self.titleLabel!);
    }

}