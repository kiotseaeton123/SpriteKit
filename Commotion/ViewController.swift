//
//  ViewController.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import CoreMotion

extension Date{
    var yesterday: Date{
        return Calendar.current.date(byAdding:.day, value: -1, to: self)!
    }
    var midnight:Date{
        let cal = Calendar(identifier: .gregorian)
        return cal.startOfDay(for: self)
    }
}

class ViewController: UIViewController {
    
    let goalSteps: Float = 1000.0
    //MARK: class variables
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.circularView.value=newtotalSteps
                self.stepsLabel.text = "Steps: \(newtotalSteps)/\(self.goalSteps)"
                
                if(self.totalSteps >= self.goalSteps){
                    self.playButton.isEnabled = true
                }
            }
        }
    }
    
    //MARK: UI Elements
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var isWalking: UILabel!
    @IBOutlet weak var playButton: UIButton!

    
    @IBOutlet weak var circularView: RRCircularView!
    
    //MARK: View Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playButton.isEnabled = true
        
        self.playButton.setTitleColor(UIColor.gray, for: .disabled)
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        circularView.arrowImageView.image = UIImage(imageLiteralResourceName: "gren_round_arrow")
        circularView.globImageView.image = UIImage(imageLiteralResourceName: "gren_round")
        circularView.ringImageView.image = UIImage(imageLiteralResourceName: "round_color")
        circularView.dotImageView.image = UIImage(imageLiteralResourceName: "black_dot")
        circularView.tintColorImage = UIImage(imageLiteralResourceName: "gradient")
 
        
        circularView.minimumValue = 0
        circularView.maximumValue = Double(goalSteps)
        
        circularView.value = totalSteps
        
    }
    
    
    // MARK: Raw Motion Functions
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        // TODO: should we be doing this from the MAIN queue? You may need to fix that!  ...
        if self.motion.isDeviceMotionAvailable{
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main,
                                                 withHandler: handleMotion)
        }
    }
    
    // Raw motion handler, update a label
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){

    }
    
    // MARK: Activity Functions
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
            
        }
        
    }
    
    // activity function handler, display activity in label
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            DispatchQueue.main.async{
                self.isWalking.text = "Walking: \(unwrappedActivity.walking)\n Still: \(unwrappedActivity.stationary)\n Running: \(unwrappedActivity.running)\n Cycling: \(unwrappedActivity.cycling)\n Driving: \(unwrappedActivity.automotive)\n"
                
            }
        }
    }
    
    // MARK: Pedometer Functions
    func startPedometerMonitoring(){
        
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date().midnight,withHandler: self.handlePedometer )
        }
    }
    
    //ped handler, show steps on slider
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?){
        if let steps = pedData?.numberOfSteps {
            self.totalSteps = steps.floatValue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GameViewController{
            let gameViewController = segue.destination as? GameViewController
            gameViewController?.stepCount = self.totalSteps
            gameViewController?.goalSteps = self.goalSteps
        }
    }
    
    
}

