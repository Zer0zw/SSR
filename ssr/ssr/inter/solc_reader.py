import re
import subprocess
from packaging.version import Version

def get_latest_solidity_version(version_set):
    # 将所有版本号转换为 Version 对象并排序
    sorted_versions = sorted(version_set, key=Version)
    # 返回排序后的最后一个版本号（即最新版本）
    return sorted_versions[-1]


def get_solidity_version_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        contract_code = file.read()

    solidity_versions_set = set()
    
    # 尝试匹配 "pragma solidity >=x.x.x;" 的格式
    match_ge = re.findall(r'pragma solidity >=(\d+\.\d+\.\d+);', contract_code)
    for match in match_ge:
        solidity_versions_set.add(match)  # 添加支持的最小版本号

    # 尝试匹配 "pragma solidity ^x.x.x;" 或 "pragma solidity x.x.x;" 的格式
    match_up = re.findall(r'pragma solidity \^?(\d+\.\d+\.\d+);', contract_code)
    for match in match_up:
        solidity_versions_set.add(match)  # 添加支持的最小版本号

    # 尝试匹配 "pragma solidity ^x.x.x;" 或 "pragma solidity x.x.x;" 的格式
    match_eq = re.findall(r'pragma solidity =(\d+\.\d+\.\d+);', contract_code)
    for match in match_eq:
        solidity_versions_set.add(match)  # 添加支持的最小版本号
    
    # 如果没有找到任何匹配的版本声明，抛出错误
    if len(solidity_versions_set) == 0:
        raise ValueError("未找到Solidity版本号")
    else: 
        latest_version = get_latest_solidity_version(solidity_versions_set)  # 返回支持的最大版本号
    
    return latest_version, solidity_versions_set



def setup_global_solc(contract_file_path):
    sol_version, _ = get_solidity_version_from_file(contract_file_path)
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

if __name__ == "__main__":
    



    print("aha!")