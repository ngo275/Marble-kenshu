# Marble-kenshu MARBLEのdemo作成

*コード自体はSwift3に対応させました。Carthageをインストールしないと動かないかもしれません。ライブラリのバージョンが違っていて動かない場合は聞いてください。見られているのかわからないので研修の際はforkかstarをしてくれるとこっちも助かります。*

## Swiftでアプリ開発（キュレーションアプリを作成してみます）
プログラミング言語 Swift で iOS アプリを作ります。iOS アプリは Apple が整備する`Cocoa touch`と呼ばれるフレームワーク群を利用して構成されています。`Cocoa touch`の主要なフレームワークは`Foundation`と`UIKit`です。`Foundation `は文字列やコレクションといった基本的なクラスから、並行処理やネットワーク処理のためのクラスまで基本的なツールが揃っています。`UIKit`はiOS のGUIフレームワークであり、アプリケーションを構成するための重要な機能のほとんどを担っています。

## アーキテクチャにはMVVMを採用
### Model
アプリケーションで持つべきデータに関して定義をします。ここではキュレーションアプリを作成するので、記事（`Article`）やユーザー（`User`）等のデータ構造を定義します。
### ViewController
ViewControllerはUIViewControllerを継承しており、あるViewを管理し、タップなどのイベントを検知して制御しています。基本的にViewModel等のメソッド呼び出しを行い、Viewの描画に専念しましょう。viewDidLoadに詰め込みすぎないようにfunctionの切り出しやプロトコルの利用をしていくように心がけましょう。
### ViewModel
データの加工を行います。**引数をもらって加工した結果を返す**という役割に終始させることを意識しましょう。なるべくプロパティを持たないようさせます。もしプロパティを持つことがあったとしても、関数の実行中にそのプロパティを更新するようなことは避けましょう。これを**副作用**と言います。
*MIMIではクリーンアーキテクチャを採用して実装中です。それに加えてRxSwiftの利用もされています。*
    
    
    
## 以下キュレーション（MARBLE）のクライアントアプリ作成のチュートリアル


## プロジェクト作成
Xcodeの新規プロジェクトで、`Single View Application`を選択してプロジェクト名を入力します。ここではtest1というプロジェクト名にしてあります。プロジェクトの中身はフォルダを作成してわかりやすく構成しましょう。新しくフォルダを追加するには以下の画面のように右クリックから`New Group`を作成するところから行います。

![フォルダーの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/1.png)

ディレクトリ構成は以下のようにします。

![ディレクトリ構成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/2.png)

Storyboardは一つのファイルに詰め込むとチームで開発しているとコンフリクトの嵐になってしまうので、１つのページにつき1つのStoryboardになるように分割していきます。Storyboardファイルの作成は以下のようにします。

![Storyboardの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/4.png)

記事一覧ページはTableViewを利用して表示しますが、Cellは、コードで生成せずに、自分でGUIを利用して作成します。Viewパーツ用のファイル（これをXib（ニブ）ファイルと呼びます）にカスタムビューを作成していきます。Xibファイルは以下の画面から作成します。基本的なファイルの拡張子は.swiftになるのですが、Storyboardの拡張子は`.storyboard`、Xibファイルの拡張子は`.xib`になります。`.plist`という拡張子を持つものはプロジェクトに関する設定を記述しているものです。ATSなどの設定でいじることになるでしょう。AppleはHTTP通信に関して厳しく規制を始めており、HTTP通信を許可する設定をATSという欄をいじって行います。

![xibファイルの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/3.png)

## Storyboardで準備

まず、記事一覧ページを表示できるところまでを目安に進めていきます。StoryboardとArticleViewControllerを関連付けて、`Editor -> Embed in -> Navigation Controller`で`NavigationController`をつけます。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/5.png)

`ArticleViewController`に`TableView`を挿入します。`TableViewController`を利用しても良いのですが、`ViewController`に`TableView`を入れてテーブルを作成したほうがカスタムしやすいので、`ArticleViewController`に`TableView`を挿入する形式にします。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/6.png)

次に`TableView`を画面全体に引き伸ばします。右下でConstraintの設定をしていきます。上下左右を0にして`Add 4 Constraints`としましょう。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/7.png)

今のでConstraintsは変更されました。しかし、現状の`TableView`とサイズや位置（Frames）とのずれが生じているので`Update Frames`で`TableView`の制約条件を更新しましょう。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/8.png)

こうすると、画面いっぱいに`TableView`が広がるのですが、左右にマージンが残っています。これを消していきましょう。左端直線を選択して`、SecondItem`の`Relative to margin`、右端は`FirstItem`の`Relative to margin`のチェックを外します。左右のマージンが消えればOKです。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/9.png)

TableViewCellを入れます。

![TableViewCellの追加](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/10.png)

同様に上部にマージンが残るので、`Ajust Scroll ...`のチェックを外します。（画像は外す前です）

![TableViewの上部のマージン削除](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/11.png)

Cellとそれに対応するファイルの関連付けを行っておきましょう。

![関連付け](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/12.png)

次に`TableView`のDelegateの設定も以下の画面のように行っておきます。Delegateは'移譲'と言って、異なるクラス（ファイル）間等でメソッドをまたいで使いたい時に利用します。例えばTableViewCellのファイルにはタップした時に起こるアクションを記述できるけども、Articleに関するデータをそのCellのファイルは持っていないかもしれないことがあります。

