import re
import subprocess

def get_solidity_version_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        contract_code = file.read()
    match = re.search(r'pragma solidity \^?(\d+\.\d+\.\d+);', contract_code)
    if match:
        return match.group(1)
    raise ValueError("未找到Solidity版本号")

def setup_global_solc(contract_file_path):
    sol_version = get_solidity_version_from_file(contract_file_path)
    # print(f"检测到Solidity版本号：{sol_version}")

    # 安装指定版本的solc
    try:
        # print(f"安装solc {sol_version}...")
        # subprocess.run(["solc-select", "install", sol_version], check=True)

        # print(f"设置全局solc版本为 {sol_version}...")
        subprocess.run(["solc-select", "use", sol_version], check=True)

        # print(f"全局solc版本已设置为 {sol_version}")
    except subprocess.CalledProcessError as e:
        print(f"错误：{e}")

