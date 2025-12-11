CloudFormation を爆速で基礎 → 中級へ到達するための 1 枚紙ロードマップ
0. 前提（CLF レベルからのスタート）
あなたはすでに AWS の基本概念（VPC・EC2・RDS・IAM など）は理解している前提。
CloudFormation を最短で習得するには「構文より、設計・実践・反復」が鍵。

1. ゴール設定（最短ルート）

■ 初級クリア（約 1〜2 週間）
CloudFormation の基本構成要素（Parameters / Resources / Outputs）を理解
組み込み関数（!Ref / !Sub / !GetAtt）が使える
EC2＋VPC のテンプレートが 1 つ書ける

■ 中級クリア（約 3〜6 週間）
スタック分割設計（VPCとAppとDBを分ける）ができる
Export / ImportValue によるスタック間連携ができる
Fn::ForEach を使ってリソースのループ生成ができる
ChangeSet（差分） を読める
Replace（置換）される条件が理解できる

2. CloudFormation 基礎（最初に覚えるべき最小要素）
■ テンプレートの 5 要素（超重要）
AWSTemplateFormatVersion:
Description:
Parameters:
Resources:   ← 最重要
Outputs:

■ 初心者が覚える組み込み関数（３つだけでいい）
関数	できること
!Ref	パラメータ or リソース ID を参照
!GetAtt	リソースの属性（DNS, ARN, Endpoint）を取得
!Sub	文字列に値を埋め込む（"${Env}-vpc"）
※ 初級はこの 3 つで十分。

3. 基礎 → 中級へ進む「最短ルート式 学習ロードマップ」

STEP 1：最小構成テンプレートを書いて動かす（基礎）
作るもの：
VPC 1つ + Subnet 1つ + EC2 1つ
学ぶこと：
Resources
Parameters
!Ref, !Sub
Outputs（人間向け）
学習方法：
実際に AWS Console の「CFn → スタック作成」で動かしてみる
AMI ID 変更して Replace が発生することを確認

STEP 2：テンプレートを分割し、スタック間連携を理解（初級 → 中級入口）
作るもの：
network.yaml（VPC / Subnet など）
app.yaml（EC2）
学ぶこと：
Outputs の Export
別テンプレートで ImportValue
**「スタック設計が IaC の本質」**という概念
例：
Outputs:
  PublicSubnetA:
    Value: !Ref PublicSubnetA
    Export:
      Name: "myapp-SubnetA"

STEP 3：RDS を追加し、「属性参照」!GetAtt を理解（中級の基礎）
作るもの：
DB スタックを追加
EC2 から RDS の Endpoint を参照
学ぶこと：
!GetAtt DB.Endpoint.Address
セキュリティグループの依存関係理解
Export/Import の理解が強化される
STEP 4：複数リソースをループで生成（中級の壁を突破）
使うもの：
Transform: AWS::LanguageExtensions
Fn::ForEach
作るもの：
Subnet ×2 を ForEach で生成
EC2 ×2 を ForEach で生成
学ぶこと：
DRY（Don’t Repeat Yourself）な設計
List<String> パラメータ構造
テンプレートの行数削減
これができると「中級者」と名乗れる。
STEP 5：実務で必須の「安全なデプロイ」を理解（中級仕上げ）
学ぶこと：
ChangeSet（差分）を読めること
Replace が発生する条件
VPC / Subnet の CIDR
AMI
RDS の一部 property
スタック更新時のリスクを評価できる
Replace が理解できたら、実務で CFn を触れるレベル。
4. 爆速で実力を伸ばすための「練習カリキュラム」
① 毎日 1 つテンプレートを写経する（〜10分で良い）
対象：
VPC
EC2
SG
ALB
RDS
写経 → デプロイ → 削除
の反復回数が「習熟度」を決める。
② 「Before → After」変換練習
以下の改善を繰り返す：
Before：
ベタ書き
変数なし
Suppose 値の羅列
After：
Parameters
!Sub
!Ref
Outputs
ForEach
この変換を 10 回やると中級に到達する。
③ Cursor / VSCode + CFn Lint を使った反復
cfn-lint を導入し、エラーを潰す
Cursor に差分を書かせて改善
コード生成ではなく「修正依頼」が効果的
5. 中級へ到達したと判断できるチェックリスト
項目	YES なら中級
スタックを VPC / App / DB に分割して設計できる	○
Export / ImportValue を正しく使える	○
ForEach で複数リソースを自動生成できる	○
ChangeSet を読んで Replace の有無を判定できる	○
Parameters / Mappings / Conditions を使い分けできる	○
手書きで VPC〜EC2〜RDS を全部 CFn にできる	○
6. 結論：CloudFormationは「テンプレ作成 → スタック分割 → ForEach」で中級になる
強調ポイント：
CloudFormation は YAML の書き方を覚えるだけでは弱い
スタック設計スキルこそ中級者の必須能力
ForEach を覚えると一気に世界が変わる
ChangeSet 読解力が実務での事故防止の鍵
CLF レベルからでも、
上記ロードマップを 4〜6 週間で実施すれば、
十分に CloudFormation 中級者 に到達できる。