移譲というとわかりにくいかもしれませんが、簡単に言いますと、自分だけでは（例えば使いたいプロパティを持っていないから）実装できないので、やってほしいことを宣言するから、その実装を頼みます、と他の場所に頼んでいるという風に思っておけば良いでしょう。頼む側を移譲元、頼まれる側を移譲先と言います。例えば`UITableViewDelegate`は移譲先が`ArticleViewController`です。`ArticleViewController`は、頼まれたからやってやるぜ、という宣言をしないといけないのですが、それが調べているとよく見かける以下のコードです。

```swift
tableView.delegate = self
tableView.dataSource = self
```

今回はそれをStoryboardで設定しています。頼まれた側（移譲先）は自分で頼まれた内容を実装しないといけません。

![TableViewのDelegateの設定](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/13.png)

`tableView`という変数を`ArticleViewController`に追加します。

![TableViewという変数をArticleViewControllerに追加](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/18.png)


## TableViewCellの作成

先ほど作成した`ArticleTableViewCell.xib`ファイルを開いてそこに`TableViewCell`を挿入します。この中に記事一覧のセルに必要なものを挿入します。Image Viewとlabelで作っていきます。Constraintsの設定をしていきます。UIImageViewのサイズを*80×80*にして上、左からの位置（offset）を8にしておきます。タイトルや日付もそれぞれの間隔を8にして設定していきます。AutoLayoutまわりの[これ](http://qiita.com/kinopontas/items/d08f84dbb711c5acbe28)を参考にしてください。

![TableViewCellの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/14.png)

`ArticleTableViewCell`の関連付けやIdentifierの設定を行います。

![関連付け](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/15.png)

![関連付け](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/16.png)

`ArticleTableViewCell.swift`とUIView（Cellには入っているViewパーツ）の関連付けをしていきます。ここで、ArticleTableViewCellに入っているViewパーツに`thumbnail`や`title`、`desc`、`date`という名前の変数を作成します。コントロールを押しながらViewパーツをドラッグして`ArticleTableViewCell.swift`と繋ぎましょう。2画面にするにはXcodeの右上にある2つの円が重なっているマークをクリックします。
![２画面にする方法](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/24.png)


```swift
@IBOutlet weak var thumbnail: UIImageView!
@IBOutlet weak var title: UILabel!
@IBOutlet weak var desc: UILabel!
@IBOutlet weak var date: UILabel!
@IBOutlet weak var user: UILabel!
```

![関連付け](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/17.png)


## Carthageの導入

Swiftはライブラリを追加して機能を拡張して実装していきます。そのライブラリ管理を行ってくれるツールを導入します。そのツールが**Carthage**（カルタゴもしくはカーセッジ、どちらでも良いです）になります。他にも`Cocoa Pod`というツールもありますが、ここではCarthageをお勧めしてます。
[これ](http://qiita.com/yutat93/items/97fe9bc2bf2e97da7ec1)が非常にわかりやすくまとまっているので参考にしてインストールしてください。

Terminalでプロジェクト場所に行き、以下の5つを新しく作成した`Cartfile`に書き込んで`carthage update --platform iOS --no-use-binaries`を実行します。このプロジェクトを実行できないときはここのライブラリのバージョンが怪しいかもしれません。

```Cartfile.
github "SwiftyJSON/SwiftyJSON"    
github "Thomvis/BrightFutures"
github "rs/SDWebImage"
github "realm/realm-cocoa"
github "ishkawa/APIKit" ~> 3.0
```

    SwiftyJson: JSONの取り扱いを簡単に行えるライブラリ。

    BrightFutures: プロミスの取り扱いを簡単にするライブラリ。

    SDWebImage: 画像の非同期処理を行うライブラリ。記事一覧をスクロールする時に動作が重くなるのを防げます。（Kingfisherに置き換えたい。）

    realm-cocoa: Realmという永続的な記憶システムを利用可能にします。UserDefaultsよりも複雑なデータを簡単に保存できます。

    APIKit: API通信を便利に行えるライブラリ。APIに関して次で説明します。Alamofireから移行しました。

これらのライブラリを利用する時は、`import UIKit`のようにファイルの先頭に利用するライブラリをインポートする宣言します。


## APIの利用

アプリ開発では、記事のデータをAPIを用いて行います。非常に簡単に説明すると、あるURLを叩くとjson形式でデータを取得できる、という仕組みです。CandleのキュレーションサービスであるMARBLEのAPIを見ていきます。

`http://api.topicks.jp/api/v1/articles/list.json?search_type=category&limit=30`

パラメータ: search_type = category, limit = 30にしています。
limit = 2にした時の出力結果が以下のようになっております。これは記事一覧用のAPIであり、記事詳細ページはまた他のAPIがあります。

    {
        "meta": {
            "page": 1,
            "limit": "2",
            "count": 1099,
            "pageCount": 550,
            "nextPage": 2,
            "prevPage": null
        },
        "results": [
            {
                "Article": {
                    "id": "100437",
                    "category_id": "21",
                    "title": "話題沸騰中！一輪の花が入ったKAILIJUMEIのリップがかわいい",
                    "body": "今、SNSなどで話題沸騰中の中国発のコスメブランドKAILIJUMEI（カイリジュメ   イ）の一輪の花が入ったクリアリップをご存知ですか？既に知っている方にも、まだ知らない方にも、可愛さだけではなく、一体どのようなものなのかを詳しく紹介していきます♪」",
                    "published": 1468567042,
                    "modified": 1469495873,
                    "thumb": "https://cdn-stylehaus-jp.akamaized.net/article_parts/128910/128910_normal.jpg?1467001027",
                    "thumb_status": "0",
                    "item_order": "2937264,2999394,2999706,2999439,2937256,3000057,2999387,2991367,2999620,2993545,2993565,2993568,2993583,3001456,2993620,2999377,2999576,2999541,3001476,2999725,2999753,3000122,3000091,2999746,2999848,2999832,2999821,2999820",
                    "thumb_updated": "2016-07-06 15:32:50",
                    "provider": "",
                    "one_page": "0",
                    "category_name": "メイク・コスメ",
                    "thumb_original": "http://s3-ap-northeast-1.amazonaws.com/topicks/article_thumb/100437_original.jpg",
                    "thumb_normal": "http://s3-ap-northeast-1.amazonaws.com/topicks/article_thumb/100437.jpg"
                },
                "User": {
                    "id": "3618",
                    "username": "usagisan",
                    "screenname": null
                }
            },
            {
                "Article": {
                    "id": "100843",
                    "category_id": "20",
                    "title": "この夏もユニクロのコラボ商品が熱い！リバティロンドン×ユニクロ",
                    "body": "140年以上も歴史のあるロンドンの老舗百貨店、リバティロンドンとユニクロが待望の第三弾としてコラボしました。とても夏らしいコラボアイテム達。この夏もユニクロのプチプラコラボアイテムを手に入れて、夏のコーディネートを鮮やかに彩りましょう！",
                    "published": 1468379074,
                    "modified": 1468496328,
                    "thumb": "https://s-media-cache-ak0.pinimg.com/474x/6b/14/1b/6b141bd76d0df16417ec66fc6b3d8956.jpg",
                    "thumb_status": "0",
                    "item_order": "2964849,2964865,2964877,2964879,2964913,2964902,2983485,2983470,2983367,2965004,2983384,2965029,2983137,2983128,2983194,2983170,2983182,2983188,2983256,2983276,2983280,2983229,2983234,2983235,2983299,2983307,2983308,2983323,2983328,2983330,2983437,2983448,2983453,2983391,2986628,2986639,2964889",
                    "thumb_updated": "2016-07-10 14:39:27",
                    "provider": "",
                    "one_page": "0",
                    "category_name": "ファッション",
                    "thumb_original": "http://s3-ap-northeast-1.amazonaws.com/topicks/article_thumb/100843_original.jpg",
                    "thumb_normal": "http://s3-ap-northeast-1.amazonaws.com/topicks/article_thumb/100843.jpg"
                },
                "User": {
                    "id": "3567",
                    "username": "us__im",
                    "screenname": null
                }
            }
        ]
    }
    
    
## Cellを表示してみる

まず、`ArticleViewController.swift`において`UITableViewDelegate`, `UITableViewDataSource`の実装をしていきます。


```ArticleViewController.swift

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96.0
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {
    // return the number of tableCells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    // draw the tableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArticleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell") as! ArticleTableViewCell
        return cell
    }
}
```


まずcellの登録をしないといけません。また、cellの大きさの目安をあらかじめ指定しておくと良いです。

```swift
tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
tableView.rowHeight = UITableViewAutomaticDimension
tableView.estimatedRowHeight = 96.0
```

次に`CellForRowAt`という描画のためのメソッドを実装します。先ほど登録したcellを呼び出すメソッドを記述します。ここでは呼び出ししか行っていませんが、この後、APIを利用して取得したデータを引数として`ArticleTableViewCell.swift`に渡してcellを加工してreturnするメソッド（`bindDataCell`という名前にします）を`ArticleTableViewCell.swift`に書いていきます。

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: ArticleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell") as! ArticleTableViewCell
    return cell
}
```

ここまでくると、コマンド+Rで実行するとシミュレーターがエラーなく起動するはずです。

コマンド+Rで実行
コマンド+Bでビルド
コマンド+シフト+Kでクリーン（キャッシュを削除してくれるのでたまにこれでエラーが解決したりします。）

デバッグには、`print('欲しい値など')`やBreak Pointを挿入します。Break Pointはエディタに表示されている行数をクリックすることで挿入できます。青い印が入りますが、これがBreak Pointを表しています。実行中にここを通ると無理やり中断させて解析することができます。本当にここ通ってるのかなという時などに便利です。コンソールに(`lldb`)というものが出てきますが、これはデバッガで、`po article.count`のように`po 欲しい値`を出力できます。デバッガには他にもいろいろ便利な機能が備わっているので調べてみたり試しみてください。Break Pointを入れるときはいちいちアプリを実行し直す必要はありません。値を確認するときは`print`を書いて再実行するより`po`で確認すると良いでしょう。

`Terminating app due to uncaught exception 'NSUnknownKeyException'`というエラーが出たら、`ArticleTableViewCell.xib`と`ArticleTableViewCell.swift`との関連付けがおかしくなっているはずです。

ここで`bindDataCell`のひな形を作成しておきます。これを利用するには上の`CellForRowAt`の中で`cell.bindDataCell()`とかくだけです。


```ArticleTableViewCell.swift

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
        // cellの生成時に必ず通る
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func bindDataCell() {
        // 引数にArticleオブジェクトを受け取って、cellの作成を行います.
        // 現状まだ引数をいれずに適当な値を入れています.
        title.text = "test"
        date.text = "date"
        desc.text = "記事の説明です"
        user.text = "user'

        // 画像の描画に関して
        // if let構文で書くとき
        /* if let thumbnail = "https://i.vimeocdn.com/portrait/58832_300x300" {
               if let data = Data(contentsOf: URL(string: thumbnail)!) {
                   thumbnail.image = UIImage(data: data)
               }
            }
        */

        // guard let で書くとき. ネストが深くならない、かつ、早期リターンできるのでこちら推奨.
        // WebImageを使うとパフォーマンスが向上します
        guard let thumbnailURL = URL(string: "https://i.vimeocdn.com/portrait/58832_300x300") else { return }
        guard let thumb = try? Data(contentsOf: thumbnailURL) else { return }
        thumbnail.image = UIImage(data: thumb)

    }
}
```


起動して、以下の画面のようになっていれば正しくできています。

![テスト画面](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/19.png)


## APIを取得してみる

`Utils`と`Requests`という新しいグループを作成して、その中にAPI通信や共通のメソッドをまとめていきます。まずNew Groupから2つ新しいグループ（`Utils`と`Requests`）を作成
して、`Utils`の中にまず`APIManager.swift`を新規作成します。この時、テンプレートは`cocoa touch`ではなく`Swift`で良いです。`Requests`にはAPIリクエストをまとめます。

API通信を行うようのオブジェクトAPIManagerを作成します。`send`という関数には**ジェネリクス**という概念を利用しています。これは引数に型（型パラメータ）を与えるものです。ジェネリクスに関しては[ここ](https://github.com/ngo275/learn-swift/tree/master/SwiftGenericsExplain.playground/Pages)を参照してください。

返り値にある`Future<T.Response, SessionTaskError>`の型は、**プロミス**といいます。非同期通信時、その通信が完了するまで値は入っておらず、その値がなくても先にプログラムを進めるために利用されます。`APIManager.swift`は以下のようにします。

```APIManager.swift

