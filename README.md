# Marble-kenshu

*コード自体はSwift3に対応させました。クローンしたら動作確認できるはずです。Carthageをインストールしていない場合は動きません。*

## Swiftでアプリ開発（キュレーションアプリを作成してみます）
プログラミング言語 Swift で iOS アプリを作ります。iOS アプリは Apple が整備する`Cocoa touch`と呼ばれるフレームワーク群を利用して構成されています。`Cocoa touch`の主要なフレームワークは`Foundation`と`UIKit`です。`Foundation `は文字列やコレクションといった基本的なクラスから、並行処理やネットワーク処理のためのクラスまで基本的なツールが揃っています。`UIKit`はiOS のGUIフレームワークであり、アプリケーションを構成するための重要な機能のほとんどを担っています。

## アーキテクチャにはMVVMを採用
### Model
アプリケーションで持たれるデータに関して定義をします。ここではキュレーションアプリを作成するので、記事（`Article`）やユーザー（`User`）等のデータ構造を定義します。
### ViewController
ViewControllerはUIViewControllerを継承しており、あるViewを管理し、タップなどのイベントを検知して制御しています。基本的にViewModel等のメソッド呼び出しを行い、Viewの描画に専念しましょう。viewDidLoadに詰め込みすぎないようにfunctionの切り出しやプロトコルの利用をしていくように心がけましょう。
### ViewModel
データの加工を行います。**引数をもらって加工した結果を返す**という役割に終始させることを意識しましょう。なるべくプロパティを持たないようさせます。もしプロパティを持つことがあったとしても、関数の実行中にそのプロパティを更新するようなことは避けましょう。これを**副作用**と言います。

## 以下キュレーションアプリ（MARBLE）作成のチュートリアル


## プロジェクト作成
Xcodeの新規プロジェクトで、Single View Applicationを選択してプロジェクト名を入力します。ここではtest1というプロジェクト名にしてあります。プロジェクトの中身はフォルダを作成してわかりやすく構成しましょう。新しくフォルダを追加するには以下の画面のように右クリックからNew Groupを作成するところから行います。

![フォルダーの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/1.png)

ディレクトリ構成は以下のようにします。

![ディレクトリ構成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/2.png)

Storyboardは一つのファイルに詰め込むとチームで開発しているとコンフリクトの嵐になってしまうので、１つのページにつき1つのStoryboardになるように分割していきます。Storyboardファイルの作成は以下のようにします。

![Storyboardの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/4.png)

記事一覧ページはTableViewを利用して表示しますが、Cellは、コードで生成せずに、自分でGUIを利用して作成します。Viewパーツ用のファイル（これをXib（ニブ）ファイルと呼びます）にカスタムビューを作成していきます。Xibファイルは以下の画面から作成します。基本的なファイルの拡張子は.swiftになるのですが、Storyboardの拡張子は.storyboard、Xibファイルの拡張子は.xibになります。.plistという拡張子を持つものはプロジェクトに関する設定を記述しているものです。ATSなどの設定でいじることになるでしょう。AppleはHTTP通信に関して厳しく規制を始めており、HTTP通信を許可する設定をATSという欄をいじって行います。

![xibファイルの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/3.png)

## Storyboardで準備

まず、記事一覧ページを表示できるところまでを目安に進めていきます。StoryboardとArticleViewControllerを関連付けて、Editor -> Embed in -> Navigation ControllerでNavigationControllerをつけます。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/5.png)

ArticleViewControllerにTableViewを挿入します。TableViewControllerを利用しても良いのですが、ViewControllerにTableViewを入れてテーブルを作成したほうがカスタムしやすいので、ArticleViewControllerにTableViewを挿入する形式にします。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/6.png)

次にTableViewを画面全体に引き伸ばします。右下でConstraintの設定をしていきます。上下左右を0にしてAdd 4 Constraintsとしましょう。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/7.png)

今のでConstraintsは変更されました。しかし、現状のTableViewとサイズや位置（Frames）とのずれが生じているのでUpdate FramesでTableViewの制約条件を更新しましょう。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/8.png)

