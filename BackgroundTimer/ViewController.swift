//
//  ViewController.swift
//  BackgroundTimer
//
//  Created by Talka_Ying on 2017/5/9.
//  Copyright © 2017年 Talka_Ying. All rights reserved.
//

import UIKit

enum Background_Code_Mode : Int {
    case Normal = 0         //both not working
    case NormalAddRunloop   //both not working
    case Runloop            //working but recursive will crash
    case DispatchAfter
}

class ViewController: UIViewController {

    let interval = 0.1
    
    @IBOutlet var normalButton:UIButton?
    @IBOutlet var normalAddRunloopBuuton:UIButton?
    @IBOutlet var runloopButton:UIButton?
    @IBOutlet var dispatchAfterButton:UIButton?
    @IBOutlet var segmentedControl:UISegmentedControl?
    @IBOutlet var label:UILabel?
    
    var mode:Background_Code_Mode = .Normal
    var run:Bool = true
    var callSelf:Bool = true

    @IBAction func buttonClicked(_ sender:UIButton) {
    
        mode = Background_Code_Mode(rawValue: sender.tag)!
    
        self.reset()
        
        self.performSelector(inBackground: #selector(self.backgroundFunction(_:)), with: "0")
        
    }
    
    @IBAction func segmentedControlClicked(_ sender:UISegmentedControl) {
    
        self.reset()
        
        if sender.selectedSegmentIndex == 0 {
            callSelf = true
        }
        else {
            callSelf = false
        }
    }
    
    func reset() {
        
        run = false
        Thread.sleep(forTimeInterval: 2 * interval)
        run = true
        DispatchQueue.main.async {
            self.label?.text = "?"
        }
    }
    
    func backgroundFunction(_ value:String) {
        
        var selector:Selector?
        var valueStr:String = String( Int(value)!+1 )
        var delayTime:Double = 0
        
        if callSelf {
            selector = #selector(self.backgroundFunction(_:))
            delayTime = interval
            
            DispatchQueue.main.async {
                self.label?.text = value
            }
        }
        else {
            selector = #selector(self.theOtherFunction(_:))
        }
        
        while (run) {
            
            switch mode {
            case Background_Code_Mode.Normal:
                
                self.perform(selector!, with: valueStr, afterDelay: delayTime)
                
                break
                
            case Background_Code_Mode.NormalAddRunloop:
                
                RunLoop.current.add(Port(), forMode: .commonModes)
                self.perform(selector!, with: valueStr, afterDelay: delayTime, inModes: [RunLoopMode.commonModes])
                
                break
            
            case Background_Code_Mode.Runloop:
                
                self.perform(selector!, with: valueStr, afterDelay: delayTime)
                RunLoop.current.run()
                
                break
                
            case Background_Code_Mode.DispatchAfter:

                DispatchQueue.global().asyncAfter(deadline: .now()+delayTime, execute: {
                    self.perform(selector!, with: valueStr)
                })
                break
            }
            
            if callSelf {
                break
            }
            else {
                Thread.sleep(forTimeInterval: interval)
                valueStr = String( Int(valueStr)!+1 )
            }
        }
    }

    func theOtherFunction(_ value:String) {
        
        DispatchQueue.main.async {
            self.label?.text = value
        }
    }
    
}

