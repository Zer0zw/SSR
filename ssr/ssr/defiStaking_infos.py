import json
import os
import sys
import logging

from slither.slither import Slither
from typing import List, Tuple

from slither.core.cfg.node import Node
from slither.core.declarations import Function, Contract, FunctionContract

from inter.solc_reader import setup_global_solc

from tqdm import tqdm

from inter.contract_analyzer import get_MainContract
import inter.contract_analyzer as contract_analyzer

from openai import OpenAI

from inter.config import API_KEY, MODEL, BASE_URL

from inter.prompts_template import get_contract_message, get_variables_message, get_calculations_message

import datetime

# ******************************************************
# Global setting
# ******************************************************

# LLM相关
used_api_key = API_KEY
used_model = MODEL
used_base_url = BASE_URL
client = OpenAI(api_key = used_api_key, base_url = used_base_url)

# 日志配置
# 创建 logger 对象
logger = logging.getLogger(__name__)  # 通常使用模块的 __name__ 作为 logger 的名字
logger.setLevel(logging.DEBUG)  # 设置最低的日志级别

# 创建文件处理器，将日志写入指定文件
log_file = '/mnt/linzw3/work/defistaking/SSR/ssr/logs/defiStaking_infos.log'  # 指定日志文件的路径和名称
file_handler = logging.FileHandler(log_file)
file_handler.setLevel(logging.DEBUG)  # 设置文件处理器的日志级别

# 创建日志格式器，并将其添加到文件处理器
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

# 将文件处理器添加到 logger
logger.addHandler(file_handler)

# ******************************************************
# Extract Contract Code
# ******************************************************

def extract_contract_code(contract_path):
    try:
        with open(contract_path, 'r', encoding='utf-8') as file:
            contract_code = file.read()
        return contract_code
    except FileNotFoundError:
        print(f"文件未找到: {contract_path}")
        return None
    except Exception as e:
        print(f"读取文件时发生错误: {e}")
        return None

# 提取主合约的代码并将其输出到txt文档中
def extract_main_contract_codes(main_contract: Contract, contract_path):
    main_contract_lines = main_contract.source_mapping.lines

    # print("Starting to extract main contract codes...")
    mainContract_code_str = extract_lines_from_sol(contract_path, main_contract_lines)

    return mainContract_code_str

# 根据代码行数提取代码并输出
def extract_lines_from_sol(sol_file_path, lines_to_extract):
    try:
        with open(sol_file_path, 'r', encoding='utf-8') as file:
            # 读取sol文件所有行
            lines = file.readlines()

        # 提取指定行数的代码
        extracted_lines = []
        for line_num in lines_to_extract:
            # 注意：行数从1开始，但列表索引从0开始，所以要减1
            if 0 < line_num <= len(lines):
                extracted_lines.append(lines[line_num - 1].strip())
        
        main_contract_code = '\n'.join(extracted_lines)

        # 输出提取的代码
        return main_contract_code

    except Exception as e:
        print(f"An error occurred: {e}")


# ******************************************************
# Getting DeFi Staking Information
# ******************************************************

def get_is_deFiStaking(_contract_code_str):
    _messages = get_contract_message(_contract_code_str)

    response = client.chat.completions.create(
        model = used_model,
        messages = _messages,

    )

    _is_deFiStaking = response.choices[0].message.content

    print("_is_deFiStaking: ", _is_deFiStaking)

    if _is_deFiStaking == "Yes":
        return True
    elif _is_deFiStaking == "No":
        return False
    else:
        raise ValueError("Invalid response from API")


# 基于LLM获取DeFi Staking相关信息
def get_defi_staking_info(contract_path):
    _defiStaking_info_dict = {}

    _contract_code_str = extract_contract_code(contract_path)

    print("Starting to check if the contract is a DeFi Staking contract...")
    _is_deFiStaking = get_is_deFiStaking(_contract_code_str)

    if _is_deFiStaking:
        print("Starting to get DeFi Staking information...")
        print("Starting to get DeFi Staking variables information...")
        _variables_info_dict = get_defiStaking_variables_info(_contract_code_str)

        print("Starting to get DeFi Staking calculations information...")
        _calculations_info_dict = get_defiStaking_calculations_info(_contract_code_str)

        _defiStaking_info_dict["Variables"] = _variables_info_dict
        _defiStaking_info_dict["Calculations"] = _calculations_info_dict
    else:
        logger.info(f"Project path: {contract_path} is not a DeFi Staking contract.")
        print(f"Project path: {contract_path} is not a DeFi Staking contract.")

    return _defiStaking_info_dict