import Foundation
import SwiftyJSON
import APIKit
import BrightFutures

struct APIManager {

    static func send<T: MarbleRequest>(request: T, callbackQueue queue: CallbackQueue? = nil) -> Future<T.Response, SessionTaskError> {

        let promise = Promise<T.Response, SessionTaskError>()

        Session.send(request, callbackQueue: queue) { result in
            // ここらへんの使用はAPIKitのREADMEを読みましょう.
            switch result {
            case let .success(data):
                promise.success(data)

            case let .failure(error):
                promise.failure(error)
            }
        }

        return promise.future
    }

}
```

先ほど作成したディレクトリ`Requests`の中には`APIKit`で利用するリクエストの構造体を入れて行きます。まず`MarbleRequest.swift`を新規作成します。protocolを作成して`Request`というprotocolを採用します。このprotocolは`APIKit`内で定義されているもので、`import APIKit`を宣言します。

```MarbleRequest.swift
import Foundation
import APIKit

protocol MarbleRequest: Request {}

extension MarbleRequest {
    var baseURL: URL { return URL(string: "http://api.topicks.jp/api/v1")! }
}

```


次に、APIのリクエストごとに構造体を作成します。ここでは、記事一覧を持って来るためのリクエスト用の構造体（`GetArticlesRequest`）だけ作成しておきます。`GetArticleRequest.swift`は以下のようになります。

```GetArticlesRequest.swift
import Foundation
import APIKit
import SwiftyJSON