こうすると、画面いっぱいにTableViewが広がるのですが、左右にマージンが残っています。これを消していきましょう。左端直線を選択して、SecondItemのRelative to margin、右端はFirstItemのRelative to marginのチェックを外します。左右のマージンが消えればOKです。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/9.png)

TableViewCellを入れます。

![TableViewCellの追加](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/10.png)

同様に上部にマージンが残るので、Ajust Scroll ...のチェックを外します。（画像は外す前です）

![TableViewの上部のマージン削除](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/11.png)

Cellとそれに対応するファイルの関連付けを行っておきましょう。

![関連付け](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/12.png)

次にTableViewのDelegateの設定も以下の画面のように行っておきます。Delegateは'移譲'と言って、異なるクラス（ファイル）間等でメソッドをまたいで使いたい時に利用します。例えばTableViewCellのファイルにはタップした時に起こるアクションを記述できるけども、Articleに関するデータをそのCellのファイルは持っていないかもしれないことがあります。

移譲というとわかりにくいかもしれませんが、簡単に言いますと、自分だけでは（例えば使いたいプロパティを持っていないから）実装できないので、やってほしいことを宣言するから、その実装を頼みます、と他の場所に頼んでいるという風に思っておけば良いでしょう。頼む側を移譲元、頼まれる側を移譲先と言います。例えば`UITableViewDelegate`は移譲先がArticleViewControllerです。ArticleViewControllerは、頼まれたからやってやるぜ、という宣言をしないといけないのですが、それがネットでよく見かける

```swift
tableView.delegate = self
tableView.dataSource = self
```

です。今回はそれをStoryboardで設定しています。頼まれた側（移譲先）は自分で頼まれた内容を実装しないといけません。

![TableViewのDelegateの設定](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/13.png)

tableViewという変数をArticleViewControllerに追加します。

![TableViewという変数をArticleViewControllerに追加](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/18.png)


## TableViewCellの作成

