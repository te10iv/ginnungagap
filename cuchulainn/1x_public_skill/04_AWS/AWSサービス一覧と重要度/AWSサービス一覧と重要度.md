
# A群 よく使われるサービス、主要サービス

- 詳細まで知れば知るほど良い
    - 手でもコードでも使いこなせるようにするべき  

| 群 | サービス名 | 分類 | サービス概要（1行） |
|----|-------------|--------|-------------------------|
| A | EC2 | Compute | 仮想サーバを起動・管理できる AWS の基盤サービス |
| A | Auto Scaling | Compute | 負荷に応じて EC2 台数を自動増減 |
| A | Elastic Load Balancing（ALB/NLB） | Compute | トラフィックを複数サーバへ分散 |
| A | Lambda | Compute | サーバ管理不要で関数を実行できるサーバレス基盤 |
| A | ECS | Compute | コンテナを管理・実行するフルマネージドサービス |
| A | ECR | Compute | Docker イメージのプライベートレジストリ |
| A | Fargate | Compute | 基盤管理不要でコンテナを実行できる環境 |
| A | S3 | Storage | 耐久性 11 ナインのオブジェクトストレージ |
| A | S3 Glacier / Archive | Storage | 低コストでデータを長期保管 |
| A | EBS | Storage | EC2 用のブロックストレージ |
| A | EFS | Storage | 複数 EC2 で共有できる NFS ストレージ |
| A | RDS | Database | 各種商用/OSSデータベースのマネージドサービス |
| A | Aurora | Database | 高性能な MySQL/PostgreSQL 互換 DB |
| A | DynamoDB | Database | スケーラブルな NoSQL データベース |
| A | ElastiCache（Redis/Memcached） | Database | インメモリキャッシュで高速化を実現 |
| A | VPC | Network | AWS 内の仮想ネットワークを構成する基礎 |
| A | サブネット（Public / Private） | Network | ネットワーク分割の基本単位 |
| A | Route Table | Network | VPC 内でのルーティング制御 |
| A | Internet Gateway（IGW） | Network | VPC をインターネット接続するためのゲートウェイ |
| A | NAT Gateway | Network | Private サブネットから外部への通信を提供 |
| A | VPC Endpoint（Gateway/Interface） | Network | VPC 内から AWS サービスへ私的接続を提供 |
| A | PrivateLink | Network | 他アカウント/SaaS へプライベート接続 |
| A | Transit Gateway | Network | 多数の VPC/オンプレを一元的に接続するハブ |
| A | Direct Connect | Network | オンプレと AWS を専用線で接続 |
| A | VPN（Site-to-Site VPN） | Network | 拠点間の暗号化トンネル接続 |
| A | Client VPN | Network | 個人端末を AWS VPC へ VPN 接続 |
| A | Route 53 | Network | DNS サービス、ヘルスチェック、ルーティング |
| A | CloudFront | Network | グローバル CDN でキャッシュ配信を高速化 |
| A | API Gateway | Network | REST / WebSocket API を公開・管理 |
| A | Global Accelerator | Network | AWS グローバルネットワークで高速・安定通信 |
| A | IAM | Security | AWS アクセス権限管理の中心 |
| A | KMS | Security | 暗号化鍵管理 |
| A | Secrets Manager | Security | パスワード・認証情報の安全な管理 |
| A | Cognito | Security | 認証/ユーザ管理のマネージドサービス |
| A | WAF | Security | Web アプリを攻撃（SQLi等）から保護 |
| A | Shield Advanced | Security | DDoS からの高度な防御 |
| A | Organizations | Security | 複数アカウントの管理・ガバナンス |
| A | CloudWatch | Monitoring | メトリクス監視・ログ・アラーム |
| A | CloudWatch Logs | Monitoring | アプリケーション/OS のログ管理 |
| A | CloudTrail | Monitoring | API アクションログを記録 |
| A | Config | Monitoring | リソース構成変更を履歴管理 |
| A | Systems Manager（SSM） | Monitoring | パッチ、コマンド、運用自動化 |
| A | Control Tower | Governance | マルチアカウントの初期構成自動化 |
| A | Trusted Advisor | Governance | コスト/セキュリティの改善提案 |
| A | CodeCommit | DevTools | Git リポジトリ管理 |
| A | CodeBuild | DevTools | ソースコードのビルド |
| A | CodeDeploy | DevTools | EC2/Lambda/ECS へのデプロイ自動化 |
| A | CodePipeline | DevTools | CI/CD パイプラインを構築 |
| A | SQS | Integration | メッセージキューサービス |
| A | SNS | Integration | プッシュ通知・Pub/Sub |
| A | EventBridge | Integration | SaaS/サービス間イベント連携 |
| A | Step Functions | Integration | ワークフローの状態管理 |
| A | Athena | Analytics | S3 のデータに SQL でクエリ可能 |


