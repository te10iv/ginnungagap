# セキュリティベストプラクティス

CloudFormationにおけるセキュリティ設計の必須知識

---

## 🔒 セキュリティ設計の原則

### 1. 最小権限の原則（Least Privilege）

**IAM Role設計**:
```yaml
Resources:
  EC2Role:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: S3ReadOnly
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:ListBucket
                Resource:
                  - !Sub 'arn:aws:s3:::${SpecificBucket}'
                  - !Sub 'arn:aws:s3:::${SpecificBucket}/*'
                # ❌ Resource: '*' は使わない
```

### 2. 多層防御（Defense in Depth）

```yaml
Resources:
  # Layer 1: WAF（エッジ層）
  WebACL:
    Type: AWS::WAFv2::WebACL
    Properties:
      Scope: REGIONAL
      DefaultAction:
        Allow: {}
      Rules:
        - Name: RateLimitRule
          Priority: 1
          Statement:
            RateBasedStatement:
              Limit: 2000
              AggregateKeyType: IP
          Action:
            Block: {}
  
  # Layer 2: Security Group（ネットワーク層）
  WebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          SourceSecurityGroupId: !Ref ALBSecurityGroup  # ALBからのみ
  
  # Layer 3: IAM Role（アプリ層）
  # ... 最小権限のIAM Role
  
  # Layer 4: 暗号化（データ層）
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      StorageEncrypted: true
      KmsKeyId: !Ref DBEncryptionKey
```

---

## 🔐 機密情報管理

### ❌ 悪い例（ハードコード）

```yaml
# 絶対にやってはいけない
Parameters:
  DBPassword:
    Type: String
    Default: 'MyPassword123'  # NG!

Resources:
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUserPassword: 'HardcodedPassword'  # NG!
```

### ✅ 良い例（Secrets Manager）

```yaml
Resources:
  # Secrets Manager でパスワード生成
  DBSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      GenerateSecretString:
        SecretStringTemplate: '{"username": "admin"}'
        GenerateStringKey: password
        PasswordLength: 32
        ExcludeCharacters: '"@/\'
        RequireEachIncludedType: true
  
  # Dynamic Referenceで参照
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUsername: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:username}}'
      MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:password}}'
  
  # アプリケーションからも参照可能
  # aws secretsmanager get-secret-value --secret-id <DBSecret>

Outputs:
  SecretArn:
    Value: !Ref DBSecret
    Export:
      Name: !Sub '${AWS::StackName}-DBSecret'
```

---

## 🔑 KMS暗号化

### パターン1: 各サービスでKMS使用

```yaml
Resources:
  # KMS Key作成
  EncryptionKey:
    Type: AWS::KMS::Key
    Properties:
      Description: Application encryption key
      KeyPolicy:
        Version: '2012-10-17'
        Statement:
          - Sid: Enable IAM User Permissions
            Effect: Allow
            Principal:
              AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
            Action: 'kms:*'
            Resource: '*'
          - Sid: Allow CloudWatch Logs
            Effect: Allow
            Principal:
              Service: logs.amazonaws.com
            Action:
              - 'kms:Encrypt'
              - 'kms:Decrypt'
              - 'kms:ReEncrypt*'
              - 'kms:GenerateDataKey*'
              - 'kms:CreateGrant'
              - 'kms:DescribeKey'
            Resource: '*'
            Condition:
              ArnLike:
                'kms:EncryptionContext:aws:logs:arn': !Sub 'arn:aws:logs:${AWS::Region}:${AWS::AccountId}:*'
  
  KeyAlias:
    Type: AWS::KMS::Alias
    Properties:
      AliasName: alias/myapp-encryption
      TargetKeyId: !Ref EncryptionKey

  # S3暗号化
  Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: aws:kms
              KMSMasterKeyID: !Ref EncryptionKey

  # RDS暗号化
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      StorageEncrypted: true
      KmsKeyId: !Ref EncryptionKey

  # EBS暗号化（Launch Template）
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateData:
        BlockDeviceMappings:
          - DeviceName: /dev/xvda
            Ebs:
              VolumeSize: 20
              VolumeType: gp3
              Encrypted: true
              KmsKeyId: !Ref EncryptionKey

  # CloudWatch Logs暗号化
  LogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub '/aws/app/${AWS::StackName}'
      KmsKeyId: !GetAtt EncryptionKey.Arn
```