struct GetArticlesRequest: MarbleRequest {
    // typealiasは型に別名をつけます.APIKitのDocumentに実装すべきpropertyやmethodが書いてあるので確認してみてください.
    // maxは返ってきた記事数で、無限スクロールをする時に、次のページがあるかどうかの判別で使います.
    typealias Response = (max: Int, articles: [Article])
    
    // queryParametersは空でも動くように?をつけています.
    let queryParameters: [String : Any]?
    var method: HTTPMethod { return .get }
    var path: String { return "/articles/list.json" }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> (max: Int, articles: [Article]) {
        let json = JSON(object)
        
        if let message = json["message"].string {
            throw ResponseError.unexpectedObject(message)
        }
        
        let max = json["meta"]["count"].int ?? 0
        let articles = json["results"].arrayValue.map { Article(json: $0) }
        
        return (max, articles)
    }
}

```

エラー処理を`Utils.swift`にまとめて書いておきます。先ほど作成した`Utils`の中に以下のファイルを作成しておきましょう。

```Utils.swift
import UIKit

class Utils {
    static func createErrorObject(_ message: String, code: Int = 100) -> NSError {
        let domain = "jp.co.candle.app.marble"
        
        return NSError(domain: domain, code: 100, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
```

日付のフォーマットに関して実装する際その都度、書かないといけない処理を`Utils`にまとめておきます。`DateUtils.swift`というファイルを作って以下のようにします。

```DateUtils.swift
import UIKit

extension Date {
    static func dateFromString(_ string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: string)
    }
}
```

これがあることで`Date.dateFromString`(`日付に関するStringデータ.stringValue`)のように`String`から`Date`に簡単に型変換を行うことが可能になります。`NSData`がSwift3になって`Data`になりました。

Modelの中にある`Article.swift`を実装します。Modelの中に`User.swift`も作成しておきます。ここは天下り的になってしまいますが、Model, ViewModelを以下のように実装します。このようにArticleという構造体を導入することで、データの受け渡しや、欲しいデータのアクセスを簡易化できます。jsonで取り扱うと、`json["result"]["Article"]["title"].stringValue`というアクセス方法を毎回取らねばなりません。Articleオブジェクトにすると`article.title`で利用できます。タイポも減るしいいですね。  

まず`Article.swift`から。

```Article.swift    
import UIKit
import SwiftyJSON

struct Article {

    let id: Int
    let title: String
    let body: String
    let categoryId: Int
    let categoryName: String
    let itemOrder: String
    let modified: Int
    let onePage: Int
    let provider: String
    let published: Int
    let thumb: String
    let thumbNormal: String
    let thumbOriginal: String
    let thumbStatus: Int
    let thumbUpdated: Date
    let userData: User
    
    init(json: JSON) {
        let article = json["Article"]
        id = article["id"].intValue
        title = article["title"].stringValue
        body = article["body"].stringValue
        categoryId = article["category_id"].intValue
        categoryName = article["category_name"].stringValue
        itemOrder = article["item_order"].stringValue
        modified = article["modified"].intValue
        onePage = article["one_page"].intValue
        provider = json["provider"].stringValue
        published = article["published"].intValue
        thumb = article["thumb"].stringValue
        thumbNormal = article["thumb_normal"].stringValue
        thumbOriginal = article["thumb_original"].stringValue
        thumbStatus = article["thumb_status"].intValue
        thumbUpdated = Date.dateFromString(article["thumb_updated"].stringValue) ?? Date()
        userData = User(json: json["User"])
        
    }
}
```

Userモデルも`User.swift`に記述していきます。    

```User.swift
    
import UIKit
import SwiftyJSON

struct User {
    
    let id: Int
    let screenName: String
    let userName: String
    
    init(id: Int, screenName: String, userName: String) {
        self.id = id
        self.screenName = screenName
        self.userName = userName
    }
    
    init(json: JSON) {
        id = json["id"].int ?? 0
        screenName = json["screenname"].string ?? ""
        userName = json["username"].string ?? ""
    }
}
```


次に`ArticleViewModel.swift`を以下のようにします。

```ArticleViewModel.swift
import UIKit
import BrightFutures
import SwiftyJSON
import APIKit

class ArticleViewModel {
    
    var max: Int = 0
    var articles = [Article]()
    
    func fetchArticles(params: [String: Any]) -> Future<GetArticlesRequest.Response, SessionTaskError> {
        
        return APIManager.send(request: GetArticlesRequest(queryParameters: params))
    }
}
```

次に`ArticleViewController.swift`にプロパティをつけていきます。まず`ArticleViewModel`、`APIManager`をインスタンス化します。都合上`ArticleViewModel`に`[Article]型`の`articles`というプロパティを持たせていますが、それの読み書きを`ArticleViewController`で行っています（`get`や`set`）。データの中身自体をViewControllerに持たせないためです。
`UIKit`, `SwiftyJSON`, `Result`をインポートしましょう。

```ArticleViewController.swift
import UIKit
import SwiftyJSON
import Result

class ArticleViewController: UIViewController {

    private let viewmodel = ArticleViewModel()
    
    // ViewModelに実際のデータをもたせているので、ここではget/setでViewModelにアクセスしている
    private var articles: [Article] {
        get {
            return viewmodel.articles
        }
        set(newValue) {
            viewmodel.articles = newValue
        }
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        load()

        tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func load() {
        let params: [String: Any] = [
            "search_type": "category",
            "limit": 30,
        ]
        viewmodel.fetchArticleList(params: params)
            .onSuccess { [weak self] data in
                self?.articles = data.articles
                self?.tableView.reloadData()
                print(data.articles)
            }
            .onFailure { [weak self] error in
                self?.showErrorAlert(error.localizedDescription, completion: nil)
        }
    }

    private func showErrorAlert(_ message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "MARBLE",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: completion))
        present(alert, animated: true, completion: nil)
    }

}
```


この時点で実行すると、

`test1[14247:6154680] App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.`

というエラーが出るかもしれません。ATSの設定をいじります。以下の写真のように設定をしておきます。

![ATS](https://s3-ap-northeast-1.amazonaws.com/ngo275.asset/Pic/ATSsetting.png)

記事データのログが大量に出るはずです。まだcellにデータを渡して描画するという部分を実装していないので、次はそこを実装します。

`ArticleTableViewCell.swift`の`bindDataCell`という関数を以下のようにします。引数に`article`を入れることで各Cellの`UILabel`のプロパティを欲しい形にできます。

```ArticleTableViewCell.swift

///////
func bindDataCell(article: Article) {
    // 引数にArticleオブジェクトを受け取って、cellの作成を行います.
    title.text = article.title
    date.text = String(article.modified)
    desc.text = article.body
    user.text = article.userData.userName
    
    // 画像の描画に関して
    // if let構文で書くとき
    /* if let thumbnail = "https://i.vimeocdn.com/portrait/58832_300x300" {
           if let data = Data(contentsOf: URL(string: thumbnail)!) {
               thumbnail.image = UIImage(data: data)
           }
        }
    */

    // guard let で書くとき. ネストが深くならない、かつ、早期リターンできるのでこちら推奨.
    guard let thumbnailURL = URL(string: "https://i.vimeocdn.com/portrait/58832_300x300") else { return }
    guard let thumb = try? Data(contentsOf: thumbnailURL) else { return }
    thumbnail.image = UIImage(data: thumb)
    
}
```

`ArticleViewController`側（呼び出し側）では以下のようにします。

    class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
と`ArticleViewController`の定義時にまとめて`UITableViewDelegate`を書くことが可能ですが、なるべくそれぞれのDelegate単位で`extension`を使って分割していくようにします。Swiftの拡張機能。また
    
    // MARK: - UITableViewDataSource
    
とMARKのコメントをつける習慣もつけましょう。フォーマットを守りましょう。MARKはXcodeで検索をする時に利用できます。

```ArticleViewContrller.swift
///
extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    // draw the tableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArticleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.bindDataCell(articles[indexPath.row])
        
