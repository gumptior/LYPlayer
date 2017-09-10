//
//  VideoNewsCell.swift
//  LYPlayerExample
//
//  Created by LY_Coder on 2017/9/6.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class VideoNewsCell: UITableViewCell {
    
    
    static var cellIdentifier = "VideoNewsCellIdentifier"
    
    /** 初始化方法 */
    static func cellWithTableView(tableView: UITableView) -> VideoNewsCell {
        var cell: VideoNewsCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? VideoNewsCell
        
        if cell == nil {
            cell = VideoNewsCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        return cell!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).offset(-10)
            make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    lazy var playerView: LYPlayerView = {
        let playerView = LYPlayerView(url: URL(string: "123456")!)
        
        return playerView
    }()

}
