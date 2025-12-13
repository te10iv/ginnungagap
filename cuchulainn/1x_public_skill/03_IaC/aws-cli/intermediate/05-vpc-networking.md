# 05. VPC・ネットワーク操作

VPC、Subnet、セキュリティグループの管理

---

## 🎯 学習目標

- VPCとSubnetを作成・管理できる
- セキュリティグループを設定できる
- ルートテーブルを管理できる
- VPCピアリングを設定できる

**所要時間**: 60分

---

## 🌐 VPC操作

### VPC一覧の確認

```bash
# VPC一覧
aws ec2 describe-vpcs

# VPC IDと名前のみ表示
aws ec2 describe-vpcs \
  --query 'Vpcs[*].{
    ID:VpcId,
    CIDR:CidrBlock,
    Name:Tags[?Key==`Name`].Value|[0]
  }' \
  --output table
```

---

### VPC作成

```bash
# VPC作成
vpc_id=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

echo "Created VPC: $vpc_id"

# DNSホスト名を有効化
aws ec2 modify-vpc-attribute \
  --vpc-id "$vpc_id" \
  --enable-dns-hostnames

# タグ追加
aws ec2 create-tags \
  --resources "$vpc_id" \
  --tags Key=Name,Value=MyVPC
```

---

### VPC削除

```bash
# VPC削除
aws ec2 delete-vpc --vpc-id vpc-xxxxx
```

---

## 🗂️ Subnet操作

### Subnet一覧の確認

```bash
# すべてのSubnet
aws ec2 describe-subnets

# 特定VPCのSubnet
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-xxxxx"

# Subnet情報を整形
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-xxxxx" \
  --query 'Subnets[*].{
    ID:SubnetId,
    CIDR:CidrBlock,
    AZ:AvailabilityZone,
    Name:Tags[?Key==`Name`].Value|[0]
  }' \
  --output table
```

---

### Subnet作成

```bash
# PublicSubnet作成
public_subnet=$(aws ec2 create-subnet \
  --vpc-id "$vpc_id" \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ap-northeast-1a \
  --query 'Subnet.SubnetId' \
  --output text)

# パブリックIP自動割り当てを有効化
aws ec2 modify-subnet-attribute \
  --subnet-id "$public_subnet" \
  --map-public-ip-on-launch

# タグ追加
aws ec2 create-tags \
  --resources "$public_subnet" \
  --tags Key=Name,Value=PublicSubnet-1a

# PrivateSubnet作成
private_subnet=$(aws ec2 create-subnet \
  --vpc-id "$vpc_id" \
  --cidr-block 10.0.10.0/24 \
  --availability-zone ap-northeast-1a \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags \
  --resources "$private_subnet" \
  --tags Key=Name,Value=PrivateSubnet-1a
```

---

## 🔐 セキュリティグループ

### セキュリティグループ一覧

```bash
# すべてのSG
aws ec2 describe-security-groups

# 特定VPCのSG
aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=vpc-xxxxx"

# SG情報を整形
aws ec2 describe-security-groups \
  --query 'SecurityGroups[*].{
    ID:GroupId,
    Name:GroupName,
    Description:Description
  }' \
  --output table
```

---

### セキュリティグループ作成

```bash
# SG作成
sg_id=$(aws ec2 create-security-group \
  --group-name web-server-sg \
  --description "Security group for web servers" \
  --vpc-id "$vpc_id" \
  --query 'GroupId' \
  --output text)

echo "Created Security Group: $sg_id"
```

---

### インバウンドルール追加

```bash
# SSH (22) を許可
aws ec2 authorize-security-group-ingress \
  --group-id "$sg_id" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# HTTP (80) を許可
aws ec2 authorize-security-group-ingress \
  --group-id "$sg_id" \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# HTTPS (443) を許可
aws ec2 authorize-security-group-ingress \
  --group-id "$sg_id" \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# 複数ポートを一度に追加
aws ec2 authorize-security-group-ingress \
  --group-id "$sg_id" \
  --ip-permissions \
    IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=0.0.0.0/0}]' \
    IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges='[{CidrIp=0.0.0.0/0}]'
```

---

### アウトバウンドルール追加

```bash
# すべてのトラフィックを許可（デフォルト）
aws ec2 authorize-security-group-egress \
  --group-id "$sg_id" \
  --protocol -1 \
  --cidr 0.0.0.0/0
```

---

### ルール削除

```bash
# インバウンドルール削除
aws ec2 revoke-security-group-ingress \
  --group-id "$sg_id" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

---

### ルール詳細確認

```bash
# インバウンドルール詳細
aws ec2 describe-security-groups \
  --group-ids "$sg_id" \
  --query 'SecurityGroups[*].IpPermissions[*].{
    Protocol:IpProtocol,
    FromPort:FromPort,
    ToPort:ToPort,
    CIDR:IpRanges[*].CidrIp
  }' \
  --output table
```

---

## 🚪 Internet Gateway

### Internet Gateway作成

```bash
# IGW作成
igw_id=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

# VPCにアタッチ
aws ec2 attach-internet-gateway \
  --internet-gateway-id "$igw_id" \
  --vpc-id "$vpc_id"