# 基于LLM获取DeFi Staking相关信息(只从主合约中获取信息)
def get_defi_staking_info_mainContract(contract_path):
    _defiStaking_info_dict = {}

    # 获取主合约代码
    _slither_obj = Slither(contract_path)
    _main_contract = get_MainContract(_slither_obj)
    _contract_code_str = extract_main_contract_codes(_main_contract, contract_path)

    print("Starting to check if the contract is a DeFi Staking contract...")
    _is_deFiStaking = get_is_deFiStaking(_contract_code_str)

    if _is_deFiStaking:
        print("Starting to get DeFi Staking information...")
        print("Starting to get DeFi Staking variables information...")
        _variables_info_dict = get_defiStaking_variables_info(_contract_code_str)

        print("Starting to get DeFi Staking calculations information...")
        _calculations_info_dict = get_defiStaking_calculations_info(_contract_code_str)

        _defiStaking_info_dict["Variables"] = _variables_info_dict
        _defiStaking_info_dict["Calculations"] = _calculations_info_dict
    else:
        logger.info(f"Project path: {contract_path} is not a DeFi Staking contract.")
        print(f"Project path: {contract_path} is not a DeFi Staking contract.")

    return _defiStaking_info_dict


# 基于LLM获取DeFi Staking相关的变量信息
def get_defiStaking_variables_info(_contract_code_str):
    
    _messages = get_variables_message(_contract_code_str)
    # print(_messages)

    response = client.chat.completions.create(
        model = used_model,
        messages = _messages,
        response_format = {
            'type': 'json_object'
        },
        stream=False
    )

    _variables_info_dict = json.loads(response.choices[0].message.content)
    print(_variables_info_dict)

    return _variables_info_dict

# 基于LLM获取DeFi Staking相关的计算信息
def get_defiStaking_calculations_info(_contract_code_str):

    _messages = get_calculations_message(_contract_code_str)

    response = client.chat.completions.create(
        model = used_model,
        messages = _messages,
        response_format = {
            'type': 'json_object'
        },
        stream=False
    )

    _calculations_info_dict = json.loads(response.choices[0].message.content)
    print(_calculations_info_dict)

    return _calculations_info_dict

# ***************************************************************
# Main Function
# ***************************************************************

def get_defiStaking_infos_singleProject(project_name, contract_folder_path, output_folder_path):
    # 设置合约源码路径以及输出路径
    contract_path = os.path.join(contract_folder_path, f"{project_name}.sol")
    output_path = os.path.join(output_folder_path, f"{project_name}.json")

    # 验证合约源码文件是否存在
    if not os.path.exists(contract_path):
        logger.error(f"Contract file not found: {contract_path}")
        raise FileNotFoundError(f"Contract file not found: {contract_path}")
    
    # 验证该项目的DeFi Staking Infos是否已经提取过了，省钱
    if os.path.exists(output_path):
        logger.info(f"DeFi Staking Infomation already exists: {project_name}")
        raise RuntimeError(f"DeFi Staking Infomation already exists: {project_name}")
    
    setup_global_solc(contract_path)
    # 验证合约是否可被Slither分析
    if not contract_analyzer.is_contract_analyzable(contract_path):
        logger.info(f"Contract is not analyzable by Slither: {project_name}")
        raise RuntimeError(f"Contract is not analyzable by Slither: {project_name}")

    defiStaking_info_dict = get_defi_staking_info(contract_path)

    if defiStaking_info_dict != {}:
        # print("Outputting DeFi Staking information...")
        # 确保目录存在
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        # 打开文件并将字典数据写入文件
        with open(output_path, 'w') as f:
            json.dump(defiStaking_info_dict, f, ensure_ascii=False, indent=4)
        logger.info(f"DeFi Staking Infomation extracted: {project_name}")
    else: 
        logger.info(f"Not DeFi Staking contract: {project_name}")


def get_defiStaking_infos_singleProject_mainContract(project_name, contract_folder_path, output_folder_path):
    # 设置合约源码路径以及输出路径
    contract_path = os.path.join(contract_folder_path, f"{project_name}.sol")
    output_path = os.path.join(output_folder_path, f"{project_name}.json")

    # 验证合约源码文件是否存在
    if not os.path.exists(contract_path):
        logger.error(f"Contract file not found: {contract_path}")
        raise FileNotFoundError(f"Contract file not found: {contract_path}")
    
    # 验证该项目的DeFi Staking Infos是否已经提取过了，省钱
    if os.path.exists(output_path):
        logger.info(f"DeFi Staking Infomation already exists: {project_name}")
        raise RuntimeError(f"DeFi Staking Infomation already exists: {project_name}")
    
    setup_global_solc(contract_path)
    # 验证合约是否可被Slither分析
    if not contract_analyzer.is_contract_analyzable(contract_path):
        logger.info(f"Contract is not analyzable by Slither: {project_name}")
        raise RuntimeError(f"Contract is not analyzable by Slither: {project_name}")

    defiStaking_info_dict = get_defi_staking_info_mainContract(contract_path)

    if defiStaking_info_dict != {}:
        # print("Outputting DeFi Staking information...")
        # 确保目录存在
        # os.makedirs(os.path.dirname(output_folder_path), exist_ok=True)
        # 打开文件并将字典数据写入文件
        with open(output_path, 'w') as f:
            json.dump(defiStaking_info_dict, f, ensure_ascii=False, indent=4)
        logger.info(f"DeFi Staking Infomation extracted: {project_name}")
    else: 
        logger.info(f"Not DeFi Staking contract: {project_name}")




