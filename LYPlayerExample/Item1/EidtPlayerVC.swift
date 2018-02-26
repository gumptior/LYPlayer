//
//  EidtPlayerVC.swift
//  LYPlayerExample
//
//  Created by LY_Coder on 2018/2/26.
//  Copyright © 2018年 LYCoder. All rights reserved.
//

import UIKit

class EidtPlayerVC: UIViewController {
    
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    
    @IBOutlet weak var recoveryPlaySwitch: UISwitch!
    
    @IBOutlet weak var rateStepper: UIStepper! {
        didSet {
            rateStepper.addTarget(self, action: #selector(rateStepperAction), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var rateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! NormalPlayerVC
        vc.isAutoPlay = autoPlaySwitch.isOn
        vc.isRecoveryPlay = recoveryPlaySwitch.isOn
        vc.rate = Float(rateStepper.value)
        
    }
    
    func rateStepperAction() {
        rateLabel.text = "\(rateStepper.value)"
    }

}