# タグ追加
aws ec2 create-tags \
  --resources "$igw_id" \
  --tags Key=Name,Value=MyIGW
```

---

## 🗺️ ルートテーブル

### ルートテーブル一覧

```bash
# ルートテーブル一覧
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$vpc_id"
```

---

### ルートテーブル作成

```bash
# パブリック用ルートテーブル作成
rt_id=$(aws ec2 create-route-table \
  --vpc-id "$vpc_id" \
  --query 'RouteTable.RouteTableId' \
  --output text)

# デフォルトルート追加（0.0.0.0/0 → IGW）
aws ec2 create-route \
  --route-table-id "$rt_id" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "$igw_id"

# Subnetに関連付け
aws ec2 associate-route-table \
  --route-table-id "$rt_id" \
  --subnet-id "$public_subnet"

# タグ追加
aws ec2 create-tags \
  --resources "$rt_id" \
  --tags Key=Name,Value=PublicRouteTable
```

---

## 🔗 VPCピアリング

### ピアリング接続作成

```bash
# ピアリング接続作成
pcx_id=$(aws ec2 create-vpc-peering-connection \
  --vpc-id vpc-xxxxx \
  --peer-vpc-id vpc-yyyyy \
  --query 'VpcPeeringConnection.VpcPeeringConnectionId' \
  --output text)

# ピアリング承認
aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id "$pcx_id"

# タグ追加
aws ec2 create-tags \
  --resources "$pcx_id" \
  --tags Key=Name,Value=VPC-Peering
```

---

### ルート追加（ピアリング用）

```bash
# VPC Aのルートテーブルにルート追加
aws ec2 create-route \
  --route-table-id rtb-xxxxx \
  --destination-cidr-block 10.1.0.0/16 \
  --vpc-peering-connection-id "$pcx_id"

# VPC Bのルートテーブルにルート追加
aws ec2 create-route \
  --route-table-id rtb-yyyyy \
  --destination-cidr-block 10.0.0.0/16 \
  --vpc-peering-connection-id "$pcx_id"
```

---

## 🛠️ 実践スクリプト

### スクリプト: VPC環境の自動構築

```bash
#!/bin/bash
set -euo pipefail

# 設定
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.10.0/24"
AZ="ap-northeast-1a"

echo "=== Creating VPC Environment ==="

# VPC作成
echo "Creating VPC..."
vpc_id=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --query 'Vpc.VpcId' --output text)
aws ec2 modify-vpc-attribute --vpc-id "$vpc_id" --enable-dns-hostnames
aws ec2 create-tags --resources "$vpc_id" --tags Key=Name,Value=MyVPC
echo "VPC created: $vpc_id"

# Internet Gateway作成
echo "Creating Internet Gateway..."
igw_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id"
aws ec2 create-tags --resources "$igw_id" --tags Key=Name,Value=MyIGW
echo "IGW created: $igw_id"

# Public Subnet作成
echo "Creating Public Subnet..."
public_subnet=$(aws ec2 create-subnet --vpc-id "$vpc_id" --cidr-block "$PUBLIC_SUBNET_CIDR" --availability-zone "$AZ" --query 'Subnet.SubnetId' --output text)
aws ec2 modify-subnet-attribute --subnet-id "$public_subnet" --map-public-ip-on-launch
aws ec2 create-tags --resources "$public_subnet" --tags Key=Name,Value=PublicSubnet
echo "Public Subnet created: $public_subnet"

# Private Subnet作成
echo "Creating Private Subnet..."
private_subnet=$(aws ec2 create-subnet --vpc-id "$vpc_id" --cidr-block "$PRIVATE_SUBNET_CIDR" --availability-zone "$AZ" --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources "$private_subnet" --tags Key=Name,Value=PrivateSubnet
echo "Private Subnet created: $private_subnet"

# Public Route Table作成
echo "Creating Public Route Table..."
rt_id=$(aws ec2 create-route-table --vpc-id "$vpc_id" --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id "$rt_id" --destination-cidr-block 0.0.0.0/0 --gateway-id "$igw_id"
aws ec2 associate-route-table --route-table-id "$rt_id" --subnet-id "$public_subnet"
aws ec2 create-tags --resources "$rt_id" --tags Key=Name,Value=PublicRouteTable
echo "Route Table created: $rt_id"

# Security Group作成
echo "Creating Security Group..."
sg_id=$(aws ec2 create-security-group --group-name web-sg --description "Web Server SG" --vpc-id "$vpc_id" --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 443 --cidr 0.0.0.0/0
echo "Security Group created: $sg_id"

echo ""
echo "=== VPC Environment Created ==="
echo "VPC ID: $vpc_id"
echo "Public Subnet ID: $public_subnet"
echo "Private Subnet ID: $private_subnet"
echo "Security Group ID: $sg_id"
```

---

## ✅ このレッスンのチェックリスト

- [ ] VPCとSubnetを作成できる
- [ ] セキュリティグループを設定できる
- [ ] ルートテーブルを管理できる
- [ ] Internet Gatewayを設定できる
- [ ] VPCピアリングを理解している

---

## 📚 次のステップ

次は **[06. 実務自動化Tips](06-automation-tips.md)** で、実務ノウハウを学びます！

---

**VPC・ネットワーク操作をマスターしました！🚀**