先ほど作成したArticleTableViewCell.xibファイルを開いてそこにTableViewCellを挿入します。この中に記事一覧のセルに必要なものを挿入します。Image Viewとlabelで作っていきます。Constraintsの設定をしていきます。UIImageViewのサイズを80×80にして上、左からの位置（offset）を8にしておきます。タイトルや日付もそれぞれの間隔を8にして設定していきます。AutoLayoutまわりの[これ](http://qiita.com/kinopontas/items/d08f84dbb711c5acbe28)を参考にしてください。

![TableViewCellの作成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/14.png)

ArticleTableViewCellの関連付けやIdentifierの設定を行います。

![関連付け](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/15.png)

![関連付け](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/16.png)

ArticleTableViewCell.swiftとUIView（Cellには入っているViewパーツ）の関連付けをしていきます。ここで、ArticleTableViewCellに入っているViewパーツに`thumbnail`や`title`、`desc`、`date`という名前の変数を作成します。コントロールを押しながらViewパーツをドラッグしてArticleTableViewCell.swiftと繋ぎましょう。2画面にするにはXcodeの右上にある2つの円が重なっているマークをクリックします。
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

Swiftはライブラリを追加して機能を拡張して実装していきます。そのライブラリ管理を行ってくれるツールを導入します。そのツールがCarthage（カルタゴもしくはカーセッジ、どちらでも良いです。Candleではカルタゴと呼んでいます）になります。他にもCocoa Podというツールもありますが、ここではCarthageをお勧めしてます。
`http://qiita.com/yutat93/items/97fe9bc2bf2e97da7ec1`
これが非常にわかりやすくまとまっているので参考にしてインストールしてください。Terminalでプロジェクト場所に行き、以下の5つを新しく作成したCartfileに書き込んで`carthage update --platform iOS --no-use-binaries`を実行します。

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

realm-cocoa: Realmという永続的な記憶システムを利用可能にします。NSUserDefaultsよりも複雑なデータを保存できます。

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

まず、ArticleViewControllerにおいて`UITableViewDelegate`, `UITableViewDataSource`の実装をしていきます。


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

次に`CellForRowAt`という描画のためのメソッドを実装します。先ほど登録したcellを呼び出すメソッドを記述します。ここでは呼び出ししか行っていませんが、この後、APIを利用して取得したデータを引数としてArticleTableViewCell.swiftに渡してcellを加工してreturnするメソッド（bindDataCellという名前にします）をArticleTableViewCell.swiftに書いていきます。

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

デバッグには、print('欲しい値など')やBreak Pointを挿入します。Break Pointはエディタに表示されている行数をクリックすることで挿入できます。青い印が入りますが、これがBreak Pointを表しています。実行中にここを通ると無理やり中断させて解析することができます。本当にここ通ってるのかなという時などに便利です。コンソールに(lldb)というものが出てきますが、これはデバッガで、`po article.count`のように`po 欲しい値`を出力できます。デバッガには他にもいろいろ便利な機能が備わっているので調べてみたり試しみてください。Break Pointを入れるときはいちいちアプリを実行し直す必要はありません。値を確認するときはprintを書いて再実行するより`po`で確認すると良いでしょう。

`Terminating app due to uncaught exception 'NSUnknownKeyException'`というエラーが出たら、ArticleTableViewCell.xibとArticleTableViewCell.swiftとの関連付けがおかしくなっているはずです。

ここでbindDataCellのひな形を作成しておきます。これを利用するには上の`CellForRowAtIndexPath`の中で`cell.bindDataCell()`とかくだけです。


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
        // これがないとXibファイルが生成されません.
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
        guard let thumbnailURL = URL(string: "https://i.vimeocdn.com/portrait/58832_300x300") else { return }
        guard let thumbnail = try? Data(contentsOf: thumbnailURL) else { return }
        thumbnail.image = UIImage(data: thumbnail)

    }
}
```


起動して、以下の画面のようになっていれば正しくできています。

![テスト画面](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/19.png)


## APIを取得してみる

UtilsとRequestsという新しいグループを作成して、その中にAPI通信や共通のメソッドをまとめていきます。まずNew Groupから2つ新しいグループ（UtilsとRequests）を作成
して、Utilsの中にまずAPIManager.swiftを新規作成します。この時、テンプレートはcocoa touchではなくSwiftで良いです。RequestsにはAPIリクエストをまとめます。

API通信を行うようのオブジェクトAPIManagerを作成します。`send`という関数にはジェネリクスという概念を利用しています。これは引数に型（型パラメータ）を与えるものです。ジェネリクスに関しては[ここ](https://github.com/ngo275/learn-swift/tree/master/SwiftGenericsExplain.playground/Pages)を参照してください。

返り値にある`Future<T.Response, SessionTaskError>`の型は、プロミスといいます。非同期通信時、その通信が完了するまで値は入っておらず、その値がなくても先にプログラムを進めるために利用されます。

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

先ほど作成したディレクトリRequestsの中にはAPIKitで利用するリクエストの構造体を入れて行きます。まず`MarbleRequest.swift`を新規作成します。protocolを作成して`Request`というprotocolを採用します。このprotocolはAPIKit内で定義されているもので、`import APIKit`を宣言します。


```MarbleRequest.swift
import Foundation
import APIKit

protocol MarbleRequest: Request {}

extension MarbleRequest {
    var baseURL: URL { return URL(string: "http://api.topicks.jp/api/v1")! }
}

```


次に、APIのリクエストごとに構造体を作成します。ここでは、記事一覧を持って来るためのリクエスト用の構造体（`GetArticlesRequest`）だけ作成しておきます。

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

エラー処理をUtils.swiftにまとめて書いておきます。先ほど作成したUtilsの中に以下のファイルを作成しておきましょう。

```Utils.swift
import UIKit

