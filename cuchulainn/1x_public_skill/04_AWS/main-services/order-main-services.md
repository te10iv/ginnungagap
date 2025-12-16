

# 

cursolに各主要サービスの01-overview.mdというwikiを作ってもらったんだけど、 なんだか、頭にスッと入ってこない。 

この先の学習がどうすればよいかわからない。 

たとえば
EC2について、初心者から中級者まで、まずはこれをしればOK！というような知識インプット資料のマークダウンファイルを2−３個作らせたい。 
どうすれば良いと思う？


▼
EC2について、
初心者→中級者向けに

1. EC2_まずこれだけ.md
2. EC2_仕組みと設計の基本.md
3. EC2_運用と実務.md

の3ファイルを作って。
各ファイルは
- ゴール
- 覚えること
- できるようになること
を必ず含めて。


<service-name>/
├── 01_basics.md        ← Lv1：まず触る・全体像
├── 02_design.md        ← Lv2：仕組み・設計
└── 03_operations.md   ← Lv3：運用・実務


03_cloudformation.yaml　→ 11_cloudformation.yamlにリネーム
04_terraform.tf　　→ 12_terraform.tf
05_operations.md →　21_operations.md