        return cell
    }
}
```

`indexPath`には`row`と`section`というプロパティが存在して、`section`はTableのかたまりで、`row`（もしくは`item`。`row`と`item`は同義）はその中でのインデックスに相当します。ここではsectionは一つしかないのでここでは`row`のみ（`item`でもよい）利用します。`CellForRowAt`では`indexPath`順に一つ一つのCellが描画されていきます。

この時点でシミュレーターを実行すると記事一覧が表示されるはずです。（**ATS**の設定を変更しないと画像がうまく表示されないかもしれません。）

この時`ArticleViewController.swift`の`viewDidLoad`をみると以下のようになっています。

```ArticleViewContoller.swift
override func viewDidLoad() {
    super.viewDidLoad()
        
    load()
        
    tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 96.0
}
```

`tableView...`という記述が3行ありますね。なるべく`viewDidLoad`は関数呼び出しに専念させたいので、この3行を関数に切り出しましょう。

```ArticleViewController.swift
///
private func initTableView() {
    tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 96.0
}
```

という関数を`private func load()`とかと並列する位置に書きましょう。そして`viewDidLoad`に`initTableView()`を`load()`の下に加えましょう。`private`はそのスコープ内でアクセス可能にするアクセス修飾子です。`fileprivate`が、同じファイル内からのアクセスを可能にする修飾子です。デフォルトは`internal`です。

次に、`ArticleTableViewCell`を登録して描画するまでに`ArticleViewController`に4つもの`ArticleTableViewController`というワードが出てきています。また他のCellをXibファイルに作成して描画するたびにこの面倒な記述をしなければならないのです（typoとかの可能性も増大しますね）。こういう面倒な記述をプロトコルを利用して簡略化できるので実装していきましょう。

New Groupからまた新しいグループを作成して`Protocols`と名付けましょう。その中にファイルの新規作成（テンプレートはSwift file）から`NibLoadable.swift`というファイルを作ります。`NibLoadable.swift`の中身は以下のようにします。

```NibLoadable.swift
import UIKit

