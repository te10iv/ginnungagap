AWSTemplateFormatVersion: 2010-09-09
Description: STEP1 - 組み込み関数や Outputs を使わないベタ書き CloudFormation の例

Resources:
  # 既存 VPC を前提とした Security Group（VpcId をベタ書き）
  MyWebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: my-web-sg
      GroupDescription: Allow HTTP and SSH
      VpcId: vpc-0123456789abcdef0      # 既存の VPC ID をそのままベタ書き
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0             # 学習用なので広めに（本番ではNG）
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: my-web-sg              # ここもベタ書き

  # 既存 Subnet に EC2 インスタンスを 1 台立てる（SubnetId もベタ書き）
  MyWebServer:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0123456789abcdef0    # 利用リージョンの AMI ID をベタ書き
      InstanceType: t3.micro
      KeyName: my-keypair               # 既存のキーペア名をベタ書き
      SubnetId: subnet-0123456789abcde0 # 既存の Subnet ID をベタ書き
      SecurityGroupIds:
        - sg-0123456789abcdef0          # 上の SG を使わず、既存 SG の ID をベタ書きしてもよい
      Tags:
        - Key: Name
          Value: my-web-server          # インスタンス名もベタ書き