class Utils {
    static func createErrorObject(_ message: String, code: Int = 100) -> NSError {
        let domain = "jp.co.candle.app.marble"
        
        return NSError(domain: domain, code: 100, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
```

日付のフォーマットに関して実装する際その都度、書かないといけない文言をUtilsにまとめておきます。

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

これがあることで`Date.dateFromString(日付に関するStringデータ.stringValue)`のように`String`から`Date`に簡単に型変換を行うことが可能になります。

Modelの中にある`Article.swift`を実装します。Modelの中に`User.swift`も作成しておきます。ここは天下り的になってしまいますが、Model, ViewModelを以下のように実装します。このようにArticleという構造体を導入することで、データの受け渡しや、欲しいデータのアクセスを簡易化できます。jsonで取り扱うと、`json["result"]["Article"]["title"].stringValue`というアクセス方法を毎回取らねばなりません。Articleオブジェクトにすると`article.title`で利用できます。タイポも減るしいいですね。  


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

Userモデルも記述していきます。    

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


次にArticleViewModel.swiftを以下のようにします。

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

ArticleViewControllerにプロパティをつけていきます。まずArticleViewModel、APIManagerをインスタンス化します。都合上ArticleViewModelに[Article]?型のarticlesというプロパティを持たせていますが、それの読み書きをArticleViewControllerで行っています（`get`や`set`）。
UIKit, SwiftyJSON, Alamofire, Resultをインポートしましょう。

```ArticleViewController.swift
class ArticleViewController: UIViewController {

    private let viewmodel = ArticleViewModel()
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
                self?.articles = data.1
                self?.tableView.reloadData()
                print(data.1)
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

ArticleTableViewCell.swiftのbindDataCellという関数を以下のようにします。引数にarticleを入れることで各CellのUILabelのプロパティを欲しい形にできます。

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
    guard let thumbnail = try? Data(contentsOf: thumbnailURL) else { return }
    thumbnail.image = UIImage(data: thumbnail)
    
}
```

ArticleViewController側（呼び出し側）では以下のようにします。

    class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
と`ArticleViewController`の定義時にまとめて`TableViewDelegate`を書くことが可能ですが、なるべくそれぞれのDelegate単位で`extension`を使って分割していくようにします。また
    
    // MARK: - UITableViewDataSource
    
とMARKのコメントをつける習慣もつけましょう。フォーマットを守りましょう。

    extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {
    
        // MARK: - UITableViewDataSource
        
        // return the number of tableViewCells
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return articles?.count ?? 0
        }
        // draw the tableCells
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell: ArticleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ArticleTableViewCell") as! ArticleTableViewCell
            cell.bindDataCell(articles![indexPath.row])
            return cell
        }
    }

`indexPath`には`row`と`section`というプロパティが存在して、`section`はTableのかたまりで、`row`はその中でのインデックスに相当します。ここではsectionは一つしかないので`row`のみ利用します。`CellForRowAtIndexPath`では`indexPath`順に一つ一つのCellが描画されていきます。

この時点でシミュレーターを実行すると記事一覧が表示されるはずです。（ATSの設定を変更しないと画像がうまく表示されないかもしれません。）

この時ArticleViewControllerのviewDidLoadをみると以下のようになっています。

    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
        
        tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96.0
    }


tableView...という記述が3行ありますね。なるべく`viewDidLoad`は関数呼び出しに専念させたいので、この3行を関数に切り出しましょう。

    private func initTableView() {
        tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96.0
    }

という関数を`private func load()`とかと並列する位置に書きましょう。そして`viewDidLoad`に`initTableView()`を`load()`の下に加えましょう。

次に、ArticleTableViewCellを登録して描画するまでにArticleViewControllerに4つものArticleTableViewControllerというワードが出てきています。また他のCellをXibファイルに作成して描画するたびにこの面倒な記述をしなければならないのです（typoとかの可能性も増大しますね）。こういう面倒な記述をプロトコルを利用して簡略化できるので実装していきましょう。

New Groupからまた新しいグループを作成してProtocolsと名付けましょう。その中にファイルの新規作成（テンプレートはSwift file）からNibLoadable.swiftというファイルを作ります。NibLoadable.swiftの中身は以下のようにします。

    import UIKit

    protocol NibLoadable: class {
        static var nibName: String { get }
    }

    extension NibLoadable where Self: UIView {
        static var nibName: String {
            return NSStringFromClass(self).componentsSeparatedByString(".").last!
        }
    }

同様にしてProtocolsの中にReusable.swiftを作成して中身を以下のように記述します。

    import UIKit

    protocol Reusable: class {
        static var defaultReuseIdentifier: String { get }
    }

    extension Reusable where Self: UIView {
        static var defaultReuseIdentifier: String {
            return NSStringFromClass(self).componentsSeparatedByString(".").last!
        }
    }

Utilsの中にTableViewUtils.swiftというファイルを作り以下のようにします。`// MARK - プロトコル名`としているのはプロトコルの適用部分に印をつける意味があり、検索時に可視化しやすくなります。

    import UIKit

    extension UITableView {
    
        func register<T: UITableViewCell where T: Reusable>(registerCell _: T.Type) {
            registerClass(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
        }
    
        func register<T: UITableViewCell where T: protocol<Reusable, NibLoadable> >(registerCell _: T.Type) {
            let nib = UINib(nibName: T.nibName, bundle: nil)
            registerNib(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
        }
    
        func dequeueReusableCell<T: UITableViewCell where T: Reusable>(forIndexPath indexPath: NSIndexPath) -> T {
            guard let cell = dequeueReusableCellWithIdentifier(T.defaultReuseIdentifier, forIndexPath: indexPath) as? T else {
                fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
            }
        
            return cell
        }
    }
    
    // MARK - Reusable
    extension UITableViewCell: Reusable {}

    // MARK - NibLoadable
    extension UITableViewCell: NibLoadable {}

このようにメソッドを記述しておくことで、
`tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")`
=> `tableView!.register(registerCell: ArticleTableViewCell.self)`

`let cell: ArticleTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellClassName, forIndexPath: indexPath) as! ArticleTableViewCell`
=> `let cell: ArticleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)`

と記述するだけでよくなります。

これで記事一覧ページの表示完了です。

![記事一覧完成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/21.png)

参考にArticleViewController.swiftを載せておきます。`viewDidLoad`に`title = "MARBLE"`を書いておくといい感じにヘッダーが出ます。

    ▼ArticleViewController.swift
    
    import UIKit
    import SwiftyJSON
    import Alamofire
    import Result
    
    class ArticleViewController: UIViewController {
    
        
        private let viewmodel = ArticleViewModel()
        private let apiManager: APIManager = APIManager.sharedInstance
        private var articles: [Article]? {
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
        
        private func initTableView() {
            tableView!.register(registerCell: ArticleTableViewCell.self)
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
                    self?.articles = data.1
                    self?.tableView.reloadData()
                    print(data.1)
                }
                .onFailure { [weak self] error in
                    self?.showErrorAlert(error.localizedDescription, completion: nil)
            }
        }
        
        private func showErrorAlert(message: String, completion: ((UIAlertAction) -> Void)?) {
            let alert = UIAlertController(title: "MARBLE",
                                          message: message,
                                          preferredStyle: UIAlertControllerStyle.Alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: completion))
            presentViewController(alert, animated: true, completion: nil)
        }
    
    }
    
    extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {
        
        // MARK: - UITableViewDataSource
        
        // return the number of tableCells
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return articles?.count ?? 0
        }
        // draw the tableCells
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell: ArticleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.bindDataCell(articles![indexPath.row])
            return cell
        }
    }


## 記事詳細ページの作成

Storyboardsの中にあるArticleDetail.storyboardを編集していきます。この中にViewControllerを挿入して、ViewControllerというフォルダの中にあるArticleDetailViewControllerと関連付けをします。

![ArticleDetailStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/22.png)

ここでは、Storyboardの分割・遷移にフォーカスしているので、記事詳細ページで表示するのは`article.body`だけにとどめておきます。下の画像のようにtextViewを挿入します。Constraintも自分で自由に設定して良いです。

![textViewの追加](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/23.png)

ArticleDetailViewControllerと先ほど追加したtextViewを関連付けます。基本的にStoryboardにあるものはすべてコードでも関連付けをしないといけないと思っておいて良いでしょう。
Identifierもつけておきます。

![identifier](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/25.png)

遷移してきた時に最初にStoryboardのどれに初めにアクセスすればいいのかを伝えるために以下のようにInitialのチェックをつけます。

![initial設定](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/26.png)

ArticleDetailViewControllerは以下のようになります。
    
    ▼ArticleDetailViewController.swift
    
    import UIKit
    import SwiftyJSON
    import Alamofire
    
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

あとはArticleViewControllerから遷移して、その際にArticleを受け渡せばよいです。
`tableView`にはCellをタップした時のアクションを実装するfunctionが準備されています（delegate）のでそれを利用します。

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "ArticleDetail", bundle: nil)
        if let next: ArticleDetailViewController = storyboard.instantiateViewControllerWithIdentifier("ArticleDetail") as? ArticleDetailViewController {
            next.article = articles![indexPath.row]
            navigationController?.pushViewController(next, animated: true)
        }
    }
    
