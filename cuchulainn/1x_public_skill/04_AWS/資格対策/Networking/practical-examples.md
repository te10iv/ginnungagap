# AWS Advanced Networking Specialty - 実践的な設定例集

実務でそのまま使える設定例とベストプラクティス

---

## 📋 目次

1. [Transit Gateway設計](#1-transit-gateway設計)
2. [Direct Connect設定](#2-direct-connect設定)
3. [ハイブリッドDNS](#3-ハイブリッドdns)
4. [VPN設定](#4-vpn設定)
5. [PrivateLink構築](#5-privatelink構築)

---

## 1. Transit Gateway設計

### 1-1. ハブ&スポークアーキテクチャ

#### CloudFormationテンプレート
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Transit Gateway Hub and Spoke Architecture'

Parameters:
  HubVpcCidr:
    Type: String
    Default: 10.0.0.0/16
  
  Spoke1VpcCidr:
    Type: String
    Default: 10.1.0.0/16
  
  Spoke2VpcCidr:
    Type: String
    Default: 10.2.0.0/16

Resources:
  # Transit Gateway
  TransitGateway:
    Type: AWS::EC2::TransitGateway
    Properties:
      Description: Central Transit Gateway
      DefaultRouteTableAssociation: disable
      DefaultRouteTablePropagation: disable
      DnsSupport: enable
      VpnEcmpSupport: enable
      Tags:
        - Key: Name
          Value: main-tgw

  # Hub VPC
  HubVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref HubVpcCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: hub-vpc

  # Hub VPC サブネット（Transit Gateway用）
  HubTgwSubnetAz1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref HubVPC
      CidrBlock: 10.0.255.0/28
      AvailabilityZone: !Select [0, !GetAZs '']
      Tags:
        - Key: Name
          Value: hub-tgw-subnet-az1

  HubTgwSubnetAz2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref HubVPC
      CidrBlock: 10.0.255.16/28
      AvailabilityZone: !Select [1, !GetAZs '']
      Tags:
        - Key: Name
          Value: hub-tgw-subnet-az2

  # Spoke1 VPC
  Spoke1VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref Spoke1VpcCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: spoke1-vpc

  Spoke1TgwSubnetAz1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref Spoke1VPC
      CidrBlock: 10.1.255.0/28
      AvailabilityZone: !Select [0, !GetAZs '']
      Tags:
        - Key: Name
          Value: spoke1-tgw-subnet-az1

  Spoke1TgwSubnetAz2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref Spoke1VPC
      CidrBlock: 10.1.255.16/28
      AvailabilityZone: !Select [1, !GetAZs '']
      Tags:
        - Key: Name
          Value: spoke1-tgw-subnet-az2

  # Spoke2 VPC
  Spoke2VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref Spoke2VpcCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: spoke2-vpc

  Spoke2TgwSubnetAz1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref Spoke2VPC
      CidrBlock: 10.2.255.0/28
      AvailabilityZone: !Select [0, !GetAZs '']
      Tags:
        - Key: Name
          Value: spoke2-tgw-subnet-az1

  Spoke2TgwSubnetAz2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref Spoke2VPC
      CidrBlock: 10.2.255.16/28
      AvailabilityZone: !Select [1, !GetAZs '']
      Tags:
        - Key: Name
          Value: spoke2-tgw-subnet-az2

  # Transit Gateway Attachments
  HubTgwAttachment:
    Type: AWS::EC2::TransitGatewayAttachment
    Properties:
      TransitGatewayId: !Ref TransitGateway
      VpcId: !Ref HubVPC
      SubnetIds:
        - !Ref HubTgwSubnetAz1
        - !Ref HubTgwSubnetAz2
      Tags:
        - Key: Name
          Value: hub-tgw-attachment

  Spoke1TgwAttachment:
    Type: AWS::EC2::TransitGatewayAttachment
    Properties:
      TransitGatewayId: !Ref TransitGateway
      VpcId: !Ref Spoke1VPC
      SubnetIds:
        - !Ref Spoke1TgwSubnetAz1
        - !Ref Spoke1TgwSubnetAz2
      Tags:
        - Key: Name
          Value: spoke1-tgw-attachment

  Spoke2TgwAttachment:
    Type: AWS::EC2::TransitGatewayAttachment
    Properties:
      TransitGatewayId: !Ref TransitGateway
      VpcId: !Ref Spoke2VPC
      SubnetIds:
        - !Ref Spoke2TgwSubnetAz1
        - !Ref Spoke2TgwSubnetAz2
      Tags:
        - Key: Name
          Value: spoke2-tgw-attachment

  # Transit Gateway ルートテーブル
  HubRouteTable:
    Type: AWS::EC2::TransitGatewayRouteTable
    Properties:
      TransitGatewayId: !Ref TransitGateway
      Tags:
        - Key: Name
          Value: hub-route-table

  SpokeRouteTable:
    Type: AWS::EC2::TransitGatewayRouteTable
    Properties:
      TransitGatewayId: !Ref TransitGateway
      Tags:
        - Key: Name
          Value: spoke-route-table

  # ルートテーブルアソシエーション
  HubRouteTableAssociation:
    Type: AWS::EC2::TransitGatewayRouteTableAssociation
    Properties:
      TransitGatewayAttachmentId: !Ref HubTgwAttachment
      TransitGatewayRouteTableId: !Ref HubRouteTable

  Spoke1RouteTableAssociation:
    Type: AWS::EC2::TransitGatewayRouteTableAssociation
    Properties:
      TransitGatewayAttachmentId: !Ref Spoke1TgwAttachment
      TransitGatewayRouteTableId: !Ref SpokeRouteTable

  Spoke2RouteTableAssociation:
    Type: AWS::EC2::TransitGatewayRouteTableAssociation
    Properties:
      TransitGatewayAttachmentId: !Ref Spoke2TgwAttachment
      TransitGatewayRouteTableId: !Ref SpokeRouteTable

  # ルートテーブルプロパゲーション
  # Hub Route Tableはすべてのスポークからルートを受信
  HubPropagationSpoke1:
    Type: AWS::EC2::TransitGatewayRouteTablePropagation
    Properties:
      TransitGatewayAttachmentId: !Ref Spoke1TgwAttachment
      TransitGatewayRouteTableId: !Ref HubRouteTable

  HubPropagationSpoke2:
    Type: AWS::EC2::TransitGatewayRouteTablePropagation
    Properties:
      TransitGatewayAttachmentId: !Ref Spoke2TgwAttachment
      TransitGatewayRouteTableId: !Ref HubRouteTable

  # Spoke Route TableはHubからルートを受信
  SpokePropagationHub:
    Type: AWS::EC2::TransitGatewayRouteTablePropagation
    Properties:
      TransitGatewayAttachmentId: !Ref HubTgwAttachment
      TransitGatewayRouteTableId: !Ref SpokeRouteTable

  # Spoke Route Tableにデフォルトルート追加（Hub経由）
  SpokeDefaultRoute:
    Type: AWS::EC2::TransitGatewayRoute
    Properties:
      DestinationCidrBlock: 0.0.0.0/0
      TransitGatewayAttachmentId: !Ref HubTgwAttachment
      TransitGatewayRouteTableId: !Ref SpokeRouteTable

Outputs:
  TransitGatewayId:
    Value: !Ref TransitGateway
    Description: Transit Gateway ID
  
  HubVpcId:
    Value: !Ref HubVPC
    Description: Hub VPC ID
  
  Spoke1VpcId:
    Value: !Ref Spoke1VPC
    Description: Spoke1 VPC ID
  
  Spoke2VpcId:
    Value: !Ref Spoke2VPC
    Description: Spoke2 VPC ID
```

---

### 1-2. セグメンテーション（環境分離）

#### CLI設定例
```bash
#!/bin/bash

# 変数設定
TGW_ID="tgw-0123456789abcdef0"
PROD_VPC_ATTACHMENT="tgw-attach-prod-xxxxx"
DEV_VPC_ATTACHMENT="tgw-attach-dev-xxxxx"
SHARED_VPC_ATTACHMENT="tgw-attach-shared-xxxxx"

# ルートテーブル作成
PROD_RT=$(aws ec2 create-transit-gateway-route-table \
  --transit-gateway-id $TGW_ID \
  --tag-specifications 'ResourceType=transit-gateway-route-table,Tags=[{Key=Name,Value=production-rt}]' \
  --query 'TransitGatewayRouteTable.TransitGatewayRouteTableId' \
  --output text)

DEV_RT=$(aws ec2 create-transit-gateway-route-table \
  --transit-gateway-id $TGW_ID \
  --tag-specifications 'ResourceType=transit-gateway-route-table,Tags=[{Key=Name,Value=development-rt}]' \
  --query 'TransitGatewayRouteTable.TransitGatewayRouteTableId' \
  --output text)

SHARED_RT=$(aws ec2 create-transit-gateway-route-table \
  --transit-gateway-id $TGW_ID \
  --tag-specifications 'ResourceType=transit-gateway-route-table,Tags=[{Key=Name,Value=shared-rt}]' \
  --query 'TransitGatewayRouteTable.TransitGatewayRouteTableId' \
  --output text)

# アソシエーション
aws ec2 associate-transit-gateway-route-table \
  --transit-gateway-route-table-id $PROD_RT \
  --transit-gateway-attachment-id $PROD_VPC_ATTACHMENT

aws ec2 associate-transit-gateway-route-table \
  --transit-gateway-route-table-id $DEV_RT \
  --transit-gateway-attachment-id $DEV_VPC_ATTACHMENT

aws ec2 associate-transit-gateway-route-table \
  --transit-gateway-route-table-id $SHARED_RT \
  --transit-gateway-attachment-id $SHARED_VPC_ATTACHMENT

# プロパゲーション（本番環境ルートテーブル）
# 本番VPCと共有VPCのみ
aws ec2 enable-transit-gateway-route-table-propagation \
  --transit-gateway-route-table-id $PROD_RT \
  --transit-gateway-attachment-id $PROD_VPC_ATTACHMENT

aws ec2 enable-transit-gateway-route-table-propagation \
  --transit-gateway-route-table-id $PROD_RT \
  --transit-gateway-attachment-id $SHARED_VPC_ATTACHMENT

# プロパゲーション（開発環境ルートテーブル）
# 開発VPCと共有VPCのみ
aws ec2 enable-transit-gateway-route-table-propagation \
  --transit-gateway-route-table-id $DEV_RT \
  --transit-gateway-attachment-id $DEV_VPC_ATTACHMENT

aws ec2 enable-transit-gateway-route-table-propagation \
  --transit-gateway-route-table-id $DEV_RT \
  --transit-gateway-attachment-id $SHARED_VPC_ATTACHMENT

# プロパゲーション（共有サービスルートテーブル）
# 本番と開発の両方
aws ec2 enable-transit-gateway-route-table-propagation \
  --transit-gateway-route-table-id $SHARED_RT \
  --transit-gateway-attachment-id $PROD_VPC_ATTACHMENT

aws ec2 enable-transit-gateway-route-table-propagation \
  --transit-gateway-route-table-id $SHARED_RT \
  --transit-gateway-attachment-id $DEV_VPC_ATTACHMENT

echo "Transit Gateway segmentation configured successfully"
```

---

## 2. Direct Connect設定

### 2-1. 冗長性の高いDirect Connect構成

#### Terraform設定例
```hcl
# Direct Connect Gateway
resource "aws_dx_gateway" "main" {
  name            = "main-dxgw"
  amazon_side_asn = "64512"
}

# ロケーション1: プライマリ
resource "aws_dx_connection" "primary_location1" {
  name      = "dx-primary-loc1"
  bandwidth = "10Gbps"
  location  = "EqDC2" # 東京Equinix
  
  tags = {
    Name        = "primary-dx-location1"
    Environment = "production"
    Redundancy  = "primary"
  }
}

resource "aws_dx_connection" "primary_location1_backup" {
  name      = "dx-primary-loc1-backup"
  bandwidth = "10Gbps"
  location  = "EqDC2"
  
  tags = {
    Name        = "primary-dx-location1-backup"
    Environment = "production"
    Redundancy  = "primary-backup"
  }
}

# ロケーション2: セカンダリ（別のロケーション）
resource "aws_dx_connection" "secondary_location2" {
  name      = "dx-secondary-loc2"
  bandwidth = "10Gbps"
  location  = "EqOS1" # 大阪Equinix
  
  tags = {
    Name        = "secondary-dx-location2"
    Environment = "production"
    Redundancy  = "secondary"
  }
}

resource "aws_dx_connection" "secondary_location2_backup" {
  name      = "dx-secondary-loc2-backup"
  bandwidth = "10Gbps"
  location  = "EqOS1"
  
  tags = {
    Name        = "secondary-dx-location2-backup"
    Environment = "production"
    Redundancy  = "secondary-backup"
  }
}

# Private VIF - ロケーション1 プライマリ
resource "aws_dx_private_virtual_interface" "primary_loc1" {
  connection_id    = aws_dx_connection.primary_location1.id
  dx_gateway_id    = aws_dx_gateway.main.id
  name             = "private-vif-primary-loc1"
  vlan             = 100
  address_family   = "ipv4"
  bgp_asn          = 65001
  amazon_address   = "169.254.1.1/30"
  customer_address = "169.254.1.2/30"
  bgp_auth_key     = var.bgp_auth_key_loc1_primary
  
  tags = {
    Name = "private-vif-primary-loc1"
  }
}

# Private VIF - ロケーション1 バックアップ
resource "aws_dx_private_virtual_interface" "primary_loc1_backup" {
  connection_id    = aws_dx_connection.primary_location1_backup.id
  dx_gateway_id    = aws_dx_gateway.main.id
  name             = "private-vif-primary-loc1-backup"
  vlan             = 101
  address_family   = "ipv4"
  bgp_asn          = 65001
  amazon_address   = "169.254.2.1/30"
  customer_address = "169.254.2.2/30"
  bgp_auth_key     = var.bgp_auth_key_loc1_backup
  
  tags = {
    Name = "private-vif-primary-loc1-backup"
  }
}

# Private VIF - ロケーション2 セカンダリ
resource "aws_dx_private_virtual_interface" "secondary_loc2" {
  connection_id    = aws_dx_connection.secondary_location2.id
  dx_gateway_id    = aws_dx_gateway.main.id
  name             = "private-vif-secondary-loc2"
  vlan             = 200
  address_family   = "ipv4"
  bgp_asn          = 65001
  amazon_address   = "169.254.3.1/30"
  customer_address = "169.254.3.2/30"
  bgp_auth_key     = var.bgp_auth_key_loc2_primary
  
  tags = {
    Name = "private-vif-secondary-loc2"
  }
}

# Private VIF - ロケーション2 バックアップ
resource "aws_dx_private_virtual_interface" "secondary_loc2_backup" {
  connection_id    = aws_dx_connection.secondary_location2_backup.id
  dx_gateway_id    = aws_dx_gateway.main.id
  name             = "private-vif-secondary-loc2-backup"
  vlan             = 201
  address_family   = "ipv4"
  bgp_asn          = 65001
  amazon_address   = "169.254.4.1/30"
  customer_address = "169.254.4.2/30"
  bgp_auth_key     = var.bgp_auth_key_loc2_backup
  
  tags = {
    Name = "private-vif-secondary-loc2-backup"
  }
}

# Transit Gateway への関連付け
resource "aws_dx_gateway_association" "tgw" {
  dx_gateway_id         = aws_dx_gateway.main.id
  associated_gateway_id = aws_ec2_transit_gateway.main.id
  
  allowed_prefixes = [
    "10.0.0.0/8",
    "172.16.0.0/12"
  ]
}

output "dx_gateway_id" {
  value = aws_dx_gateway.main.id
}

output "private_vif_ids" {
  value = {
    primary_loc1        = aws_dx_private_virtual_interface.primary_loc1.id
    primary_loc1_backup = aws_dx_private_virtual_interface.primary_loc1_backup.id
    secondary_loc2      = aws_dx_private_virtual_interface.secondary_loc2.id
    secondary_loc2_backup = aws_dx_private_virtual_interface.secondary_loc2_backup.id
  }
}
```

---

### 2-2. BGP設定（Cisco IOS例）

#### ルーター設定
```cisco
! BGP設定（ロケーション1 プライマリ）
router bgp 65001
 bgp log-neighbor-changes
 neighbor 169.254.1.1 remote-as 64512
 neighbor 169.254.1.1 password <BGP_AUTH_KEY>
 neighbor 169.254.1.1 timers 10 30
 neighbor 169.254.1.1 timers connect 10
 
 address-family ipv4
  neighbor 169.254.1.1 activate
  neighbor 169.254.1.1 soft-reconfiguration inbound
  neighbor 169.254.1.1 prefix-list TO-AWS out
  neighbor 169.254.1.1 route-map SET-PRIMARY-PATH out
  network 192.168.0.0 mask 255.255.0.0
 exit-address-family

! BGP設定（ロケーション1 バックアップ）
router bgp 65001
 neighbor 169.254.2.1 remote-as 64512
 neighbor 169.254.2.1 password <BGP_AUTH_KEY>
 neighbor 169.254.2.1 timers 10 30
 neighbor 169.254.2.1 timers connect 10
 
 address-family ipv4
  neighbor 169.254.2.1 activate
  neighbor 169.254.2.1 soft-reconfiguration inbound
  neighbor 169.254.2.1 prefix-list TO-AWS out
  neighbor 169.254.2.1 route-map SET-BACKUP-PATH out
  network 192.168.0.0 mask 255.255.0.0
 exit-address-family

! AS-PATH Prepending（バックアップパスの優先度を下げる）
route-map SET-PRIMARY-PATH permit 10
 ! AS-PATHそのまま（最短パス）
 exit

route-map SET-BACKUP-PATH permit 10
 set as-path prepend 65001 65001 65001
 exit

! プレフィックスリスト
ip prefix-list TO-AWS seq 10 permit 192.168.0.0/16

! BFD設定（障害検出の高速化）
interface GigabitEthernet0/0
 bfd interval 300 min_rx 300 multiplier 3
 exit

router bgp 65001
 neighbor 169.254.1.1 fall-over bfd
 neighbor 169.254.2.1 fall-over bfd
 exit
```

---

## 3. ハイブリッドDNS

### 3-1. Route 53 Resolver完全設定

#### CloudFormation
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Route 53 Resolver for Hybrid DNS'

Parameters:
  VpcId:
    Type: AWS::EC2::VPC::Id
  
  InboundSubnet1:
    Type: AWS::EC2::Subnet::Id
  
  InboundSubnet2:
    Type: AWS::EC2::Subnet::Id
  
  OutboundSubnet1:
    Type: AWS::EC2::Subnet::Id
  
  OutboundSubnet2:
    Type: AWS::EC2::Subnet::Id
  
  OnPremDnsServer1:
    Type: String
    Description: On-premises DNS server IP 1
    Default: 10.20.0.53
  
  OnPremDnsServer2:
    Type: String
    Description: On-premises DNS server IP 2
    Default: 10.20.1.53

Resources:
  # セキュリティグループ
  ResolverSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for Route 53 Resolver endpoints
      VpcId: !Ref VpcId
      SecurityGroupIngress:
        # DNS（UDP/TCP）
        - IpProtocol: tcp
          FromPort: 53
          ToPort: 53
          CidrIp: 0.0.0.0/0
        - IpProtocol: udp
          FromPort: 53
          ToPort: 53
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: resolver-sg

  # Inbound Endpoint
  InboundResolverEndpoint:
    Type: AWS::Route53Resolver::ResolverEndpoint
    Properties:
      Name: inbound-resolver-endpoint
      Direction: INBOUND
      SecurityGroupIds:
        - !Ref ResolverSecurityGroup
      IpAddresses:
        - SubnetId: !Ref InboundSubnet1
          Ip: 10.0.1.10
        - SubnetId: !Ref InboundSubnet2
          Ip: 10.0.2.10
      Tags:
        - Key: Name
          Value: inbound-resolver-endpoint

  # Outbound Endpoint
  OutboundResolverEndpoint:
    Type: AWS::Route53Resolver::ResolverEndpoint
    Properties:
      Name: outbound-resolver-endpoint
      Direction: OUTBOUND
      SecurityGroupIds:
        - !Ref ResolverSecurityGroup
      IpAddresses:
        - SubnetId: !Ref OutboundSubnet1
        - SubnetId: !Ref OutboundSubnet2
      Tags:
        - Key: Name
          Value: outbound-resolver-endpoint

  # Resolver Rule（オンプレミスドメイン転送）
  OnPremDomainRule:
    Type: AWS::Route53Resolver::ResolverRule
    Properties:
      Name: onprem-domain-rule
      RuleType: FORWARD
      DomainName: corp.example.com
      ResolverEndpointId: !Ref OutboundResolverEndpoint
      TargetIps:
        - Ip: !Ref OnPremDnsServer1
          Port: 53
        - Ip: !Ref OnPremDnsServer2
          Port: 53
      Tags:
        - Key: Name
          Value: onprem-domain-rule

  # Resolver Rule Association
  RuleAssociation:
    Type: AWS::Route53Resolver::ResolverRuleAssociation
    Properties:
      Name: onprem-rule-association
      ResolverRuleId: !Ref OnPremDomainRule
      VPCId: !Ref VpcId

  # Query Logging（オプション）
  QueryLogConfig:
    Type: AWS::Route53Resolver::ResolverQueryLoggingConfig
    Properties:
      Name: resolver-query-logs
      DestinationArn: !GetAtt QueryLogGroup.Arn

  QueryLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: /aws/route53/resolver-query-logs
      RetentionInDays: 30

  QueryLogConfigAssociation:
    Type: AWS::Route53Resolver::ResolverQueryLoggingConfigAssociation
    Properties:
      ResolverQueryLogConfigId: !Ref QueryLogConfig
      ResourceId: !Ref VpcId

Outputs:
  InboundEndpointIp1:
    Value: 10.0.1.10
    Description: Inbound Endpoint IP Address 1
    Export:
      Name: InboundResolverIp1
  
  InboundEndpointIp2:
    Value: 10.0.2.10
    Description: Inbound Endpoint IP Address 2
    Export:
      Name: InboundResolverIp2
  
  OutboundEndpointId:
    Value: !Ref OutboundResolverEndpoint
    Description: Outbound Resolver Endpoint ID
```

---

### 3-2. オンプレミスDNS設定（BIND例）

#### named.conf
```bind
// AWS Route 53 Resolver への転送設定
zone "aws.example.com" {
    type forward;
    forward only;
    forwarders {
        10.0.1.10;  // Inbound Endpoint IP 1
        10.0.2.10;  // Inbound Endpoint IP 2
    };
};

zone "compute.internal" {
    type forward;
    forward only;
    forwarders {
        10.0.1.10;
        10.0.2.10;
    };
};

// 特定のAWSサービスエンドポイント
zone "amazonaws.com" {
    type forward;
    forward only;
    forwarders {
        10.0.1.10;
        10.0.2.10;
    };
};

// ログ設定
logging {
    channel query_log {
        file "/var/log/named/query.log" versions 3 size 5m;
        severity info;
        print-time yes;
        print-category yes;
        print-severity yes;
    };
    
    category queries { query_log; };
};
```

---

## 4. VPN設定

### 4-1. Site-to-Site VPN with BGP

#### CloudFormation
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Site-to-Site VPN with BGP'

Parameters:
  TransitGatewayId:
    Type: String
    Description: Transit Gateway ID
  
  CustomerGatewayIp:
    Type: String
    Description: Customer Gateway public IP address
    Default: 203.0.113.100
  
  CustomerBgpAsn:
    Type: Number
    Description: Customer BGP ASN
    Default: 65000

Resources:
  # Customer Gateway
  CustomerGateway:
    Type: AWS::EC2::CustomerGateway
    Properties:
      Type: ipsec.1
      BgpAsn: !Ref CustomerBgpAsn
      IpAddress: !Ref CustomerGatewayIp
      Tags:
        - Key: Name
          Value: onprem-cgw

  # VPN Connection
  VpnConnection:
    Type: AWS::EC2::VPNConnection
    Properties:
      Type: ipsec.1
      CustomerGatewayId: !Ref CustomerGateway
      TransitGatewayId: !Ref TransitGatewayId
      VpnTunnelOptionsSpecifications:
        # トンネル1
        - PreSharedKey: !Sub '{{resolve:secretsmanager:vpn-psk-tunnel1:SecretString:password}}'
          TunnelInsideCidr: 169.254.10.0/30
          Phase1DHGroupNumbers: [14, 15, 16, 17, 18, 19, 20, 21]
          Phase2DHGroupNumbers: [14, 15, 16, 17, 18, 19, 20, 21]
          Phase1EncryptionAlgorithms: [AES256, AES128]
          Phase2EncryptionAlgorithms: [AES256, AES128]
          Phase1IntegrityAlgorithms: [SHA2-256, SHA2-384, SHA2-512]
          Phase2IntegrityAlgorithms: [SHA2-256, SHA2-384, SHA2-512]
          IKEVersions: [ikev2]
          DPDTimeoutSeconds: 30
          Phase1LifetimeSeconds: 28800
          Phase2LifetimeSeconds: 3600
          RekeyMarginTimeSeconds: 540
          RekeyFuzzPercentage: 100
          ReplayWindowSize: 1024
          StartupAction: start
        # トンネル2
        - PreSharedKey: !Sub '{{resolve:secretsmanager:vpn-psk-tunnel2:SecretString:password}}'
          TunnelInsideCidr: 169.254.11.0/30
          Phase1DHGroupNumbers: [14, 15, 16, 17, 18, 19, 20, 21]
          Phase2DHGroupNumbers: [14, 15, 16, 17, 18, 19, 20, 21]
          Phase1EncryptionAlgorithms: [AES256, AES128]
          Phase2EncryptionAlgorithms: [AES256, AES128]
          Phase1IntegrityAlgorithms: [SHA2-256, SHA2-384, SHA2-512]
          Phase2IntegrityAlgorithms: [SHA2-256, SHA2-384, SHA2-512]
          IKEVersions: [ikev2]
          DPDTimeoutSeconds: 30
          Phase1LifetimeSeconds: 28800
          Phase2LifetimeSeconds: 3600
          RekeyMarginTimeSeconds: 540
          RekeyFuzzPercentage: 100
          ReplayWindowSize: 1024
          StartupAction: start
      StaticRoutesOnly: false  # BGP有効
      Tags:
        - Key: Name
          Value: onprem-vpn

  # CloudWatch Alarms（VPNトンネル監視）
  Tunnel1DownAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${AWS::StackName}-vpn-tunnel1-down'
      AlarmDescription: VPN Tunnel 1 is down
      MetricName: TunnelState
      Namespace: AWS/VPN
      Statistic: Maximum
      Period: 60
      EvaluationPeriods: 2
      Threshold: 0
      ComparisonOperator: LessThanOrEqualToThreshold
      Dimensions:
        - Name: VpnId
          Value: !Ref VpnConnection
        - Name: TunnelIpAddress
          Value: !GetAtt VpnConnection.VpnTunnelOutsideIpAddress1
      AlarmActions:
        - !Ref SnsTopicArn
      TreatMissingData: breaching

  Tunnel2DownAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${AWS::StackName}-vpn-tunnel2-down'
      AlarmDescription: VPN Tunnel 2 is down
      MetricName: TunnelState
      Namespace: AWS/VPN
      Statistic: Maximum
      Period: 60
      EvaluationPeriods: 2
      Threshold: 0
      ComparisonOperator: LessThanOrEqualToThreshold
      Dimensions:
        - Name: VpnId
          Value: !Ref VpnConnection
        - Name: TunnelIpAddress
          Value: !GetAtt VpnConnection.VpnTunnelOutsideIpAddress2
      AlarmActions:
        - !Ref SnsTopicArn
      TreatMissingData: breaching

Outputs:
  VpnConnectionId:
    Value: !Ref VpnConnection
    Description: VPN Connection ID
  
  Tunnel1OutsideIp:
    Value: !GetAtt VpnConnection.VpnTunnelOutsideIpAddress1
    Description: Tunnel 1 Outside IP Address
  
  Tunnel2OutsideIp:
    Value: !GetAtt VpnConnection.VpnTunnelOutsideIpAddress2
    Description: Tunnel 2 Outside IP Address
```

---

### 4-2. オンプレミス側VPN設定（Cisco IOS）

```cisco
! IKEv2 Policy
crypto ikev2 proposal AWS-IKE-PROPOSAL
 encryption aes-cbc-256
 integrity sha256
 group 14
 exit

crypto ikev2 policy AWS-IKE-POLICY
 proposal AWS-IKE-PROPOSAL
 exit

crypto ikev2 keyring AWS-KEYRING
 peer AWS-TUNNEL-1
  address 203.0.113.10
  pre-shared-key <TUNNEL1_PSK>
 peer AWS-TUNNEL-2
  address 203.0.113.11
  pre-shared-key <TUNNEL2_PSK>
 exit

crypto ikev2 profile AWS-IKE-PROFILE
 match identity remote address 0.0.0.0
 authentication remote pre-share
 authentication local pre-share
 keyring local AWS-KEYRING
 lifetime 28800
 dpd 10 3 on-demand
 exit

! IPsec Transform Set
crypto ipsec transform-set AWS-TRANSFORM-SET esp-aes 256 esp-sha256-hmac
 mode tunnel
 exit

! IPsec Profile
crypto ipsec profile AWS-IPSEC-PROFILE
 set transform-set AWS-TRANSFORM-SET
 set ikev2-profile AWS-IKE-PROFILE
 set security-association lifetime seconds 3600
 exit

! Tunnel Interface 1
interface Tunnel1
 ip address 169.254.10.2 255.255.255.252
 ip mtu 1399
 ip tcp adjust-mss 1359
 tunnel source GigabitEthernet0/1
 tunnel destination 203.0.113.10
 tunnel mode ipsec ipv4
 tunnel protection ipsec profile AWS-IPSEC-PROFILE
 ip virtual-reassembly
 exit

! Tunnel Interface 2
interface Tunnel2
 ip address 169.254.11.2 255.255.255.252
 ip mtu 1399
 ip tcp adjust-mss 1359
 tunnel source GigabitEthernet0/1
 tunnel destination 203.0.113.11
 tunnel mode ipsec ipv4
 tunnel protection ipsec profile AWS-IPSEC-PROFILE
 ip virtual-reassembly
 exit

! BGP Configuration
router bgp 65000
 bgp log-neighbor-changes
 
 ! Tunnel 1 Neighbor
 neighbor 169.254.10.1 remote-as 64512
 neighbor 169.254.10.1 timers 10 30 30
 
 ! Tunnel 2 Neighbor
 neighbor 169.254.11.1 remote-as 64512
 neighbor 169.254.11.1 timers 10 30 30
 
 address-family ipv4
  neighbor 169.254.10.1 activate
  neighbor 169.254.10.1 soft-reconfiguration inbound
  neighbor 169.254.11.1 activate
  neighbor 169.254.11.1 soft-reconfiguration inbound
  network 192.168.0.0 mask 255.255.0.0
  maximum-paths 2  ! ECMP有効化
 exit-address-family
 exit

! Static Route (BGPフォールバック用)
ip route 10.0.0.0 255.0.0.0 Tunnel1 250
ip route 10.0.0.0 255.0.0.0 Tunnel2 250
```

---

## 5. PrivateLink構築

### 5-1. エンドポイントサービス（プロバイダー側）

#### CloudFormation
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'PrivateLink Endpoint Service (Provider)'

Parameters:
  VpcId:
    Type: AWS::EC2::VPC::Id
  
  Subnet1:
    Type: AWS::EC2::Subnet::Id
  
  Subnet2:
    Type: AWS::EC2::Subnet::Id

Resources:
  # Network Load Balancer
  NetworkLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: privatelink-nlb
      Type: network
      Scheme: internal
      IpAddressType: ipv4
      Subnets:
        - !Ref Subnet1
        - !Ref Subnet2
      Tags:
        - Key: Name
          Value: privatelink-nlb

  # Target Group
  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: privatelink-tg
      Protocol: TCP
      Port: 443
      VpcId: !Ref VpcId
      HealthCheckProtocol: TCP
      HealthCheckPort: 443
      HealthCheckEnabled: true
      HealthCheckIntervalSeconds: 30
      HealthyThresholdCount: 3
      UnhealthyThresholdCount: 3
      Tags:
        - Key: Name
          Value: privatelink-tg

  # Listener
  Listener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref NetworkLoadBalancer
      Protocol: TCP
      Port: 443
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref TargetGroup

  # VPC Endpoint Service
  VpcEndpointService:
    Type: AWS::EC2::VPCEndpointService
    Properties:
      NetworkLoadBalancerArns:
        - !Ref NetworkLoadBalancer
      AcceptanceRequired: true
      
  # VPC Endpoint Service Permissions（特定のAWSアカウントに許可）
  VpcEndpointServicePermissions:
    Type: AWS::EC2::VPCEndpointServicePermissions
    Properties:
      ServiceId: !Ref VpcEndpointService
      AllowedPrincipals:
        - arn:aws:iam::123456789012:root
        - arn:aws:iam::123456789013:root

Outputs:
  ServiceName:
    Value: !Sub 'com.amazonaws.vpce.${AWS::Region}.${VpcEndpointService}'
    Description: VPC Endpoint Service Name
    Export:
      Name: PrivateLinkServiceName
  
  NlbArn:
    Value: !Ref NetworkLoadBalancer
    Description: Network Load Balancer ARN
```

---

### 5-2. Interface Endpoint（コンシューマー側）

#### CloudFormation
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'PrivateLink Interface Endpoint (Consumer)'

Parameters:
  VpcId:
    Type: AWS::EC2::VPC::Id
  
  Subnet1:
    Type: AWS::EC2::Subnet::Id
  
  Subnet2:
    Type: AWS::EC2::Subnet::Id
  
  ServiceName:
    Type: String
    Description: VPC Endpoint Service Name
    Default: com.amazonaws.vpce.us-east-1.vpce-svc-xxxxx

Resources:
  # Security Group
  EndpointSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for VPC endpoint
      VpcId: !Ref VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 10.0.0.0/8
      Tags:
        - Key: Name
          Value: endpoint-sg

  # Interface VPC Endpoint
  InterfaceEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VpcId
      ServiceName: !Ref ServiceName
      VpcEndpointType: Interface
      PrivateDnsEnabled: false  # カスタムDNS使用時
      SubnetIds:
        - !Ref Subnet1
        - !Ref Subnet2
      SecurityGroupIds:
        - !Ref EndpointSecurityGroup

  # Route 53 Private Hosted Zone（カスタムDNS）
  PrivateHostedZone:
    Type: AWS::Route53::HostedZone
    Properties:
      Name: api.example.com
      VPCs:
        - VPCId: !Ref VpcId
          VPCRegion: !Ref AWS::Region

  # DNS Record
  DnsRecord:
    Type: AWS::Route53::RecordSet
    Properties:
      HostedZoneId: !Ref PrivateHostedZone
      Name: api.example.com
      Type: A
      AliasTarget:
        DNSName: !Select [1, !Split [':', !Select [0, !GetAtt InterfaceEndpoint.DnsEntries]]]
        HostedZoneId: !Select [0, !Split [':', !Select [0, !GetAtt InterfaceEndpoint.DnsEntries]]]
        EvaluateTargetHealth: false

Outputs:
  EndpointId:
    Value: !Ref InterfaceEndpoint
    Description: VPC Endpoint ID
  
  DnsName:
    Value: !Select [1, !Split [':', !Select [0, !GetAtt InterfaceEndpoint.DnsEntries]]]
    Description: Endpoint DNS Name
```

---

**practical-examples.md 完成！実務で即使えるネットワーク設定例を網羅しました。**
