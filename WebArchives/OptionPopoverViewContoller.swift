//
//  OptionPopoverViewContoller.swift
//  WebArchives
//
//  Created by Yuumi Yoshida on 2019/02/09.
//  Copyright © 2019年 Yuumi Yoshida. All rights reserved.
//

import UIKit

class OptionPopoverViewContoller: UITableViewController {
    let orderColumns = ["created_at", "title"]
    let orderDirections = ["ASC", "DESC"]
    let categories = ["ALL", "記事", "Code", "Art", "Wine"]
    var option = ArticleQueryOption()

    @IBOutlet weak var doneButton: UIBarButtonItem!

    @IBAction func pushCancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Category"
        case 1:
            return "Order by"
        case 2:
            return ""
        default:
            return nil
        }
     }
    
    override  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return categories.count
        case 1:
            return orderColumns.count
        case 2:
            return orderDirections.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        cell.accessoryType = .none
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = categories[indexPath.row]
            if option.category != nil && categories[indexPath.row] == option.category {
                cell.accessoryType = .checkmark
            }
        case 1:
            cell.textLabel!.text = orderColumns[indexPath.row]
            if option.orderColumn != nil && orderColumns[indexPath.row] == option.orderColumn {
                cell.accessoryType = .checkmark
            }
        case 2:
            cell.textLabel!.text = orderDirections[indexPath.row]
            if let descending = option.orderDescending, descending ?  indexPath.row == 1 : indexPath.row == 0 {
                cell.accessoryType = .checkmark
            }
         default:
            cell.textLabel!.text = "???"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            option.category = categories[indexPath.row]
         case 1:
            option.orderColumn = orderColumns[indexPath.row]
         case 2:
            option.orderDescending = indexPath.row == 1
        default:
            print("???")
        }
        doneButton.isEnabled = option.isFilled()
        tableView.reloadData()
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.isEnabled = option.isFilled()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