protocol NibLoadable: class {
    static var nibName: String { get }
}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
```

同様にして`Protocols`の中に`Reusable.swift`を作成して中身を以下のように記述します。

```Reusable.swift
import UIKit

protocol Reusable: class {
    static var defaultReuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
```

`Utils`の中に`TableViewUtils.swift`というファイルを作り以下のようにします。`// MARK - プロトコル名`としているのはプロトコルの適用部分に印をつける意味があり、検索時に可視化しやすくなります。

```TableViewUtils.swift
import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(registerCell _: T.Type) where T: Reusable & NibLoadable  {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
}
```

このようにメソッドを記述しておくことで、
`tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")`

=> `tableView.register(registerCell: ArticleTableViewCell.self)`

`let cell: ArticleTableViewCell = tableView..dequeueReusableCell(withIdentifier: cellClassName, forIndexPath: indexPath) as! ArticleTableViewCell`

=> `let cell: ArticleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)`

と記述するだけでよくなります。

これで記事一覧ページの表示完了です。

![記事一覧完成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/21.png)

参考に`ArticleViewController.swift`を載せておきます。`viewDidLoad`に`title = "MARBLE"`を書いておくといい感じにヘッダーが出ます。


```ArticleViewController.swift
import UIKit
import SwiftyJSON
import Result
    
class ArticleViewController: UIViewController {
            
    private let viewmodel = ArticleViewModel()
    private let apiManager: APIManager = APIManager.sharedInstance
    fileprivate var articles: [Article] {
        get {
            return viewmodel.articles
        }
        set(newValue) {
            viewmodel.articles = newValue
        }
    }
        
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        title = "MARBLE"
        load()
        initTableView()
    }
    
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        // MARK: private method
        
        private func initTableView() {
            tableView.register(registerCell: ArticleTableViewCell.self)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 105.0
        }
        
        private func load() {
            let params: [String: AnyObject] = [
                "search_type": "category",
                "limit": 30,
                //            "category_id": categoryId
            ]
            viewmodel.fetchArticleList(params)
                .onSuccess { [weak self] data in
                    self?.articles = data.articles
                    self?.tableView.reloadData()
                    // data.1とdata.articlesは等しい
                    print(data.articles)
                }
                .onFailure { [weak self] error in
                    self?.showErrorAlert(error.localizedDescription, completion: nil)
            }
        }
        
        private func showErrorAlert(_ message: String, completion: ((UIAlertAction) -> Void)?) {
            let alert = UIAlertController(title: "MARBLE",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert
            )
        
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: completion))
            present(alert, animated: true, completion: nil)
        }
    
    }
    
extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    // return the number of tableCells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    // draw the tableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArticleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.bindDataCell(articles[indexPath.row])
    
        return cell
    }
    // action when a cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: jump to the detail page.
    }
}
```
この時点では画像表示がカクカクしているかと思います。`WebImage`を使ってこのカクカクを解消します。

## 記事詳細ページの作成

`Storyboards`の中にある`ArticleDetail.storyboard`を編集していきます。この中に`ViewController`を挿入して、`ViewController`というフォルダの中にある`ArticleDetailViewController`と関連付けをします。

![ArticleDetailStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/22.png)

ここでは、Storyboardの分割・遷移にフォーカスしているので、記事詳細ページで表示するのは`article.body`だけにとどめておきます。下の画像のように`textView`を挿入します。Constraintも自分で自由に設定して良いです。

![textViewの追加](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/23.png)

`ArticleDetailViewController`と先ほど追加した`textView`を関連付けます（コントロールを押しながらドラッグするやつ）。基本的にStoryboardにあるものはすべてコードでも関連付けをしないといけないと思っておいて良いでしょう。
*Identifier*もつけておきます。

![identifier](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/25.png)

**遷移してきた時に最初にStoryboardのどれに初めにアクセスすればいいのかを伝えるために以下のようにInitialのチェックをつけます。**

![initial設定](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/26.png)

`ArticleDetailViewController.swift`は以下のようになります。
    
```ArticleDetailViewController.swift
import UIKit
import SwiftyJSON

class ArticleDetailViewController: UIViewController {

    let apiManager: APIManager = APIManager.sharedInstance
    var article: Article?

    @IBOutlet weak var text: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let article = article {
            text.text = article.body
            text.editable = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
```

あとは`ArticleViewController`ら遷移して、その際に`article`を受け渡せばよいです。
`tableView`にはCellをタップした時のアクションを実装するfunctionが準備されています（delegate）のでそれを利用します。以下を`ArticleVeiwContrller.swift`に書きます。

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let storyboard: UIStoryboard = UIStoryboard(name: "ArticleDetail", bundle: nil)
    if let next: ArticleDetailViewController = storyboard.instantiateViewController(withIdentifier: "ArticleDetail") as? ArticleDetailViewController {
        next.article = articles[indexPath.row]
        navigationController?.pushViewController(next, animated: true)
    }
}
```

このfuctionを遷移元であるArticleViewControllerの`extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {`の中に記述しましょう。ここでは、まず遷移先のStoryboardをインスタンス化して、それに対応するViewControllerを取得、そこに遷移する、という流れです。その時に一緒に遷移先の`article`というプロパティにタップされた`article`を渡しています。タップされたCellは`indexPath.row`（`indexPath.item`）でアクセスできます。

ここまでくるとタップすると遷移できているはずです。

記事一覧を表示するときに、Cellを登録する・表示する時にProtocolに切り出しましたが、ここでもStoryboardの遷移の関数は繰り返し使うのでProtocolに切り出して統一しましょう。

`Protocols`というフォルダに`StoryboardLoadable.swift`というファイルを作成して以下のように記述します。

```StoryboardLoadable.swift
import UIKit

protocol StoryboardLoadable: class {
    static var storyboardName: String { get }
}

extension StoryboardLoadable where Self: UIViewController {

    static var storyboardName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!.replacingOccurrences(of: "ViewController", with: "")
    }

}
```

そして、`Utils`の中にある`Utils.swift`に

```Utils.swift
import UIKit