このfuctionを遷移元であるArticleViewControllerの`extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {`の中に記述しましょう。ここでは、まず遷移先のStoryboardをインスタンス化して、それに対応するViewControllerを取得、そこに遷移する、という流れです。その時に一緒に遷移先の`article`というプロパティにタップされたarticleを渡しています。タップされたCellは`indexPath.row`でアクセスできます。

ここまでくるとタップすると遷移できているはずです。

記事一覧を表示するときに、Cellを登録する・表示する時にProtocolに切り出しましたが、ここでもStoryboardの遷移の関数は繰り返し使うのでProtocolに切り出して統一しましょう。

ProtocolsというフォルダにStoryboardLoadable.swiftというファイルを作成して以下のように記述します。

    import UIKit

    protocol StoryboardLoadable: class {
        static var storyboardName: String { get }
    }
    
    extension StoryboardLoadable where Self: UIViewController {

        static var storyboardName: String {
            return NSStringFromClass(self).componentsSeparatedByString(".").last!.stringByReplacingOccurrencesOfString("ViewController", withString: "")
        }
        
    }

そして、Utilsの中にあるUtils.swiftに

    static func createViewController<T: StoryboardLoadable>() -> T {
        let sb = UIStoryboard(name: T.storyboardName, bundle: nil)
        return sb.instantiateInitialViewController() as! T
    }