# B群 使えると良いサービス(約90)


- 概要だけよりは、知っておいた方が良い
    - （どれくらいできるとよい？）
    - 名前／用途／どこで使うか を理解しておくと即戦力

| 群 | サービス名 | 分類 | サービス概要（1行） |
|----|-------------|--------|-------------------------|
| B | Lightsail | Compute | 小規模サイト向けの簡易VPS |
| B | Batch | Compute | 大量のバッチ処理を自動最適化 |
| B | Elastic Beanstalk | Compute | アプリをサーバレス風にデプロイできるPaaS |
| B | EKS | Compute | Kubernetesのマネージドサービス |
| B | Outposts | Compute | AWSハードウェアをオンプレに設置できる |
| B | Local Zones | Compute | 都市近郊にある低レイテンシAWSロケーション |
| B | Wavelength | Compute | 5G向け超低レイテンシAWSエッジ |
| B | FSx for Windows File Server | Storage | SMB/AD対応のWindows向け共有ストレージ |
| B | FSx for Lustre | Storage | HPC向けの超高速ファイルシステム |
| B | FSx for NetApp ONTAP | Storage | NetApp互換のファイルストレージ |
| B | FSx for OpenZFS | Storage | ZFSベースの高性能ストレージ |
| B | AWS Backup | Storage | AWS横断でバックアップ管理 |
| B | Storage Gateway | Storage | オンプレとS3を接続するハイブリッド基盤 |
| B | DocumentDB | Database | MongoDB互換のマネージドDB |
| B | Neptune | Database | グラフ構造データベース |
| B | Keyspaces | Database | Cassandra互換のNoSQL DB |
| B | Timestream | Database | IoT向けの時系列データベース |
| B | QLDB | Database | 改ざん不可能な元帳型データベース |
| B | ElastiCache Serverless | Database | Redis/Memcachedをサーバレスで利用可能 |
| B | VPC Lattice | Network | サービス間通信を統合管理する新世代ネットワーク |
| B | VPC Endpoint Services | Network | PrivateLinkベースの独自サービス公開 |
| B | VPC Peering | Network | 2つのVPCを直接接続する仕組み |
| B | Direct Connect Gateway | Network | DXで複数VPCを接続 |
| B | VPN CloudHub | Network | 複数VPN拠点をハブ接続 |
| B | Network Firewall | Network | フルマネージドのL3/L4ファイアウォール |
| B | Route 53 Resolver | Network | DNSフォワーダー／アウトバウンドDNS |
| B | Route 53 ARC（Recovery Controller） | Network | アプリ障害時のフェイルオーバー制御 |
| B | App Mesh | Network | マイクロサービス向けサービスメッシュ |
| B | Private NAT Gateway | Network | 高可用性のNATサービス（AZ単位） |
| B | Firewall Manager | Security | 組織全体のWAF/NFWルール管理 |
| B | Inspector | Security | EC2やLambdaの脆弱性スキャン |
| B | Macie | Security | S3内の機密データ（PII）を自動検出 |
| B | Detective | Security | セキュリティ調査分析向けの可視化ツール |
| B | IAM Identity Center (AWS SSO) | Security | 複数AWSアカウントへのSSO認証 |
| B | Certificate Manager | Security | 無料SSL証明書の発行・管理 |
| B | Verified Access | Security | ゼロトラストなアクセス制御基盤 |
| B | Systems Manager Patch Manager | Ops | OSパッチ適用を自動化 |
| B | Systems Manager Session Manager | Ops | EC2へSSH不要で接続する仕組み |
| B | Systems Manager Automation | Ops | 運用手順の自動化 |
| B | Systems Manager Parameter Store | Ops | 設定値やシークレットの管理 |
| B | Application Insights | Ops | アプリの問題を自動で検出 |
| B | AWS Health Dashboard | Ops | AWS全体の障害・メンテ情報 |
| B | Managed Grafana | Ops | Grafanaのマネージド提供 |
| B | Managed Prometheus | Ops | Prometheus互換の監視ソリューション |
| B | Cloud9 | DevTools | ブラウザベースのIDE |
| B | X-Ray | DevTools | アプリのトレース・依存分析 |
| B | AppConfig | DevTools | 設定値のバージョン管理とロールアウト |
| B | CodeGuru Reviewer | DevTools | AIによるコードレビュー |
| B | CodeWhisperer | DevTools | AIコーディング支援 |
| B | CloudShell | DevTools | ブラウザ上のAWS CLI実行環境 |
| B | AppSync | Integration | GraphQL API バックエンド |
| B | Amazon MQ | Integration | RabbitMQ/ActiveMQのマネージド版 |
| B | SWF（Simple Workflow） | Integration | 複雑ワークフローの調整サービス |
| B | Data Exchange | Integration | データマーケットプレイス |
| B | M2（Mainframe Modernization） | Migration | メインフレーム移行サービス |
| B | Glue | Analytics | データETL（抽出・変換・ロード） |
| B | Glue Data Catalog | Analytics | データのメタデータ管理 |
| B | Kinesis Data Streams | Analytics | リアルタイムデータ処理ストリーム |
| B | Kinesis Firehose | Analytics | データをS3/Redshift等に自動転送 |
| B | Kinesis Data Analytics | Analytics | リアルタイムSQL分析 |
| B | Redshift | Analytics | DWH（データウェアハウス） |
| B | Redshift Serverless | Analytics | サーバレスDWH |
| B | QuickSight | Analytics | BI可視化ダッシュボード |
| B | OpenSearch Service | Analytics | 検索エンジン & 分析可視化 |
| B | SageMaker | AI/ML | 機械学習モデルの開発・学習・デプロイ |
| B | Rekognition | AI/ML | 画像認識API |
| B | Transcribe | AI/ML | 音声→テキスト変換 |
| B | Polly | AI/ML | テキスト→音声合成 |
| B | Translate | AI/ML | 翻訳サービス |
| B | Comprehend | AI/ML | 自然言語処理 |
| B | Lex | AI/ML | チャットボット作成 |
| B | Personalize | AI/ML | レコメンドエンジン |
| B | Forecast | AI/ML | 時系列予測モデル |
| B | IoT Core | IoT | デバイス接続基盤 |
| B | IoT Analytics | IoT | IoTデータ分析基盤 |
| B | IoT Events | IoT | デバイスイベントの処理 |
| B | IoT SiteWise | IoT | 設備データの収集・可視化 |
| B | Greengrass | IoT | エッジ側のIoT処理 |
| B | WorkSpaces | Business | 仮想デスクトップ（VDI） |
| B | WorkMail | Business | メール & カレンダー |
| B | AppStream 2.0 | Business | アプリケーションのストリーミング |
| B | Amazon Connect | Business | コールセンター基盤 |
| B | Chime SDK | Business | 音声/ビデオ通話組み込みSDK |
| B | DMS | Migration | データベース移行 |
| B | Application Migration Service | Migration | オンプレサーバをAWSへ移行 |
| B | DataSync | Migration | ストレージ間ファイル転送 |
| B | Transfer Family（SFTP/FTPS/FTP） | Migration | SFTP/FTPのマネージド転送サービス |
| B | GameLift | Game | ゲームサーバホスティング |
| B | RoboMaker | Robotics | ロボットアプリ開発 |
| B | Ground Station | Satellite | 衛星通信データの受信 |
| B | SimSpace Weaver | Simulation | 大規模空間シミュレーション |
| B | Braket | Quantum | 量子計算サービス |


