//
//  MasterViewController.swift
//  WebArchives
//
//  Created by Yuumi Yoshida on 2019/02/01.
//  Copyright © 2019年 Yuumi Yoshida. All rights reserved.
//

import UIKit
import Firebase


class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    let backend = Backend()
    var articles:[DocumentSnapshot] = []
    var queryOption = ArticleQueryOption()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 80.0;
        tableView.rowHeight = 80.0;
        
        // Do any additional setup after loading the view, typically from a nib.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        NotificationCenter.default.addObserver(forName: .riseArchive, object: nil, queue: OperationQueue.main, using: { notification in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let archiveViewController = storyboard.instantiateViewController(withIdentifier: "ArchiveViewControllerID") as!  ArchiveViewController
            archiveViewController.urlString = notification.object as? String
            self.present(archiveViewController, animated: true, completion: nil)
        })

        backend.authorize(self) {
        }
        queryOption.category = "記事"
        queryOption.orderColumn = "created_at"
        queryOption.orderDescending = true
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadArticles()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = articles[indexPath.row].data()
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                splitViewController?.preferredDisplayMode = UIDevice.current.orientation.isLandscape ? .allVisible : .primaryHidden
            }
        }
    }

    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        if let popover = segue.source as? OptionPopoverViewContoller {
            self.queryOption = popover.option
            reloadArticles()
        }
    }

    @IBAction func pushOptionButton(_ sender: Any) {
        let popover = self.storyboard!.instantiateViewController(withIdentifier: "OptionPopover") as! OptionPopoverViewContoller
        popover.option = self.queryOption
        popover.modalPresentationStyle = .formSheet
        self.present(popover, animated: true)
    }

    @IBAction func pushMenuButton(_ sender: Any) {
        let action = UIAlertController(title: nil, message: nil, preferredStyle:  .actionSheet)
        action.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
            self.backend.logout()
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        action.popoverPresentationController?.sourceView = self.view
        action.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        self.present(action, animated: true)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCellID", for: indexPath) as! ArticleTableViewCell
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm"

        let article = articles[indexPath.row].data()
        cell.titleleLabel!.text  = article?["title"] as? String
        cell.datetimeLabel!.text =  dateFormat.string(from: article?["created_at"] as! Date)
        if let thumb = article!["thumb"] {
            cell.thumbImageView!.contentMode = .scaleAspectFit
            cell.thumbImageView!.image = UIImage(data: thumb as! Data)
        }
        return cell
    }

    private func reloadArticles() {
        backend.queryArticles(option: queryOption, complete:{ (articles) in
            self.articles = articles
            self.tableView.reloadData()
        })
    }
}