と加えておきます。どこかに以下のプロトコル適用を書いておきます。場所はどこでも良いですが、ArticleViewController.swiftに書いておきます。

    // MARK - StoryboardLoadable
    extension UIViewController: StoryboardLoadable {}

さきほどの関数もこのようにスッキリします。このようにプロトコルを利用する方法を取り入れていきましょう。

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let next: ArticleDetailViewController = Utils.createViewController()
            next.article = articles![indexPath.row]
            navigationController?.pushViewController(next, animated: true)

    }

## Tabの利用

今はまだタブがなく記事一覧ページがいきなり出てくるだけなのでタブを取り入れてコンテンツを増やしていきたいと思います。

Main.storyboardにTabBarControllerを追加します。デフォルトで2つのViewControllerがついてきますが、これらを削除します。NavigationControllerとArticleViewControllerをコピーしてこれらも削除します。次にArticle.storyboardを作成し、その中に先ほどコピーした2つのViewControllerをペーストします。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/27.png)

`Main.storyboard`には`TabBarController`ひとつが残っているようにしたら、これに`Is Initial View Controller`の設定をしておきます。`Article.storyboard`の`NavigationController`にも同じように設定します。基本的に各storyboardには必ず`Is Initial View Controller`をつけたStoryboardが存在するようにしなければなりません。

次は、`Article.storyboard`の`NavigationController`に対応する`ViewController`を作成しなければなりません。`ArticleContainerViewController`とします。各Tabに1つ`ContainerViewController`を対応させる必要があります。`ContainerViewController`というフォルダを作成して、その中に`ContainerViewController`を追加していきましょう。新規作成で`CocoaTouchClass`で`UINavigationController`を継承した`ArticleContainerViewController`を作ります。そして下の画面のように`NavigationController`と関連付けをしておきましょう。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/28.png)