if __name__ == '__main__':
    # ***************************************************************
    # 输入
    # ***************************************************************

    # 项目名称
    
    # 检测单个项目
    # project_name = "Noracle"

    # 检测在一个文件夹下的所有sol文件
    # target_sol_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale/analyzable/ethereum"
    # project_name_list = contract_analyzer.get_projectNams_from_folder(target_sol_folder_path)
    
    # 合约源码所在文件夹
    # contract_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/groundTruth"
    contract_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale/analyzable/ethereum"
    
    # 输出DeFi Staking Infos的文件夹
    # output_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/2_model/infos"
    output_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/infos/ethereum"

    

    # ***************************************************************
    # Single Project
    # ***************************************************************

    # get_defiStaking_infos_singleProject(project_name, contract_folder_path, output_folder_path)

    # ***************************************************************
    # Multiple Projects
    # ***************************************************************

    analyzed_contract_txt_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/infos/analyzed_contracts.txt"
    largeScale_root_contract_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale"

    chain_name_list = [
        # "analyzable/ethereum",
        # "bsc",
        # "arbitrum",
        # "avalanche",
        # "celo",
        # "fantom",
        # "optimism",
        # "polygon",
        "tron"
    ]

    # 设置时间段：00:30 到 08:30
    current_time = datetime.datetime.now()
    start_time = current_time.replace(hour=0, minute=30, second=0, microsecond=0)
    end_time = current_time.replace(hour=8, minute=20, second=0, microsecond=0)

    for chain_name in chain_name_list:
        # 合约源码所在文件夹
        target_contract_folder_path = os.path.join(largeScale_root_contract_folder_path, chain_name)
        project_name_list = contract_analyzer.get_projectNams_from_folder(target_contract_folder_path)

        contract_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale/" + chain_name
        output_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/infos/" + chain_name

        for project_name in project_name_list:
            # 时间段内的合约才进行分析
            current_time = datetime.datetime.now()
            if current_time < start_time or current_time > end_time:
                print("Time is not in the range of analysis.")
                break

            print("Analying project: ", project_name)
            
            # 已经分析过的合约路径
            with open(analyzed_contract_txt_path, 'r', encoding='utf-8') as file:
                analyzed_contract_path_list = file.readlines()
            analyzed_contract_path_list = [line.strip() for line in analyzed_contract_path_list]

            # 判断一个合约是否已经被分析过了
            to_analyze_contract_path = os.path.join(contract_folder_path, f"{project_name}.sol")
            if to_analyze_contract_path in analyzed_contract_path_list:
                logger.info(f"Analyzed contract: {to_analyze_contract_path}")
            else:
                # 利用LLM提取DeFi Staking相关信息
                try:
                    get_defiStaking_infos_singleProject_mainContract(project_name, contract_folder_path, output_folder_path)
                    logger.info(f"Contract analyzed finished: {project_name}")
                except:
                    logger.error(f"An error occurred when analyzing project: {project_name}")
                
                with open(analyzed_contract_txt_path, 'a', encoding='utf-8') as file:  # 以追加模式打开文件
                    file.write(to_analyze_contract_path + '\n')  # 写入新的一行

    
    # ***************************************************************
    # Test
    # ***************************************************************
    # contract_path = os.path.join(contract_folder_path, f"{project_name}.sol")
    # _contract_code_str = extract_contract_code(contract_path)
    # _messages = get_contract_message(_contract_code_str)

    # print("Starting to check if the contract is a DeFi Staking contract...")
    # response = client.chat.completions.create(
    #     model = used_model,
    #     messages = _messages,
    #     stream = False
    # )

    # # _is_deFiStaking_response = response

    # # print(_is_deFiStaking_response)

    # # _is_deFiStaking = _is_deFiStaking_response.choices[0].message.content
    # _is_deFiStaking = response.choices[0].message.content

    # print("_is_deFiStaking: ", _is_deFiStaking)
    

    print("aha!")