class Utils {
    
    static func createErrorObject(_ message: String, code: Int = 100) -> NSError {
        let domain = "jp.co.candle.app.marble"
        
        return NSError(domain: domain, code: 100, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    static func createViewController<T: StoryboardLoadable>() -> T {
        let sb = UIStoryboard(name: T.storyboardName, bundle: nil)
        return sb.instantiateInitialViewController() as! T
    }
    
}
```

と加えておきます。どこかに以下のプロトコル適用を書いておきます。場所はどこでも良いですが、`ArticleViewController.swift`に書いておきます。`ArticleVeiwContrller.swift`の末尾がわかりやすいでしょう。

```swift
// MARK - StoryboardLoadable
extension UIViewController: StoryboardLoadable {}
```

さきほどの関数もこのようにスッキリします。このようにプロトコルを利用する方法を取り入れていきましょう。

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let next: ArticleDetailViewController = Utils.createViewController()
    next.article = articles[indexPath.row]
    navigationController?.pushViewController(next, animated: true)
}
```

## Tabの利用

今はまだタブがなく記事一覧ページがいきなり出てくるだけなのでタブを取り入れてコンテンツを増やしていきたいと思います。

`Main.storyboard`に`TabBarController`を追加します。デフォルトで2つの`ViewController`がついてきますが、これらを削除します。`ViewController`の`NavigationController`と`ArticleViewController`をコピーします（最初からあった`ViewController`は不要になります）。次に`Article.storyboard`を作成し、その中に先ほどコピーした2つのViewControllerをペーストします。コントロール+Cとコントロール+Vでできます。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/27.png)

`Main.storyboard`には`TabBarController`のみが残っているようにしたら、これに`Is Initial View Controller`の設定をしておきます。`Article.storyboard`の`UINavigationController`にも同じように設定します。**基本的に各storyboardには必ず`Is Initial View Controller`をつけたStoryboardが存在するようにしなければなりません。**

~~次は、`Article.storyboard`の`NavigationController`に対応する`ViewController`を作成しなければなりません。`ArticleContainerViewController`とします。各Tabに1つ`ContainerViewController`を対応させる必要があります。`ContainerViewController`というフォルダを作成して、その中に`ContainerViewController`を追加していきましょう。新規作成で`CocoaTouchClass`で`UINavigationController`を継承した`ArticleContainerViewController`を作ります。そして下の画面のように`NavigationController`と関連付けをしておきましょう。~~

`ArticleViewController.swift`とかに紐づく`UINavigationController`はデフォルトのままでよくて、いちいちそれに紐づく`ContainerViewController`を作る必要はありませんでした。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/28.png)

