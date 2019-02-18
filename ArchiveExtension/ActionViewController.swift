//
//  ActionViewController.swift
//  ArchiveExtension
//
//  Created by Yuumi Yoshida on 2019/02/01.
//  Copyright © 2019年 Yuumi Yoshida. All rights reserved.
//

import UIKit
import WebKit
import MobileCoreServices


class ActionViewController: UIViewController, WKNavigationDelegate {
    private var webViewURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 200, height: 100)
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first,
            itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (itemUrl, error) in
                if let url = itemUrl as? URL {
                    self.webViewURL = url.absoluteString
                 }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let webURL = self.webViewURL {
            let url = "com.ey-office.apps://web-archives/\(webURL)"
            if !openURL(URL(string: url)!) {
                print("-- Can't invoke \(url)")
            }
        }
        self.extensionContext?.completeRequest(returningItems: self.extensionContext?.inputItems, completionHandler: nil)
     }
    
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
 
}