`ArticleContainerViewController`は以下のように少しだけメソッドを付け足しておきます。

    import UIKit

    class ArticleContainerViewController: UINavigationController {
    
        var statusBarStyle: UIStatusBarStyle = UIStatusBarStyle.Default
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
    
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        override func preferredStatusBarStyle() -> UIStatusBarStyle {
            return statusBarStyle
        }
    
    }

次は、`Main.storyboard`に対応する`ViewController`を作成します。`MainTabBarController`を先ほどの`ContainerViewController`のディレクトリに作成します。`CocoatouchClass`から`UITabBarController`を選択すると良いです。そしてStoryboardで関連付けもしておきましょう。

![MainStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/29.png)

`MainTabBarController`にまず、イニシャライザを記述します。

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBar.translucent = true
    }
    
次に、viewDidLoadでTabに入れるべき`Viewcontroller`を指定します。

    override func viewDidLoad() {
    
        let articleStoryboard = UIStoryboard(name: "Article", bundle: nil)
        let articleViewController = articleStoryboard.instantiateInitialViewController() as! ArticleContainerViewController
        let viewControllers = [articleViewController]
        self.setViewControllers(viewControllers, animated: false)
        super.viewDidLoad()
    
    }

`super.viewDidLoad`の位置に注意しましょう。

![デモ](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/30.png)

今のところTabのアイコンが変なのでここの編集をしていきます。アイコン等の画像は基本的に`Assets.xcassets`というフォルダがデフォルトで存在するのでそこに追加していきます。（ホームなどの画像はMARBLEのRsourcesというフォルダに入っていると思うのでそこからダウンロードすると良いでしょう。）1x, 2x, 3xは解像度が異なります。AppIconを設定することでアプリのアイコンを登録できます。

![xcassetを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/32.png)

TabBarItemを`Article.storyboard`に挿入します。
![ArticleStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/31.png)

さきほど登録したホームアイコンをStoryboardで設定します。デフォルトで備わっているアイコンであればSystem Iconから選択できます。

![ArticleStoryboardを編集](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/33.png)

他に必要なTab（Search, Like, Mypage）も付け足します。Storyboard、ViewController、ContainerViewControllerを作成して`MainTabBarController`に追加分のViewControllerを書いていきます。

手順をもう一度簡単にまとめると以下のようになります。

新規作成でStoryboardを作ります。`ViewController`を追加、ツールバーの`Editor/EmbedIn/NavigationController`でNavigationControllerを追加します。今できた2つのViewControllerのそれぞれに対応するViewControllerを作成します（e.g. `Search.storyboard`, `SearchViewController.swift`, `SearchContainerViewController.swift`）。この時StoryboardとViewControllerの関連付け、`IsInitialViewController`の設定、NavigationControllerにTabBarItemの追加を忘れないようにしましょう。

![タブ完成](https://raw.github.com/wiki/ngo275/Marble-kenshu/images/34.png)


## お気に入り機能の実装

記事詳細ページに適当なボタンを設置してそれをタップするとLikeでき、Likeページに行くとLikeした記事の一覧を見れる、というお気に入り機能を実装します。


## 最後にgithubに公開

ここまでで作成したappをgithubに公開するときの注意点を述べておきます。xcodeの作業分をFinderで確認するとディレクトリがなく全て同じ階層に作成されているはずです。xcodeのプロジェクト構成とFinderのプロジェクト構成を動機する必要があります。でないとgitに反映されるのはFinderと同じディレクトリ構成なので新規にグループを作ったはずなのに反映されていない、というワナにはまってしまいます。

`http://s31o3.hatenablog.com/entry/2015/03/27/151432`

を参考にしてsynxというツールをインストールしましょう。`git add .`する前にこれでxcodeとFinderを同期しておきましょう。