次は、`Main.storyboard`に対応する`ViewController`を作成します。`MainTabBarController`を`AppDelegate.swift`の階層あたりに作成します。`CocoatouchClass`から`UITabBarController`を選択すると良いです。そしてStoryboardで関連付けもしておきましょう。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/29.png)

`MainTabBarController`に`viewDidLoad`でTabに入れるべき`Viewcontroller`（`ArticleViewController`, `SearchViewController`, `LikeViewController`, `MypageViewController`）を指定します。

```MainTabBarController.swift
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Arrayにした方がきれいに見えそうです...
        let articleStoryboard = UIStoryboard(name: "Article", bundle: nil)
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        let likeStoryboard = UIStoryboard(name: "Like", bundle: nil)
        let mypageStoryboard = UIStoryboard(name: "Mypage", bundle: nil)
        let articleViewController = articleStoryboard.instantiateInitialViewController() as! UINavigationController
        let searchViewController = searchStoryboard.instantiateInitialViewController() as! UINavigationController
        let likeViewController = likeStoryboard.instantiateInitialViewController() as! UINavigationController
        let mypageViewController = mypageStoryboard.instantiateInitialViewController() as! UINavigationController
        let viewControllers = [articleViewController, searchViewController, likeViewController, mypageViewController]
        self.setViewControllers(viewControllers, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

```


![デモ](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/30.png)

今のところTabのアイコンが変なのでここの編集をしていきます。アイコン等の画像は基本的に`Assets.xcassets`というフォルダがデフォルトで存在するのでそこに追加していきます。（ホームなどの画像はMARBLEのRsourcesというフォルダに入っていると思うのでそこからダウンロードすると良いでしょう。）1x, 2x, 3xは解像度が異なります。AppIconを設定することでアプリのアイコンを登録できます。

![xcassetを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/32.png)

TabBarItemを`Article.storyboard`に挿入します。
![ArticleStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/31.png)

さきほど登録したホームアイコンをStoryboardで設定します。デフォルトで備わっているアイコンであればSystem Iconから選択できます。

![ArticleStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/33.png)

他に必要なTab（Search, Like, Mypage）も付け足します。Storyboard、ViewControllerを作成して`MainTabBarController`に追加分のViewControllerを書いていきます。

手順をもう一度簡単にまとめると以下のようになります。

新規作成でStoryboardを作ります。`ViewController`を追加、ツールバーの`Editor/EmbedIn/NavigationController`でUINavigationControllerを追加します。今できた2つのViewControllerのそれぞれに対応するViewControllerを作成します（e.g. `Search.storyboard`, `SearchViewController.swift`）。この時StoryboardとViewControllerの関連付け、`IsInitialViewController`の設定、UINavigationControllerにTabBarItemの追加を忘れないようにしましょう。

![タブ完成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/34.png)


## お気に入り機能の実装

記事詳細ページに適当なボタンを設置してそれをタップするとLikeでき、Likeページに行くとLikeした記事の一覧を見れる、というお気に入り機能を実装します。
Realmを使います。



## 最後にgithubに公開

ここまでで作成したappをgithubに公開するときの注意点を述べておきます。xcodeの作業分をFinderで確認するとディレクトリがなく全て同じ階層に作成されているはずです。Xcodeのプロジェクト構成とFinderのプロジェクト構成を同期する必要があります。でないとgithubに反映されるのはFinderと同じディレクトリ構成なので新規にグループを作ったはずなのに反映されていない、というワナにはまってしまいます。

`http://s31o3.hatenablog.com/entry/2015/03/27/151432`

を参考にしてsynxというツールをインストールしましょう。`git add .`する前にこれでxcodeとFinderを同期しておきましょう。