---

## 🛡️ ネットワークセキュリティ

### パターン1: Private Subnet配置

```yaml
Resources:
  # Public Subnet（最小化）
  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      # ALB、NAT Gatewayのみ配置

  # Private Subnet（アプリケーション）
  PrivateAppSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock: 10.0.11.0/24
      MapPublicIpOnLaunch: false
      # EC2、ECS、Lambda配置

  # Private Subnet（データベース）
  PrivateDBSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      CidrBlock: 10.0.21.0/24
      # RDS、ElastiCache配置（完全隔離）

  # Security Group: DB は App層からのみアクセス
  DBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          SourceSecurityGroupId: !Ref AppSecurityGroup  # App SGからのみ
```

### パターン2: VPC Endpoint（プライベート接続）

```yaml
Resources:
  S3Endpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VPC
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.s3'
      RouteTableIds:
        - !Ref PrivateRouteTable
      # S3へインターネット経由不要、データ転送コスト$0

  ECREndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcEndpointType: Interface
      VpcId: !Ref VPC
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ecr.api'
      SubnetIds:
        - !Ref PrivateSubnet1
      SecurityGroupIds:
        - !Ref VPCEndpointSecurityGroup
      PrivateDnsEnabled: true
```

---

## 🚨 監査・コンプライアンス

### CloudTrail有効化

```yaml
Resources:
  TrailBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    Properties:
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      LifecycleConfiguration:
        Rules:
          - Id: DeleteOldLogs
            Status: Enabled
            ExpirationInDays: 2555  # 7年保持
            Transitions:
              - TransitionInDays: 90
                StorageClass: GLACIER

  Trail:
    Type: AWS::CloudTrail::Trail
    DependsOn: TrailBucketPolicy
    Properties:
      TrailName: !Sub '${AWS::StackName}-trail'
      S3BucketName: !Ref TrailBucket
      IsLogging: true
      IsMultiRegionTrail: true
      IncludeGlobalServiceEvents: true
      EnableLogFileValidation: true
      EventSelectors:
        - ReadWriteType: All
          IncludeManagementEvents: true
          DataResources:
            - Type: AWS::S3::Object
              Values:
                - !Sub '${SensitiveBucket.Arn}/*'
```

### Config Rules

```yaml
Resources:
  # S3パブリックアクセス禁止
  S3PublicReadProhibitedRule:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: s3-bucket-public-read-prohibited
      Source:
        Owner: AWS
        SourceIdentifier: S3_BUCKET_PUBLIC_READ_PROHIBITED
  
  # EBS暗号化必須
  EncryptedVolumesRule:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: encrypted-volumes
      Source:
        Owner: AWS
        SourceIdentifier: ENCRYPTED_VOLUMES
  
  # RDS暗号化必須
  RDSStorageEncryptedRule:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: rds-storage-encrypted
      Source:
        Owner: AWS
        SourceIdentifier: RDS_STORAGE_ENCRYPTED
```

---

## 🎯 セキュリティチェックリスト

### テンプレート作成時

- [ ] Secrets/Passwordのハードコード禁止
- [ ] IAM Policy の最小権限確認
- [ ] KMS暗号化有効化（S3、RDS、EBS）
- [ ] Private Subnet配置
- [ ] Security Group最小化
- [ ] Public Access Block設定（S3）
- [ ] DeletionPolicy設定（重要データ）
- [ ] CloudTrail有効化

### デプロイ前

- [ ] cfn-lint実行
- [ ] Checkov実行
- [ ] 変更セット確認（置換・削除リソース）
- [ ] IAM Capabilities確認

### デプロイ後

- [ ] ドリフト検出実行
- [ ] Config Rules準拠確認
- [ ] GuardDuty findings確認
- [ ] CloudTrail ログ確認

---

## 📚 学習リソース

- [AWS Security Best Practices](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/security-best-practices.html)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)

---

**セキュリティベストプラクティスで、安全なインフラを構築！🔒**
