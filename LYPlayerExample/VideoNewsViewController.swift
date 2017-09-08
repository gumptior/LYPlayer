//
//  VideoNewsViewController.swift
//  LYPlayerExample
//
//  Created by LY_Coder on 2017/9/6.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class VideoNewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension VideoNewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VideoNewsCell.cellWithTableView(tableView: tableView)
        
        return cell
    }
}

extension VideoNewsViewController: UITableViewDelegate {
    
}