# C群 とりあえず概要だけ知っていれば良いサービス

- とりあえず概要だけ知っていれば良い
    - （かかわることになったら必死にキャッチアップ）

現場でたまにしか使わない
案件で必要になったときに調べればOK
名前＋分類＋一言概要を押さえるだけで十分

| 群 | サービス名 | 分類 | サービス概要（1行） |
|----|-------------|--------|-------------------------|
| C | Serverless Application Repository | Compute | サーバレスアプリを共有・再利用できるリポジトリ |
| C | Bottlerocket OS | Compute | コンテナ向けの軽量Linux OS |
| C | Snowball Edge | Compute | 物理デバイスで大量データをAWSへ物理転送 |
| C | Snowcone | Compute | 小型で堅牢なエッジコンピューティングデバイス |
| C | Snowmobile | Compute | トレーラー級の物理デバイスで大量データ移行 |
| C | Elastic GPU | Compute | EC2にGPUを追加できるオプション |
| C | ParallelCluster | Compute | HPCクラスターの自動構築ツール |
| C | App2Container | Compute | 既存アプリをコンテナ化する支援ツール |
| C | Elastic Inference | Compute | 推論処理向けのコスト最適化GPU |
| C | S3 Outposts | Storage | Outposts上のローカルS3 |
| C | Data Lifecycle Manager | Storage | EBSスナップショットのライフサイクル管理 |
| C | Cloud Control API | Storage | AWS外からも利用できる統一API |
| C | RDS Proxy | Database | RDSへのコネクションプーリング |
| C | RDS Custom | Database | Oracle/SQL Serverをカスタム制御 |
| C | MemoryDB for Redis | Database | Redis互換の耐久性NoSQL |
| C | Babelfish for Aurora | Database | AuroraでT-SQLを利用可能に |
| C | Neptune ML | Database | グラフDB向けの機械学習 |
| C | Cloud WAN | Network | グローバルWAN接続を簡易管理 |
| C | Route 53 Resolver DNS Firewall | Network | DNSベースの通信制御 |
| C | IPv6 Transit Gateway | Network | IPv6トラフィックのハブ接続 |
| C | Direct Connect SiteLink | Network | DXロケーション間の直接接続 |
| C | IPAM（Address Manager） | Network | IPアドレス管理ツール |
| C | Network Manager | Network | SD-WAN/VPN/DXの一元管理 |
| C | Resource Access Manager (RAM) | Network | VPC等を他アカウントへ共有する仕組み |
| C | Audit Manager | Security | 監査証跡の集約/レポート作成 |
| C | Artifact | Security | AWSのコンプライアンス文書提供 |
| C | IAM Access Analyzer | Security | 権限の公開リスクを検知 |
| C | Detective for EKS | Security | EKSの異常動作調査ツール |
| C | GuardDuty Malware Protection | Security | EC2/EBSのマルウェア検査 |
| C | Network Firewall Logging | Security | NFWのログ管理 |
| C | Well-Architected Tool | Governance | アーキテクチャの評価ツール |
| C | CloudWatch Evidently | Monitoring | A/Bテスト機能 |
| C | CloudWatch RUM | Monitoring | Web/モバイルの実ユーザー監視 |
| C | AWS Chatbot | Monitoring | Slack/TeamsからAWS操作 |
| C | Application Composer | DevTools | サーバレス構成をGUIで設計 |
| C | Launch Wizard | DevTools | SAP/Microsoft等の導入支援 |
| C | CodeArtifact | DevTools | パッケージ管理リポジトリ |
| C | Device Farm | DevTools | 実機モバイル端末でアプリ検証 |
| C | Fault Injection Simulator | DevTools | 障害注入テスト（カオスエンジニアリング） |
| C | SES（Simple Email Service） | Integration | メール送信プラットフォーム |
| C | Step Functions Express | Integration | 大量イベント向け高速ワークフロー |
| C | Managed Blockchain | Integration | ブロックチェーン構築サービス |
| C | EventBridge Pipes | Integration | イベントをコードなしで連携可能 |
| C | Data Pipeline（旧/非推奨） | Integration | バッチデータ処理フロー管理 |
| C | Elastic Transcoder（非推奨） | Media | メディア変換サービス |
| C | WorkDocs | Business | ドキュメント共有（OneDrive類似） |
| C | Honeycode | Business | ノーコード業務アプリ作成 |
| C | WorkSpaces Web | Business | ブラウザのみでVDI利用 |
| C | Wickr | Business | 暗号化メッセージング |
| C | Backup Audit Manager | Business | バックアップ設定の監査 |
| C | Nimble Studio | Media | 映像制作向けコラボ基盤 |
| C | Thinkbox Deadline | Media | レンダリング管理ツール |
| C | Thinkbox Krakatoa | Media | 3Dパーティクル制作ツール |
| C | Elemental MediaConvert | Media | 動画の変換/トランスコード |
| C | Elemental MediaLive | Media | ライブ動画配信エンコード |
| C | Elemental MediaPackage | Media | 動画配信パッケージング |
| C | Elemental MediaStore | Media | 動画配信向け低レイテンシストレージ |
| C | Elemental MediaTailor | Media | 広告挿入（サーバサイドAd Insertion） |
| C | Lake Formation | Analytics | データレイクの権限管理 |
| C | DataBrew | Analytics | ノーコードでデータ前処理 |
| C | EMR | Analytics | Hadoop/Sparkのマネージドクラスタ |
| C | EMR Serverless | Analytics | サーバレスでSpark実行 |
| C | MSK（Managed Kafka） | Analytics | Kafkaのマネージド提供 |
| C | Lookout for Metrics | AI/ML | 異常検知AI |
| C | Lookout for Equipment | AI/ML | 設備故障の予測 |
| C | Lookout for Vision | AI/ML | 画像の異常検知 |
| C | Kendra | AI/ML | 高度な全文検索AI |
| C | Textract | AI/ML | OCR（書類読み取り） |
| C | HealthLake | AI/ML | 医療データ向けAI |
| C | DeepComposer | AI/ML | AI作曲ツール |
| C | DeepRacer | AI/ML | 自動運転学習カー |
| C | Panorama | AI/ML | エッジAIカメラ |
| C | IoT Device Defender | IoT | IoTデバイスのセキュリティ監査 |
| C | IoT Device Management | IoT | 大量IoTデバイスの管理 |
| C | IoT TwinMaker | IoT | デジタルツイン構築 |
| C | IoT FleetWise | IoT | 車両データ収集基盤 |
| C | Migration Hub | Migration | 移行プロジェクト管理 |
| C | Application Discovery Service | Migration | 移行対象アプリの調査 |
| C | License Manager | Migration | ソフトウェアライセンス管理 |
| C | Resilience Hub | Reliability | 可用性/耐障害性の評価 |
| C | Resource Explorer | General | すべてのAWSリソースを検索 |
| C | Clean Rooms | Analytics | 企業間でデータ共有/分析（秘匿維持） |
| C | Entity Resolution | Analytics | 重複データの名寄せ |
| C | Supply Chain | Business | サプライチェーン管理基盤 |
| C | Verified Permissions | Security | アプリの権限管理を統合 |
| C | Proton | DevTools | サービステンプレート管理 |
| C | CloudFormation Guard | DevTools | IaCのポリシー検証 |
| C | CloudFormation StackSets | DevTools | 複数アカウントへスタック展開 |
| C | CDK（Cloud Development Kit） | DevTools | プログラム言語でIaCを書く |
| C | IQ（AWS IQ） | General | AWS専門家に相談・依頼できる |
| C | Marketplace | General | AWSで使えるソフトのマーケット |





