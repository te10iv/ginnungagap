#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Terraform目次に基づいて、全てのディレクトリとファイルを作成するスクリプト
"""

import os
import re
from pathlib import Path
from collections import defaultdict

# ベースディレクトリ
BASE_DIR = Path(__file__).parent

# 目次ファイルのパス
INDEX_FILE = BASE_DIR / "terraform目次.md"

def parse_index():
    """目次ファイルを解析して、構造を取得"""
    with open(INDEX_FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    structure = defaultdict(lambda: defaultdict(list))
    current_step = None
    current_section = None
    current_subsection = None
    items = []
    
    for line in lines:
        line_stripped = line.strip()
        
        # ステップ（## で始まる）
        step_match = re.match(r'^##\s+(ステップ\d+.*|補足・参考)', line_stripped)
        if step_match:
            current_step = step_match.group(1)
            current_section = None
            current_subsection = None
            items = []
            continue
        
        # セクション（### で始まる）
        section_match = re.match(r'^###\s+(\d+-\d+\.\s+.*|.*)', line_stripped)
        if section_match:
            if current_step:
                section_name = section_match.group(1)
                # 数字で始まるセクション名のみ処理（補足・参考のセクションは別処理）
                if re.match(r'^\d+-\d+\.', section_name):
                    current_section = section_name
                    current_subsection = None
                    items = []
                elif current_step == "補足・参考":
                    # 補足・参考セクションの場合
                    current_section = section_name
                    current_subsection = None
                    items = []
            continue
        
        # サブセクション（#### で始まる）
        subsection_match = re.match(r'^####\s+(.+)', line_stripped)
        if subsection_match:
            if current_section:
                # 前のサブセクションの項目を保存
                if current_subsection:
                    structure[current_step][current_section].append({
                        'name': current_subsection,
                        'items': items.copy()
                    })
                current_subsection = subsection_match.group(1)
                items = []
            continue
        
        # リスト項目（- で始まる）
        if line_stripped.startswith('- ') and current_subsection:
            item = line_stripped[2:].strip()
            items.append(item)
    
    # 最後のサブセクションの項目を保存
    if current_subsection and items:
        structure[current_step][current_section].append({
            'name': current_subsection,
            'items': items.copy()
        })
    
    return structure

def create_directories_and_files(structure):
    """ディレクトリとファイルを作成"""
    for step_name, sections in structure.items():
        # ディレクトリ名を作成（ステップ名から）
        if step_name == "補足・参考":
            dir_name = "補足・参考"
        else:
            dir_name = step_name.replace(":", "")
        dir_path = BASE_DIR / dir_name
        dir_path.mkdir(exist_ok=True)
        
        print(f"Created/Checked directory: {dir_name}")
        
        for section_name, subsections in sections.items():
            # ファイル名を作成
            if step_name == "補足・参考":
                # 補足・参考セクションのファイル名
                file_name = f"{section_name}.md"
            else:
                # 通常のセクションのファイル名
                file_name = f"{section_name}.md"
            file_path = dir_path / file_name
            
            # ファイルの内容を生成
            content = f"# {section_name}\n\n"
            
            for subsection in subsections:
                subsection_name = subsection['name']
                items = subsection['items']
                
                content += f"## {subsection_name}\n\n"
                for item in items:
                    content += f"- {item}\n"
                content += "\n"
            
            # ファイルを書き込み
            if not file_path.exists():
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"  Created file: {file_name}")
            else:
                # 既存ファイルの内容を確認して、見出しを追加
                update_existing_file(file_path, section_name, subsections)

def update_existing_file(file_path, section_name, subsections):
    """既存ファイルを更新（見出しが不足している場合）"""
    with open(file_path, 'r', encoding='utf-8') as f:
        existing_content = f.read()
    
    # 既存の見出しを確認
    existing_subsections = re.findall(r'^##\s+(.+)', existing_content, re.MULTILINE)
    existing_subsections = [s.strip() for s in existing_subsections]
    
    # 不足している見出しを追加
    missing_content = ""
    for subsection in subsections:
        subsection_name = subsection['name']
        if subsection_name not in existing_subsections:
            missing_content += f"\n## {subsection_name}\n\n"
            for item in subsection['items']:
                missing_content += f"- {item}\n"
            missing_content += "\n"
    
    if missing_content:
        # ファイルの末尾に追加
        with open(file_path, 'a', encoding='utf-8') as f:
            f.write(missing_content)
        print(f"  Updated file: {file_path.name} (added missing subsections)")
    else:
        print(f"  Skipped file: {file_path.name} (already complete)")

def main():
    """メイン処理"""
    print("Parsing index file...")
    structure = parse_index()
    
    print(f"\nFound {len(structure)} steps:")
    for step_name, sections in structure.items():
        print(f"  {step_name}: {len(sections)} sections")
    
    print("\nCreating directories and files...")
    create_directories_and_files(structure)
    
    print("\nDone!")

if __name__ == "__main__":
    main()
