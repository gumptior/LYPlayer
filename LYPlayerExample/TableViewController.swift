//
//  TableViewController.swift
//  LYPlayerExample
//
//  Created by LY_Coder on 2017/11/28.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

        let dataList = ["http://ow41vz64v.bkt.clouddn.com/G.E.M.%E9%82%93%E7%B4%AB%E6%A3%8B%20-%20%E6%A1%83%E8%8A%B1%E8%AF%BA.mp4", "http://ow41vz64v.bkt.clouddn.com/%E8%96%9B%E4%B9%8B%E8%B0%A6%20-%20%E6%84%8F%E5%A4%96.mp4", "http://ow41vz64v.bkt.clouddn.com/%E8%B5%B5%E9%9B%B7%20-%20%E6%88%91%E4%BB%AC%E7%9A%84%E6%97%B6%E5%85%89.mp4", "http://ow41vz64v.bkt.clouddn.com/%E8%B0%A2%E6%98%A5%E8%8A%B1%20-%20%E5%80%9F%E6%88%91.mp4", "http://ow41vz64v.bkt.clouddn.com/Justin%20Timberlake%20-%20Five%20Hundred%20Miles.mp4", "http://ow41vz64v.bkt.clouddn.com/DJ%20Daniel%20Kim%20-%20Pop%20Danthology%202012.mp4", "http://ow41vz64v.bkt.clouddn.com/%E8%B5%B5%E6%96%B9%E5%A9%A7%20-%20%E5%B0%BD%E5%A4%B4%20.mp4", "http://ow41vz64v.bkt.clouddn.com/%E5%A4%A7%E5%A3%AE%20-%20%E6%88%91%E4%BB%AC%E4%B8%8D%E4%B8%80%E6%A0%B7.mp4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 230
    }



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        
        cell.backgroundColor = UIColor.red

        cell.urlString = dataList[indexPath.row]

        return cell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
