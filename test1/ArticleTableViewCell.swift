//
//  ArticleTableViewCell.swift
//  test1
//
//  Created by ShuichiNagao on 8/11/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var user: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bindDataCell(_ article: Article) {
        // 引数にArticleオブジェクトを受け取って、cellの作成を行います.
        self.title.text = article.title
        self.date.text = String(article.modified)
        self.desc.text = article.body
        self.user.text = article.userData.userName
        if let thumbnail: String = article.thumb {
            if let data = try? Data(contentsOf: URL(string: thumbnail)!) {
                self.thumbnail.image = UIImage(data: data)
            }
        }
    }
    
}

