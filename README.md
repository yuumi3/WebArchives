# WebArchive

## Description

気になったWebページを保存するアプリです

- App Extention (Safariプラグイン)でアクション(共有)・ボタンから表示中の画面を取り込めます
- iOSアプリは取り込んだ画面のリストとPDF化されたWebページ情報を見ることが出来ます
- 取り込むWebページはカテゴリー(分類)で分類できます
- 一覧情報はカテゴリーや表示順を指定できます
- 一覧、PDF情報は [Firebase](https://firebase.google.com/)に格納されます

![WebArchive](https://www.ey-office.com/images/web_archives.png)

## Build

* Firebase にアカウントを作る必用があります
* Firebaseの情報  **GoogleService-Info.plist** をプロジェクトに追加する必用があります、詳細は https://firebase.google.com/docs/ios/setup
* FirebaseのSDK(ライブライー)はCocoaPodsで提供されています `pod install` して下さい
* ユーザー認証は Googleを使用しています、プロジェクトにURL スキームを登録する必要があります、詳細は https://firebase.google.com/docs/auth/ios/google-signin
* プロジェクトにはiOSアプリの *WebArichive* とApp Extentionの  *ArchiveExtention* の２つのターゲットがあります、両方ともBuild・Runして下さい




## License

[MIT License](http://www.opensource.org/licenses/MIT).