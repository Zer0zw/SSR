import json
import os
import sys
import logging

from slither.slither import Slither
from typing import List, Tuple

from slither.analyses.data_dependency.data_dependency import is_dependent
from slither.core.cfg.node import Node
from slither.core.declarations import Function, Contract, FunctionContract
from slither.core.declarations.solidity_variables import (
    SolidityVariableComposed,
    SolidityVariable,
    SolidityFunction,
)
from slither.core.variables import Variable
from slither.detectors.abstract_detector import (
    AbstractDetector,
    DetectorClassification,
    DETECTOR_INFO,
)
from slither.slithir.operations import Binary, BinaryType
from slither.utils.output import Output

from inter.solc_reader import setup_global_solc

from tqdm import tqdm

from defiStaking_model import read_defiStaking_Infos, construct_defiStaking_model, output_defiStaking_model_to_json

from inter.contract_analyzer import SSR_Variable
from inter.contract_analyzer import get_MainContract
import inter.contract_analyzer as contract_analyzer
import inter.metrics_analysis as metrics_analysis

# ******************************************************
# Global setting
# ******************************************************

# 日志配置
# 创建 logger 对象
logger = logging.getLogger(__name__)  # 通常使用模块的 __name__ 作为 logger 的名字
logger.setLevel(logging.DEBUG)  # 设置最低的日志级别

# 创建文件处理器，将日志写入指定文件
log_file = '/mnt/linzw3/work/defistaking/SSR/ssr/logs/defiStaking_defects.log'  # 指定日志文件的路径和名称
file_handler = logging.FileHandler(log_file)
file_handler.setLevel(logging.DEBUG)  # 设置文件处理器的日志级别

# 创建日志格式器，并将其添加到文件处理器
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

# 将文件处理器添加到 logger
logger.addHandler(file_handler)


# ******************************************************************************
# Global Variables
# ******************************************************************************

erc_functionsName_list = [
    # ERC20
    "transfer",
    "transferFrom",
    "approve",
    "name",
    "sybmol",
    "decimals",
    "totalSupply",
    "balanceOf",
    "allowance",
    "increaseAllowance",
    "decreaseAllowance",
    "mint",
    "burn",
    "burnFrom"
]

erc_variablesName_list = [
    "_balances",
    "_allowances",
    "_totalSupply",
    "_name",
    "_symbol",
    "_decimals"
]


# ******************************************************************************
# Reading DeFi Staking Model
# ******************************************************************************

# 从json文件中读取model
def read_defiStaking_model(_slither_obj, _simple_defiStaking_model_path, _contract_path):
    # 初始化变量
    _defiStaking_model_dict = {}

    # 从json文件中读取simple DeFi Staking模型
    with open(_simple_defiStaking_model_path, "r") as f:
        _simple_defiStaking_model_dict = json.load(f)

    # 读取合约
    _main_contract = get_MainContract(_slither_obj)
    
    # 读取模型中的变量信息
    _defiStaking_variables_dict = read_defiStaking_Variables_from_simpleModel(_main_contract, _simple_defiStaking_model_dict)
    _defiStaking_model_dict["Variables"] = _defiStaking_variables_dict

    # 读取模型中的函数信息
    _defiStaking_functions_dict = read_defiStaking_Functions_from_simpleModel(_main_contract, _simple_defiStaking_model_dict)
    _defiStaking_model_dict["Functions"] = _defiStaking_functions_dict

    # 读取模型中的计算信息
    _defiStaking_calculations_dict = read_defiStaking_Calculations_from_simpleModel(_main_contract, _simple_defiStaking_model_dict)
    _defiStaking_model_dict["Calculations"] = _defiStaking_calculations_dict

    return _defiStaking_model_dict


# 读取DeFi Staking模型中的相关变量信息
def read_defiStaking_Variables_from_simpleModel(_contract: Contract, _simple_defiStaking_model_dict):
    _defiStaking_variables_dict = {}

    for key in _simple_defiStaking_model_dict["Variables"].keys():
        _var_list = []
        _varName_list = _simple_defiStaking_model_dict["Variables"][key]

        for _varName in _varName_list:
            _var_dict = get_stateVar_from_varName_model(_contract, _varName)
            if _var_dict["Variable"] != None:
                _ssr_var = SSR_Variable(_var_dict["Variable"], _var_dict["Element"])
                _var_list.append(_ssr_var)

        _defiStaking_variables_dict[key] = _var_list
    
    return _defiStaking_variables_dict

# 根据DeFi Staking模型给定的变量名称获取对应的状态变量
# 跟get_stateVar_from_infoName的区别在于：
# LLM提取出来的info中，struct变量中是包含的是struct结构的名称，而不是变量名称。
# 而DeFi Staking模型中，给出的直接是struct变量的名称。
def get_stateVar_from_varName_model(_contract: Contract, _read_varName):
    # 初始化变量
    _var_dict = {}

    # 判断变量类型
    _var_name, _element = contract_analyzer.parse_variable_name(_read_varName)
    _var_dict["Variable"] = None
    _var_dict["Element"] = _element

    # 获取合约中所有的状态变量
    _state_vars_set = contract_analyzer.get_all_stateVariables_set(_contract)

    # 遍历状态变量，找到与给定变量名匹配的变量
    for _var in _state_vars_set:
        if _var.name == _var_name:
            _var_dict["Variable"] = _var

    return _var_dict

# 读取DeFi Staking模型中的相关函数信息
def read_defiStaking_Functions_from_simpleModel(_contract: Contract, _simple_defiStaking_model_dict):
    # 获取大模型提供的信息
    _stake_functions_set = set()
    _getReward_functions_set = set()
    _unstake_functions_set = set()
    _sensitive_functions_set = set()

    _stake_funcNames_list = _simple_defiStaking_model_dict["Functions"]["Stake"]
    _getReward_funcNames_list = _simple_defiStaking_model_dict["Functions"]["getReward"]
    _unstake_funcNames_list = _simple_defiStaking_model_dict["Functions"]["unStake"]    
    _sensitive_funcNames_list = _simple_defiStaking_model_dict["Functions"]["Sensitive Functions"]

    for _func in _contract.functions:
        if len(_func.nodes) > 0:
            if _func.name in _stake_funcNames_list:
                _stake_functions_set.add(_func)

            if _func.name in _getReward_funcNames_list:
                _getReward_functions_set.add(_func)

            if _func.name in _unstake_funcNames_list:
                _unstake_functions_set.add(_func)
                
            if _func.name in _sensitive_funcNames_list:
                _sensitive_functions_set.add(_func)
    
    _stake_functions_set = filter_functions_by_name_and_id(_stake_functions_set)
    _getReward_functions_set = filter_functions_by_name_and_id(_getReward_functions_set)
    _unstake_functions_set = filter_functions_by_name_and_id(_unstake_functions_set)
    _sensitive_functions_set = filter_functions_by_name_and_id(_sensitive_functions_set)

    _stake_functions_list = sorted(list(_stake_functions_set), key = lambda x: x.name)
    _getReward_functions_list = sorted(list(_getReward_functions_set), key = lambda x: x.name)
    _unstake_functions_list = sorted(list(_unstake_functions_set), key = lambda x: x.name)
    _sensitive_functions_list = sorted(list(_sensitive_functions_set), key = lambda x: x.name)

    _functions_dict = {
        "Stake": _stake_functions_list,
        "getReward": _getReward_functions_list,
        "unStake": _unstake_functions_list,
        "Sensitive Functions": _sensitive_functions_list
    }

    return _functions_dict

# 过滤重名函数
def filter_functions_by_name_and_id(func_set):
    """
    给定一个包含多个函数的 set，保留每组同名函数中 id 最大的那个。
    """
    name_to_func = {}

    for func in func_set:
        func_name = func.name
        func_id = func.id
        # 如果名字已经存在，比较 id
        if func_name in name_to_func.keys():
            if func_id > name_to_func[func_name].id:
                name_to_func[func_name] = func
        else:
            name_to_func[func_name] = func

    # 返回只包含每组同名函数中 id 最大的函数的 set
    return set(name_to_func.values())

# 读取DeFi Staking模型中的相关计算信息
def read_defiStaking_Calculations_from_simpleModel(_contract: Contract, _simple_defiStaking_model_dict):
    _calculations_dict = {}

    for key in _simple_defiStaking_model_dict["Calculations"].keys():
        _calModel_list = []
        _simple_calModel_list = _simple_defiStaking_model_dict["Calculations"][key]

        for _simple_calModel in _simple_calModel_list:
            # 相关函数
            _func_name = _simple_calModel["Function"]
            _target_func_set = set()
            for _func in _contract.functions:
                if (_func.name == _func_name) and (len(_func.nodes) > 0):
                    _target_func_set.add(_func)
            _target_func = max(_target_func_set, key=lambda x: x.id)

            # 相关节点
            _target_node_list = []
            _node_lines = _simple_calModel["Node"]
            _target_node = contract_analyzer.get_node_from_lineNums(_contract, _node_lines)
            _target_node_list.append(_target_node)

            # 计算相关的变量
            _cal_ssrVars_names_list = _simple_calModel["Calculation Variables"]
            _cal_ssrVars_list = []
            for _ssrVar_name in _cal_ssrVars_names_list:
                _var_dict = get_stateVar_from_varName_model(_contract, _ssrVar_name)
                if _var_dict["Variable"] != None:
                    _ssr_var = SSR_Variable(_var_dict["Variable"], _var_dict["Element"])
                    _cal_ssrVars_list.append(_ssr_var)
            
            # 控制转账操作的变量
            _con_ssrVars_names_list = _simple_calModel["Control Variables"]
            _con_ssrVars_list = []
            for _ssrVar_name in _con_ssrVars_names_list:
                _var_dict = get_stateVar_from_varName_model(_contract, _ssrVar_name)
                if _var_dict["Variable"] != None:
                    _ssr_var = SSR_Variable(_var_dict["Variable"], _var_dict["Element"])
                    _con_ssrVars_list.append(_ssr_var)

            # 计算和控制相关的所有变量
            _fullcal_ssrVars_names_list = _simple_calModel["Full Calculation Variables"]
            _fullcal_ssrVars_list = []
            for _ssrVar_name in _fullcal_ssrVars_names_list:
                _var_dict = get_stateVar_from_varName_model(_contract, _ssrVar_name)
                if _var_dict["Variable"] != None:
                    _ssr_var = SSR_Variable(_var_dict["Variable"], _var_dict["Element"])
                    _fullcal_ssrVars_list.append(_ssr_var)

            # 是否依赖于this.balance
            _is_balance_dependent = _simple_calModel["Is Depend on this.balance"]

            _calModel_dict = {
                "Function": _target_func,
                "Node": _target_node_list,
                "Calculation Variables": _cal_ssrVars_list,
                "Control Variables": _con_ssrVars_list,
                "Full Calculation Variables": _fullcal_ssrVars_list,
                "Is Depend on this.balance": _is_balance_dependent
            }

            _calModel_list.append(_calModel_dict)
        
        _calculations_dict[key] = _calModel_list

    return _calculations_dict


# ******************************************************************************
# Critical Variables Manipulation
# ******************************************************************************

def get_CVM_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _CVM_dict = {}

    # print("")
    # print("Start to detect Critical Variables Manipulation (CVM) defects...")

    
    _list_2control_func, _ = getFunc_2control(_contract)
    # for _sensitive_func in _sensitive_funcs_list:
    #     if not isFunc_underSafeVerification(_sensitive_func, _list_2control_func):
    #         _UV_list.append({
    #             "Defect Function": _sensitive_func,
    #             "Type": "Sensitive"
    #         })

    # 情况1：修改计算公式中的关键变量(包括控制转账操作以及转账金额的变量)
    _defects_CVM_calculation_list = get_CVM_calculation_defects(_contract, _defiStaking_model_dict, _contract_path)

    _list_cal_defects = []
    for _cal_defect_info in _defects_CVM_calculation_list:
        _defect_func = _cal_defect_info["Defect Function"]
        if (not isFunc_underSafeVerification(_defect_func, _list_2control_func)) and (is_func_Not_verify_inputAddress(_defect_func)):
            _list_cal_defects.append(_cal_defect_info)

    _CVM_dict["Calculation"] = _list_cal_defects

    # for _defectInfo_dict in _defects_CVM_calculation_list:
    #     # 输出结果
    #     _defectFunc_name = _defectInfo_dict["Defect Function"].name
    #     _cal_ssrVar_name = _defectInfo_dict["Calculation Variable"].expression()
    #     _calType = _defectInfo_dict["Calculation Type"]
    #     _calFunc_name = _defectInfo_dict["Calculation Function"].name

    #     print("Function ", _defectFunc_name, " is able to modify the value of Variable ", _cal_ssrVar_name, ", which will influence the transfer of ", _calType, " tokens in Function ", _calFunc_name)

    # 情况2：修改计算公式中的关键变量this.balance
    _defects_CVM_balance_list = get_CVM_balance_defects(_contract, _defiStaking_model_dict, _contract_path) 

    _list_bal_defects = []
    for _bal_defect_info in _defects_CVM_balance_list:
        _defect_func = _bal_defect_info["Defect Function"]
        if (not isFunc_underSafeVerification(_defect_func, _list_2control_func)) and (is_func_Not_verify_inputAddress(_defect_func)):
            _list_bal_defects.append(_bal_defect_info)

    _CVM_dict["Balance"] = _list_bal_defects

    # for _defectInfo_dict in _defects_CVM_balance_list:
    #     _defectFunc_name = _defectInfo_dict["Defect Function"].name
    #     _calType = _defectInfo_dict["Calculation Type"]
    #     _calFunc_name = _defectInfo_dict["Calculation Function"].name

    #     print("In Function ", _calFunc_name, ", the balance of this contract is used to calculate the amount of ", _calType, " tokens, which can be modified by Function ", _defectFunc_name)

    # print("")

    return _CVM_dict


# 检测CVM情况1：修改计算公式中的关键变量
def get_CVM_calculation_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _defects_CVM_calculation_list = []

    # 计算公式中依赖的除了this.balance之外的变量     
    
    # 获取应该排除的变量和函数                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    _special_variables_list = get_specialVars_list_fromModel(_contract, _defiStaking_model_dict)
    _special_funcs_list = get_specialFuncs_list_fromModel(_contract, _defiStaking_model_dict)

    _stakeCal_model_list = _defiStaking_model_dict["Calculations"]["Stake"]
    for _dict in _stakeCal_model_list:

        for _ssr_var in _dict["Full Calculation Variables"]:
            # 排除部分特殊的变量
            if _ssr_var in _special_variables_list:
                continue

            _defectFunc_list = contract_analyzer.get_funcs_modify_ssrVar_freely(_contract, _ssr_var, _contract_path)

            for _defectFunc in _defectFunc_list:
                if _defectFunc not in _special_funcs_list:
                    # 初始化变量
                    _defect_info = {}

                    _defect_info["Defect Function"] = _defectFunc
                    _defect_info["Calculation Function"] = _dict["Function"]
                    _defect_info["Calculation Type"] = "stake"
                    _defect_info["Calculation Variable"] = _ssr_var

                    _defects_CVM_calculation_list.append(_defect_info)
        
    
    _rewardCal_model_list = _defiStaking_model_dict["Calculations"]["getReward"]
    for _dict in _rewardCal_model_list:

        for _ssr_var in _dict["Full Calculation Variables"]:
            # 排除部分特殊的变量
            if _ssr_var in _special_variables_list:
                continue

            _defectFunc_list = contract_analyzer.get_funcs_modify_ssrVar_freely(_contract, _ssr_var, _contract_path)

            for _defectFunc in _defectFunc_list:
                if _defectFunc not in _special_funcs_list:
                    # 初始化变量
                    _defect_info = {}

                    _defect_info["Defect Function"] = _defectFunc
                    _defect_info["Calculation Function"] = _dict["Function"]
                    _defect_info["Calculation Type"] = "reward"
                    _defect_info["Calculation Variable"] = _ssr_var

                    _defects_CVM_calculation_list.append(_defect_info)

    _unstakeCal_model_list = _defiStaking_model_dict["Calculations"]["unStake"]
    for _dict in _unstakeCal_model_list:

        for _ssr_var in _dict["Full Calculation Variables"]:
            # 排除部分特殊的变量
            if _ssr_var in _special_variables_list:
                continue

            _defectFunc_list = contract_analyzer.get_funcs_modify_ssrVar_freely(_contract, _ssr_var, _contract_path)

            for _defectFunc in _defectFunc_list:
                if _defectFunc not in _special_funcs_list:
                    # 初始化变量
                    _defect_info = {}

                    _defect_info["Defect Function"] = _defectFunc
                    _defect_info["Calculation Function"] = _dict["Function"]
                    _defect_info["Calculation Type"] = "unstake"
                    _defect_info["Calculation Variable"] = _ssr_var

                    _defects_CVM_calculation_list.append(_defect_info)

    return _defects_CVM_calculation_list

# 获取计算公式中的特殊变量
def get_specialVars_list_fromModel(_contract: Contract, _defiStaking_model_dict):
    # 初始化变量
    _special_variables_set = set()

    # 特殊变量类型1：DeFi Staking Model中的变量
    _defiStaking_variables_dict = _defiStaking_model_dict["Variables"]
    for _key in _defiStaking_variables_dict.keys():
        for _ssr_var in _defiStaking_variables_dict[_key]:
            _special_variables_set.add(_ssr_var)
    
    # 特殊变量类型2：ERC变量
    for _var in _contract.state_variables:
        if _var.name in erc_variablesName_list:
            _ssr_var = SSR_Variable(_var)
            _special_variables_set.add(_ssr_var)

    _special_variables_list = list(_special_variables_set)
    return _special_variables_list

# 获取特殊的函数列表
def get_specialFuncs_list_fromModel(_contract: Contract, _defiStaking_model_dict):
    # 初始化变量
    _special_funcs_set = set()

    # 特殊函数类型1：DeFi Staking Model中的函数
    _defiStaking_functions_dict = _defiStaking_model_dict["Functions"]
    for _func in _defiStaking_functions_dict["Stake"]:
        _special_funcs_set.add(_func)
    for _func in _defiStaking_functions_dict["getReward"]:
        _special_funcs_set.add(_func)
    for _func in _defiStaking_functions_dict["unStake"]:
        _special_funcs_set.add(_func)

    _other_special_funcNames_list = [
        "stake",
        "claim",
        "initialize"
    ]

    # 特殊函数类型3：转账函数
    _transfer_funcsAndnodes_list = contract_analyzer.get_transfer_funcsAndnodes_list(_contract)
    for _transfer_funcsAndnodes_dict in _transfer_funcsAndnodes_list:
        _special_funcs_set.add(_transfer_funcsAndnodes_dict["Function"])
    
    # 特殊函数类型2：ERC函数
    for _func in _contract.functions:
        if _func.name in erc_functionsName_list:
            _special_funcs_set.add(_func)
        
        if contains_element(_func.name, _other_special_funcNames_list):
            _special_funcs_set.add(_func)
    

    _special_funcs_list = list(_special_funcs_set)
    return _special_funcs_list

# 检测CVM情况2：篡改计算收益amount相关变量的特殊情况：篡改this.balance
def get_CVM_balance_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _defects_CVM_balance_list = [] 

    _modify_balance_funcsAndnodes_list = get_modify_balance_funcsAndnodes_list(_contract, _contract_path)

    for _balance_dict in _modify_balance_funcsAndnodes_list:
        _stakeCal_model_list = _defiStaking_model_dict["Calculations"]["Stake"]
        for _stake_dict in _stakeCal_model_list:
            if _stake_dict["Is Depend on this.balance"]:
                # 初始化变量
                _defect_info = {}
                _defect_info["Defect Function"] = _balance_dict["Function"]
                _defect_info["Calculation Type"] = "stake"
                _defect_info["Calculation Function"] = _stake_dict["Function"]

                _defects_CVM_balance_list.append(_defect_info)
        
        _rewardCal_model_list = _defiStaking_model_dict["Calculations"]["getReward"]
        for _reward_dict in _rewardCal_model_list:
            if _reward_dict["Is Depend on this.balance"]:
                # 初始化变量
                _defect_info = {}
                _defect_info["Defect Function"] = _balance_dict["Function"]
                _defect_info["Calculation Type"] = "reward"
                _defect_info["Calculation Function"] = _reward_dict["Function"]

                _defects_CVM_balance_list.append(_defect_info)

        _unstakeCal_model_list = _defiStaking_model_dict["Calculations"]["unStake"]
        for _unstake_dict in _unstakeCal_model_list:
            if _unstake_dict["Is Depend on this.balance"]:
                # 初始化变量
                _defect_info = {}
                _defect_info["Defect Function"] = _balance_dict["Function"]
                _defect_info["Calculation Type"] = "unstake"
                _defect_info["Calculation Function"] = _unstake_dict["Function"]

                _defects_CVM_balance_list.append(_defect_info)
    
    return _defects_CVM_balance_list

# 从合约中获取修改this.balance的函数和节点
def get_modify_balance_funcsAndnodes_list(_contract: Contract, _contract_path):
    _modify_balance_funcsAndnodes_list = []

    thisBalance_statement_list = [
        "this.balance",
        "balanceOf(this)",
        "balanceOf(address(this))"
    ]

    _transfer_funcsAndnodes_list = contract_analyzer.get_transfer_funcsAndnodes_list(_contract)

    for _transfer_funcsAndnodes_dict in _transfer_funcsAndnodes_list:
        for _thisBalance_stat in thisBalance_statement_list:
            if contract_analyzer.check_string_in_node(_contract_path, _transfer_funcsAndnodes_dict["Node"], _thisBalance_stat):
                _modify_balance_funcsAndnodes_list.append(_transfer_funcsAndnodes_dict)
                break

    return _modify_balance_funcsAndnodes_list




# ******************************************************************************
# Rewards without Timedelay (RT)
# ******************************************************************************

def get_RT_defects(_contract: Contract, _defiStaking_model_dict):
    _RT_list = []

    # print("Start to detect Rewards without Timedelay (RT) defects...")

    _rewardCal_model_list = _defiStaking_model_dict["Calculations"]["getReward"]
    _stake_and_unstake_funcNames_list = [
        "stake",
        "deposit",
        "withdraw"
    ]

    for _dict in _rewardCal_model_list:
        if contains_element(_dict["Function"].name, _stake_and_unstake_funcNames_list):
            continue

        if not is_relyOn_stakeTime(_dict, _defiStaking_model_dict, _contract):
            _RT_list.append(_dict["Function"])

    # 输出结果
    # for _func in _RT_list:
    #     print("Function ", _func.name, " calculate the reward without considering the time delay of staking")
    
    # print("")

    return _RT_list

# 判断计算收益的函数是否依赖质押时间
def is_relyOn_stakeTime(_calculation_dict, _defiStaking_model_dict, _contract: Contract):
    # 获取质押时间相关的变量
    _stakeTime_ssrVar_list = _defiStaking_model_dict["Variables"]["User Stake Time"]
    _special_stakeTime_varNames_list = [
        "block.timestamp", 
        "block.number",
        "now"
    ]

    if len(_stakeTime_ssrVar_list) > 0:
        return True

    # 判断是否与solidity自带的时间戳有关
    # for _func in _contract.functions_and_modifiers:
    #     for _var in _func.variables_read:
    #         if _var.name in _special_stakeTime_varNames_list:
    #             return True

    _target_func = _calculation_dict["Function"]
    for _var in _target_func.variables_read:
        if _var.name in _special_stakeTime_varNames_list:
            return True

    for _ssr_var in _target_func.variables_read:
        if _ssr_var.name in _special_stakeTime_varNames_list:
            return True
    
    _set_called_funcs = contract_analyzer.get_calledFuncs_set_fromFunc(_target_func, _target_func.contract)
    for _called_func in _set_called_funcs:
        for _var in _called_func.variables_read:
            if _var != None:
                if _var.name in _special_stakeTime_varNames_list:
                    return True

    # 判断是否与自定义的质押时间变量相关
    for _ssr_var in _calculation_dict["Full Calculation Variables"]:
        if _ssr_var in _stakeTime_ssrVar_list:
            return True
        
        for _stakeTime_ssr_var in _stakeTime_ssrVar_list:
            if _stakeTime_ssr_var is None:
                if _ssr_var.variable == _stakeTime_ssr_var.variable:
                    return True

        if _ssr_var.expression() in _special_stakeTime_varNames_list:
            return True
      
    return False


# ******************************************************************************
# Single Liquidity Pool Reliance (SLR)
# ******************************************************************************

def get_SLR_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _SLR_set = set()
    _SLR_list = []

    # print("Start to detect Single Liquidity Pool Reliance (SLR) defects...")

    # 获取流动性池地址变量列表
    _lpPool_var_list = get_lpPool_var_list(_contract)
    
    for key in _defiStaking_model_dict["Calculations"].keys():
        for _model_dict in _defiStaking_model_dict["Calculations"][key]:
            _lp_count = 0
            for _ssr_var in _model_dict["Full Calculation Variables"]:
                if _ssr_var.variable in _lpPool_var_list:
                    _lp_count += 1
                    
            if _lp_count == 1:        
                _SLR_set.add(_model_dict["Function"])

    _SLR_list = list(_SLR_set)

    # 输出结果
    # for _defect_func in _SLR_list:
    #     print("The token amount in Function ", _defect_func.name, " is relying on a single liquidity pool")
    
    # print("")

    return _SLR_list

# 获取流动性池地址变量列表
def get_lpPool_var_list(_contract: Contract):
    _lpPool_var_set = set()

    for _var in _contract.state_variables:
        if isVar_lpPool(_var):
            _lpPool_var_set.add(_var)
    
    _lpPool_var_list = list(_lpPool_var_set)

    return _lpPool_var_list


# 判断一个变量是否为流动性池地址变量
def isVar_lpPool(_var):
    try:
        _var_type = _var.type.type
        if type(_var_type).__name__ == "Contract":
            if isContract_lpPool(_var_type):
                return True
        else:
            return False
    
    except:
        return False

    return False

# 判断一个合约是否是流动性池合约
def isContract_lpPool(_contract: Contract):
    lpPool_name_list = [
        "IPancakePair",
        "PancakePair",
        "IUniswapV2Pair",
        "UniswapV2Pair"
    ]

    lpPool_functions_list = [
        "mint",
        "burn",
        "swap",
        "skim",
        "getReserves"
    ]

    if _contract.name in lpPool_name_list:
        return True
    
    _func_list = []
    for _func in _contract.functions:
        _func_list.append(_func.name)
    
    if set(lpPool_functions_list).issubset(set(_func_list)):
        return True

    return False



# ******************************************************************************
# Omission in Status Update (OSU)
# ******************************************************************************

def get_OSU_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _OSU_defects_list = []

    # print("Start to detect Omission in Status Update (OSU) defects...")

    # 对于Stake函数
    _OSU_stake_defects_list = get_OSU_stake_defects(_contract, _defiStaking_model_dict, _contract_path)
    _OSU_defects_list.extend(_OSU_stake_defects_list)

    # 对于getReward函数
    # _OSU_reward_defects_list = get_OSU_reward_defects(_contract, _defiStaking_model_dict, _contract_path)
    _OSU_reward_defects_list = get_OSU_stakeReward_defects(_contract, _defiStaking_model_dict, _contract_path)
    _OSU_defects_list.extend(_OSU_reward_defects_list)

    # 对于unStake函数
    _OSU_unstake_defects_list = get_OSU_unstake_defects(_contract, _defiStaking_model_dict, _contract_path)
    _OSU_defects_list.extend(_OSU_unstake_defects_list)

    # 对于Stake Time函数
    _OSU_stakeTime_defects_list = get_OSU_stakeTime_defects(_contract, _defiStaking_model_dict, _contract_path)
    _OSU_defects_list.extend(_OSU_stakeTime_defects_list)

    # 输出结果
    # for _defect_dict in _OSU_defects_list:
    #     _defect_func = _defect_dict["Function"]
    #     _defect_type = _defect_dict["Defect Type"]
    #     _status_type = _defect_dict["Status Type"]
    #     _status_ssr_var = _defect_dict["Status Variable"]

    #     if _defect_type == "omission":
    #         print("In Function ", _defect_func.name, ", the status of ", _status_type, " is not updated in the function")
    #     elif _defect_type == "error":
    #         print("In Function ", _defect_func.name, ", the status of ", _status_type, "of variable ", _status_ssr_var, " is updated with an error")

    # print("")
 
    return _OSU_defects_list

# 对于stake函数
# 1. 检测是否存在Stake Amount状态变量，且未对其进行修改
# 2. 检测是否存在Stake Time状态变量，且未对其进行修改
def get_OSU_stake_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _OSU_stake_list = []

    _stakeCal_model_list = _defiStaking_model_dict["Calculations"]["Stake"]

    for _dict in _stakeCal_model_list:
        # 判断函数是否是claimReward或unstake函数，以降低假阳性
        _func_name = _dict["Function"].name
        if contains_element(_func_name, ["claim", "reward"]):
            continue

        if contains_element(_func_name, ["unstake", "withdraw"]):
            continue

        _modifyAmount_nodeAndAmount_list = get_nodes_directly_modify_amount(_contract, _dict["Function"], _defiStaking_model_dict, _contract_path)
        _modifyTime_nodeAndTime_list = get_nodes_directly_modify_time(_contract, _dict["Function"], _defiStaking_model_dict, _contract_path)

        # 检测是否未对Stake Amount进行修改
        if len(_modifyAmount_nodeAndAmount_list) == 0 and len(_defiStaking_model_dict["Variables"]["User Stake Amount"]) > 0:
            _defect_dict = {}

            _defect_dict["Function"] = _dict["Function"]
            _defect_dict["Status Type"] = "stake amount"
            _defect_dict["Defect Type"] = "omission"
            _defect_dict["Status Variable"] = None

            _OSU_stake_list.append(_defect_dict)
            
        # # 检测是否未对Stake Time进行修改
        # if len(_modifyTime_nodeAndTime_list) == 0 and len(_defiStaking_model_dict["Variables"]["User Stake Time"]) > 0:
        #     _defect_dict = {}

        #     _defect_dict["Function"] = _dict["Function"]
        #     _defect_dict["Status Type"] = "stake time"
        #     _defect_dict["Defect Type"] = "omission"
        #     _defect_dict["Status Variable"] = None

        #     _OSU_stake_list.append(_defect_dict)

    return _OSU_stake_list

# 对于getReward函数：
# 1. 检测是否存在Stake Reward状态变量，且未对其进行修改
# 2. 检测Stake Reward状态变量是否在转账之前被修改
# 3. 检测Stake Time状态变量是否在转账之前被修改
def get_OSU_reward_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _OSU_reward_list = []

    _rewardCal_model_list = _defiStaking_model_dict["Calculations"]["getReward"]

    # 只判断getReward函数是否修改reward
    for _dict in _rewardCal_model_list:
        # 判断函数是否是unstake函数，以降低假阳性
        _func_name = _dict["Function"].name
        if contains_element(_func_name, ["unstake", "withdraw"]):
            continue

        if contains_element(_func_name, ["deposit"]):
            continue
        
        _modifyReward_nodeAndReward_list = get_nodes_directly_modify_reward(_contract, _dict["Function"], _defiStaking_model_dict, _contract_path)
        _modifyTime_nodeAndTime_list = get_nodes_directly_modify_time(_contract, _dict["Function"], _defiStaking_model_dict, _contract_path)
        _transfer_node_list = _dict["Node"]

        for _transfer_node in _transfer_node_list:
            # 检测是否未对Stake Reward进行修改
            if len(_modifyReward_nodeAndReward_list) == 0 and len(_defiStaking_model_dict["Variables"]["User Stake Reward"]) > 0:
                _defect_dict = {}

                _defect_dict["Function"] = _dict["Function"]
                _defect_dict["Status Type"] = "stake reward"
                _defect_dict["Defect Type"] = "omission"
                _defect_dict["Status Variable"] = None

                _OSU_reward_list.append(_defect_dict)
            
            # 检测是否未对Stake Time进行修改
            # if len(_modifyTime_nodeAndTime_list) == 0 and len(_defiStaking_model_dict["Variables"]["User Stake Time"]) > 0:
            #     _defect_dict = {}

            #     _defect_dict["Function"] = _dict["Function"]
            #     _defect_dict["Status Type"] = "stake time"
            #     _defect_dict["Defect Type"] = "omission"
            #     _defect_dict["Status Variable"] = None

            #     _OSU_reward_list.append(_defect_dict)

            # # 检测Stake Reward状态修改是否在转账之前
            # if len(_modifyReward_nodeAndReward_list) > 0:
            #     for _modifyReward_nodeAndReward_dict in _modifyReward_nodeAndReward_list:
            #         _modifyReward_node = _modifyReward_nodeAndReward_dict["Node"]
            #         if contract_analyzer.get_deyond_node(_transfer_node, _modifyReward_node) == _transfer_node:
            #             _defect_dict = {}

            #             _defect_dict["Function"] = _dict["Function"]
            #             _defect_dict["Status Type"] = "stake reward"
            #             _defect_dict["Defect Type"] = "error"
            #             _defect_dict["Status Variable"]  = _modifyReward_nodeAndReward_dict["Variable"]

            #             _OSU_reward_list.append(_defect_dict)

            # # 检测Stake Time状态修改是否在转账之前
            # if len(_modifyTime_nodeAndTime_list) > 0:
            #     for _modifyTime_nodeAndTime_dict in _modifyTime_nodeAndTime_list:
            #         _modifyTime_node = _modifyTime_nodeAndTime_dict["Node"]
            #         if contract_analyzer.get_deyond_node(_transfer_node, _modifyTime_node) == _transfer_node:
            #             _defect_dict = {}

            #             _defect_dict["Function"] = _dict["Function"]
            #             _defect_dict["Status Type"] = "stake time"
            #             _defect_dict["Defect Type"] = "error"
            #             _defect_dict["Status Variable"]  = _modifyTime_nodeAndTime_dict["Variable"]

            #             _OSU_reward_list.append(_defect_dict)

    return _OSU_reward_list

# 判断所有函数是否修改reward
def get_OSU_stakeReward_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _OSU_stakeTime_list = []

    if len(_defiStaking_model_dict["Variables"]["User Stake Reward"]) == 0:
        return []

    for _func in _contract.functions_and_modifiers:
        _modifystakeTime_nodeAndReward_list = get_nodes_directly_modify_reward(_contract, _func, _defiStaking_model_dict, _contract_path)
        if len(_modifystakeTime_nodeAndReward_list) > 0:
            return []
    
    _defect_dict = {}

    _defect_dict["Function"] = None
    _defect_dict["Status Type"] = "stake reward"
    _defect_dict["Defect Type"] = "omission"
    _defect_dict["Status Variable"] = None

    _OSU_stakeTime_list.append(_defect_dict)

    return _OSU_stakeTime_list


def get_OSU_unstake_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _OSU_unstake_list = []

    _unstakeCal_model_list = _defiStaking_model_dict["Calculations"]["unStake"]

    for _dict in _unstakeCal_model_list:
        # 判断函数是否是stake或者claimReward函数，以降低假阳性
        _func_name = _dict["Function"].name
        if contains_element(_func_name, ["claim", "reward"]):
            continue

        if contains_element(_func_name, ["deposit"]):
            continue

        # 判断是否为质押NFT，质押NFT无需验证amount
        is_NFT = False
        for _var in _dict["Function"].variables_read:
            if _var.name in ["i", "id"]:
                is_NFT = True
                break
        
        if not is_NFT:
            continue

        _modifyAmount_nodeAndAmount_list = get_nodes_directly_modify_amount(_contract, _dict["Function"], _defiStaking_model_dict, _contract_path)
        _modifystakeTime_nodeAndTime_list = get_nodes_directly_modify_time(_contract, _dict["Function"], _defiStaking_model_dict, _contract_path)
        _transfer_node_list = _dict["Node"]

        for _transfer_node in _transfer_node_list:
            # 检测是否未对Stake Amount进行修改
            if len(_modifyAmount_nodeAndAmount_list) == 0 and len(_defiStaking_model_dict["Variables"]["User Stake Amount"]) > 0:
                _defect_dict = {}

                _defect_dict["Function"] = _dict["Function"]
                _defect_dict["Status Type"] = "stake amount"
                _defect_dict["Defect Type"] = "omission"
                _defect_dict["Status Variable"] = None

                _OSU_unstake_list.append(_defect_dict)
            
            # 检测是否对Stake Time进行修改
            # if len(_modifystakeTime_nodeAndTime_list) == 0:
                # _defect_dict = {}

                # _defect_dict["Function"] = _dict["Function"]
                # _defect_dict["Status Type"] = "stake time"
                # _defect_dict["Defect Type"] = "omission"
                # _defect_dict["Status Variable"] = None

                # _OSU_unstake_list.append(_defect_dict)

            # # 检测Stake Amount状态修改是否在转账之前
            # if len(_modifyAmount_nodeAndAmount_list) > 0:
            #     for _modifyAmount_nodeAndAmount_dict in _modifyAmount_nodeAndAmount_list:
            #         _modifyAmount_node = _modifyAmount_nodeAndAmount_dict["Node"]
            #         if contract_analyzer.get_deyond_node(_transfer_node, _modifyAmount_node) == _transfer_node:
            #             _defect_dict = {}

            #             _defect_dict["Function"] = _dict["Function"]
            #             _defect_dict["Status Type"] = "stake amount"
            #             _defect_dict["Defect Type"] = "error"
            #             _defect_dict["Status Variable"]  = _modifyAmount_nodeAndAmount_dict["Variable"]

            #             _OSU_unstake_list.append(_defect_dict)

            # # 检测Stake Time状态修改是否在转账之前
            # if len(_modifystakeTime_nodeAndTime_list) > 0:
            #     for _modifystakeTime_nodeAndTime_dict in _modifystakeTime_nodeAndTime_list:
            #         _modifystakeTime_node = _modifystakeTime_nodeAndTime_dict["Node"]
            #         if contract_analyzer.get_deyond_node(_transfer_node, _modifystakeTime_node) == _transfer_node:
            #             _defect_dict = {}

            #             _defect_dict["Function"] = _dict["Function"]
            #             _defect_dict["Status Type"] = "stake time"
            #             _defect_dict["Defect Type"] = "error"
            #             _defect_dict["Status Variable"]  = _modifystakeTime_nodeAndTime_dict["Variable"]

            #             _OSU_unstake_list.append(_defect_dict)

    return _OSU_unstake_list

def get_OSU_stakeTime_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _OSU_stakeTime_list = []

    if len(_defiStaking_model_dict["Variables"]["User Stake Time"]) == 0:
        return []
    
    # _staking_funcs_list = list(set(_defiStaking_model_dict["Functions"]["Stake"]) | set(_defiStaking_model_dict["Functions"]["unStake"]) | set(_defiStaking_model_dict["Functions"]["getReward"]))

    for _func in _contract.functions_and_modifiers:
    # for _func in _staking_funcs_list:
        _modifystakeTime_nodeAndTime_list = get_nodes_directly_modify_time(_contract, _func, _defiStaking_model_dict, _contract_path)
        if len(_modifystakeTime_nodeAndTime_list) > 0:
            return []
    
    _defect_dict = {}

    _defect_dict["Function"] = None
    _defect_dict["Status Type"] = "stake time"
    _defect_dict["Defect Type"] = "omission"
    _defect_dict["Status Variable"] = None

    _OSU_stakeTime_list.append(_defect_dict)

    return _OSU_stakeTime_list


def contains_element(input_string, string_list):
    # 将输入字符串转换为小写，避免大小写问题
    input_string_lower = input_string.lower()
    
    # 遍历字符串列表，检查是否有元素在输入字符串中
    for element in string_list:
        if element.lower() in input_string_lower:
            return True  # 如果找到匹配的元素，返回True
    return False  # 如果没有任何元素匹配，返回False


# 获取函数中直接修改质押金额的节点
def get_nodes_directly_modify_amount(_contract: Contract, _target_func: Function, _defiStaking_model_dict, _contract_path):
    # 初始化变量
    _modifyAmount_nodeAndAmount_list = []

    _amount_ssrVar_list = _defiStaking_model_dict["Variables"]["User Stake Amount"]
    # 目标函数中的节点直接修改变量的情况
    for _node in _target_func.nodes:
        for _amount_ssrVar in _amount_ssrVar_list:
            if contract_analyzer.isNode_directly_modify_varOrElem(_node, _amount_ssrVar, _contract_path):
                _modifyAmount_nodeAndAmount_dict = {}

                _modifyAmount_nodeAndAmount_dict["Node"] = _node
                _modifyAmount_nodeAndAmount_dict["Variable"] = _amount_ssrVar
                _modifyAmount_nodeAndAmount_dict["Type"] = "amount"

                _modifyAmount_nodeAndAmount_list.append(_modifyAmount_nodeAndAmount_dict)

    _special_modifyAmount_funcNames_list = [
        "mint",
        "burn",
        "burnFrom"
    ]

    # 目标函数调用的函数中节点直接修改变量的情况
    _called_funcs_list = contract_analyzer.get_calledFuncs_set_fromNode(_target_func, _contract)
    for _called_func in _called_funcs_list:
        for _node in _called_func.nodes:
            for _amount_ssrVar in _amount_ssrVar_list:
                if contract_analyzer.isNode_directly_modify_varOrElem(_node, _amount_ssrVar, _contract_path):
                    _modifyAmount_nodeAndAmount_dict = {}

                    _modifyAmount_nodeAndAmount_dict["Node"] = _node
                    _modifyAmount_nodeAndAmount_dict["Variable"] = _amount_ssrVar
                    _modifyAmount_nodeAndAmount_dict["Type"] = "amount"

                    _modifyAmount_nodeAndAmount_list.append(_modifyAmount_nodeAndAmount_dict)
        
        if _called_func.name in _special_modifyAmount_funcNames_list:
            # if len(_called_func.nodes) > 0 and len(_amount_ssrVar_list) > 0:
            _modifyAmount_nodeAndAmount_dict = {}
            _modifyAmount_nodeAndAmount_dict["Node"] = None
            _modifyAmount_nodeAndAmount_dict["Variable"] = None
            _modifyAmount_nodeAndAmount_dict["Type"] = "amount"

            _modifyAmount_nodeAndAmount_list.append(_modifyAmount_nodeAndAmount_dict)
    

    return _modifyAmount_nodeAndAmount_list

# 获取函数中直接修改质押收益的节点
def get_nodes_directly_modify_reward(_contract: Contract, _target_func: Function, _defiStaking_model_dict, _contract_path):
    # 初始化变量
    _modifyReward_nodeAndReward_list = []

    _reward_ssrVar_list = _defiStaking_model_dict["Variables"]["User Stake Reward"]
    # 目标函数中的节点直接修改变量的情况
    for _node in _target_func.nodes:
        for _reward_ssrVar in _reward_ssrVar_list:
            if contract_analyzer.isNode_directly_modify_varOrElem(_node, _reward_ssrVar, _contract_path):
                _modifyReward_nodeAndReward_dict = {}
                _modifyReward_nodeAndReward_dict["Node"] = _node
                _modifyReward_nodeAndReward_dict["Variable"] = _reward_ssrVar
                _modifyReward_nodeAndReward_dict["Type"] = "reward"

                _modifyReward_nodeAndReward_list.append(_modifyReward_nodeAndReward_dict)

    # 目标函数调用的函数中节点直接修改变量的情况
    _called_funcs_list = contract_analyzer.get_calledFuncs_set_fromNode(_target_func, _contract)
    for _called_func in _called_funcs_list:
        for _node in _called_func.nodes:
            for _reward_ssrVar in _reward_ssrVar_list:
                if contract_analyzer.isNode_directly_modify_varOrElem(_node, _reward_ssrVar, _contract_path):
                    _modifyReward_nodeAndReward_dict = {}
                    _modifyReward_nodeAndReward_dict["Node"] = _node
                    _modifyReward_nodeAndReward_dict["Variable"] = _reward_ssrVar
                    _modifyReward_nodeAndReward_dict["Type"] = "reward"

                    _modifyReward_nodeAndReward_list.append(_modifyReward_nodeAndReward_dict)

    return _modifyReward_nodeAndReward_list

# 获取函数中直接修改质押时间的节点
def get_nodes_directly_modify_time(_contract: Contract, _target_func: Function, _defiStaking_model_dict, _contract_path):
    # 初始化变量
    _modifyTime_nodeAndTime_list = []

    _time_ssrVar_list = _defiStaking_model_dict["Variables"]["User Stake Time"]
    # 目标函数中的节点直接修改变量的情况
    for _node in _target_func.nodes:
        _is_modifyTime_node = False
        for _time_ssrVar in _time_ssrVar_list:
            # 修改LLM提取到的质押时间变量
            if contract_analyzer.isNode_directly_modify_varOrElem(_node, _time_ssrVar, _contract_path):
                _modifyTime_nodeAndTime_dict = {}
                _modifyTime_nodeAndTime_dict["Node"] = _node
                _modifyTime_nodeAndTime_dict["Variable"] = _time_ssrVar
                _modifyTime_nodeAndTime_dict["Type"] = "time"

                _modifyTime_nodeAndTime_list.append(_modifyTime_nodeAndTime_dict)

                _is_modifyTime_node = True
        
        # 修改LLM未提取到的质押时间变量或者获取收益的时间变量
        if not _is_modifyTime_node:
            for _read_var in _node.variables_read:
                if _read_var is None:
                    continue

                if _read_var.name == 'block.timestamp' or _read_var.name == 'block.number' or _read_var.name == 'now':
                    if len(_node.state_variables_written) > 0:
                        for _write_var in _node.state_variables_written:
                            _write_ssrVar_set = contract_analyzer.get_ssrVar_from_varAndNode(_write_var, _node, _contract_path)
                            for _write_ssrVar in _write_ssrVar_set:
                                _modifyTime_nodeAndTime_dict = {}
                                _modifyTime_nodeAndTime_dict["Node"] = _node
                                _modifyTime_nodeAndTime_dict["Variable"] = _write_ssrVar
                                _modifyTime_nodeAndTime_dict["Type"] = "time"

                                _modifyTime_nodeAndTime_list.append(_modifyTime_nodeAndTime_dict)


    _called_funcs_list = contract_analyzer.get_calledFuncs_set_fromNode(_target_func, _contract)
    for _called_func in _called_funcs_list:
        for _node in _called_func.nodes:
            _is_modifyTime_node = False
            for _time_ssrVar in _time_ssrVar_list:
                # 修改LLM提取到的质押时间变量
                if contract_analyzer.isNode_directly_modify_varOrElem(_node, _time_ssrVar, _contract_path):
                    _modifyTime_nodeAndTime_dict = {}
                    _modifyTime_nodeAndTime_dict["Node"] = _node
                    _modifyTime_nodeAndTime_dict["Variable"] = _time_ssrVar
                    _modifyTime_nodeAndTime_dict["Type"] = "time"

                    _modifyTime_nodeAndTime_list.append(_modifyTime_nodeAndTime_dict)

                    _is_modifyTime_node = True
            
            # 修改LLM未提取到的质押时间变量或者获取收益的时间变量
            if not _is_modifyTime_node:
                for _read_var in _node.variables_read:
                    if _read_var is None:
                        continue

                    if _read_var.name == 'block.timestamp' or _read_var.name == 'block.number' or _read_var.name == 'now':
                        if len(_node.state_variables_written) > 0:
                            for _write_var in _node.state_variables_written:
                                _write_ssrVar_set = contract_analyzer.get_ssrVar_from_varAndNode(_write_var, _node, _contract_path)
                                for _write_ssrVar in _write_ssrVar_set:
                                    _modifyTime_nodeAndTime_dict = {}
                                    _modifyTime_nodeAndTime_dict["Node"] = _node
                                    _modifyTime_nodeAndTime_dict["Variable"] = _write_ssrVar
                                    _modifyTime_nodeAndTime_dict["Type"] = "time"

                                    _modifyTime_nodeAndTime_list.append(_modifyTime_nodeAndTime_dict)

    return _modifyTime_nodeAndTime_list


# ******************************************************************************
# Unsafe Verifications (UV)
# ******************************************************************************

def get_UV_defects(_contract: Contract, _defiStaking_model_dict, _contract_path):
    _UV_list = []

    # print("Start to detect Unsafe Verifications (UV) defects...")

    # # 验证合约中的敏感函数是否满足安全验证
    # _sensitive_funcs_list = _defiStaking_model_dict["Functions"]["Sensitive Functions"]
    # _list_2control_func, _ = getFunc_2control(_contract)
    # for _sensitive_func in _sensitive_funcs_list:
    #     if not isFunc_underSafeVerification(_sensitive_func, _list_2control_func):
    #         _UV_list.append({
    #             "Defect Function": _sensitive_func,
    #             "Type": "Sensitive"
    #         })
        
    # 验证claimReward函数是否验证Stake Reward是否充足
    _claimReward_model_dict_list = _defiStaking_model_dict["Calculations"]["getReward"]
    _stakeReward_ssrVars_list = _defiStaking_model_dict["Variables"]["User Stake Reward"]

    if len(_stakeReward_ssrVars_list) > 0:
        for _claimReward_dict in _claimReward_model_dict_list:
            # 判断函数是否是stake或者unstake函数，以降低假阳性
            if contains_element(_claimReward_dict["Function"].name, ["stake", "desposit", "withdraw"]):
                continue

            # 首先判断DeFi Staking建模中提取到的控制变量中是否包含Stake Reward变量
            _intersection = set(_claimReward_dict["Control Variables"]).intersection(_stakeReward_ssrVars_list)
            if len(_intersection) > 0:
                continue

            # # 然后判断该函数中读取的变量是否包含Stake Reward变量，以降低假阳性
            # if isFunc_verifyVariables(_claimReward_dict["Function"], _stakeReward_ssrVars_list, _contract_path):
            #     continue
            _is_verify_reward = False
            for _func in _contract.functions_and_modifiers:
                if isFunc_verifyVariables(_func, _stakeReward_ssrVars_list, _contract_path):
                    _is_verify_reward = True
                    break
            if _is_verify_reward:
                continue

            _UV_list.append({
                "Defect Function": _claimReward_dict["Function"],
                "Type": "Reward Verification"
            })

    # 验证unStake函数是否验证Stake Amount是否充足
    _unStake_model_dict_list = _defiStaking_model_dict["Calculations"]["unStake"]
    _stakeAmount_ssrVars_list = _defiStaking_model_dict["Variables"]["User Stake Amount"]

    if len(_stakeAmount_ssrVars_list) > 0:
        for _unStake_dict in _unStake_model_dict_list:
            # 判断函数是否是stake或者getReward函数，以降低假阳性
            if contains_element(_unStake_dict["Function"].name, ["claim", "reward", "desposit"]):
                continue

            # 首先判断DeFi Staking建模中提取到的控制变量中是否包含Stake Amount变量
            _intersection = set(_unStake_dict["Control Variables"]).intersection(_stakeAmount_ssrVars_list)
            if len(_intersection) > 0:
                continue

            # 然后判断该函数中读取的变量是否包含Stake Amount变量，以降低假阳性
            if isFunc_verifyVariables(_unStake_dict["Function"], _stakeAmount_ssrVars_list, _contract_path):
                continue

            _UV_list.append({
                "Defect Function": _unStake_dict["Function"],
                "Type": "Amount Verification"
                })
    
    # 输出结果
    # for _defect_func in _UV_list:
    #     print("Sensitive function " + _defect_func.name + " is not under safe verification.")
    
    # print("")

    return _UV_list

# 判断在指定函数中是否对部分变量的取值进行验证
def isFunc_verifyVariables(_function: Function, _ssrVars_list, contract_path):
    _verified_varables_set = set()

    for _node in _function.nodes:
        for _read_var in _node.variables_read:
            _read_ssrVar_set = contract_analyzer.get_ssrVar_from_varAndNode(_read_var, _node, contract_path)
            _verified_varables_set.update(_read_ssrVar_set)
    
    _verified_variables_list = sorted(list(_verified_varables_set), key=lambda x: x.expression())

    _intersection = set(_verified_variables_list).intersection(_ssrVars_list)

    if len(_intersection) > 0:
        return True
    else:
        return False


# 判断函数是否满足安全验证
def isFunc_underSafeVerification(_function: Function, _list_2control_func):
    # 使用modifier进行安全验证的情况
    if _function in _list_2control_func:
        return True
    else:
        for _node in _function.nodes:
            try:
                for _called_func in _node.internal_calls:
                    if _called_func in _list_2control_func:
                        return True
                
            except:
                pass
    
    # 使用require语句进行安全验证的情况
                        
    return False

# 检测合约中的合约所有者地址变量
def getVar_Owner(conc: Contract):
    _set_owner_var = set()
    _list_filtered_var = []

    _list_init_var = getVar_Init(conc)
    for _var in _list_init_var:
        if "address" in str(_var.type):
            if (not str(_var.type) == 'mapping(address => uint256)') and (not str(_var.type) == 'mapping(address => mapping(address => uint256))'):
                if not str(_var.name) == 'uniswapV2Pair':
                    # _list_filtered_var.append(_var)
                    _set_owner_var.add(_var)
    
    _list_owner_var = sorted(list(_set_owner_var), key=lambda x: x.name)
    return _list_owner_var

# 检测合约中的所有初始化变量
def getVar_Init(conc: Contract):
    _set_init_var = set()
    _list_constructors = []
    if len(conc.constructors) > 0:
        _list_constructors = conc.constructors
    for _func in conc.functions:
        if str(_func.name).find("init"):
            _list_constructors.append(_func)

    if len(_list_constructors) == 0:
        return []

    for _constructor in _list_constructors:
        try: 
            for _node in _constructor.nodes:
                for _var in _node.state_variables_written:
                    _set_init_var.add(_var)
                for _called_func in _node.internal_calls:
                    for _called_node in _called_func.nodes:
                        for _called_var in _called_node.state_variables_written:
                            _set_init_var.add(_called_var)
        except:
            pass
    _list_init_var = sorted(list(_set_init_var), key=lambda x: x.name)

    return _list_init_var

# 检测合约中的所有控制的控制函数或modifier
def getFunc_2control(_contract: Contract):
    special_control_funcs_list = [
        "onlyOwner",
        "onlyGovernance",
        "onlyAdmin",
        "onlyOperator",
        "initializer"
    ]

    special_control_keywords_list = [
        "only",
        "owner",
        "admin",
        "governance",
        "operator",
        "whitelist",
        "initializer"
    ]

    _list_limited_func = []
    _set_limited_func = set()
    _set_limited_node = set()

    _list_owner_var = getVar_Owner(_contract)

    for _func in _contract.functions_and_modifiers:
        if _func.is_constructor == False and _func.is_fallback == False:
            for _node in _func.nodes:
                for _read_var in _node.variables_read:
                    if is_dependent(_read_var, SolidityVariableComposed("msg.sender"), _node):
                        for _owner_var in _list_owner_var:
                            if is_dependent(_read_var, _owner_var, _node):
                                _set_limited_node.add(_node)
                                _set_limited_func.add(_func)
                for _ir in _node.irs:
                    for _read_var in _ir.read:
                        if is_dependent(_read_var, SolidityVariableComposed("msg.sender"), _node):
                            for _owner_var in _list_owner_var:
                                if is_dependent(_read_var, _owner_var, _node):
                                    _set_limited_node.add(_node)
                                    _set_limited_func.add(_func)

        # if _func.name in special_control_funcs_list:
        if contains_element(_func.name, special_control_keywords_list):
            _set_limited_func.add(_func)

    _list_limited_node = sorted(list(_set_limited_node), key = lambda x: x.node_id)
    _list_limited_func = sorted(list(_set_limited_func), key = lambda x: x.name)

    return _list_limited_func, _list_limited_node



# ******************************************************************************
# Unauthorized User Funds Access (UFA)
# ******************************************************************************

def get_UFA_defects(_contract: Contract, _defiStaking_model_dict):
    _UFA_list = []

    # print("Start to detect Unauthorized User Funds Access (UFA) defects...")

    _defiStaking_funcs_set = set()
    for _funcs_list in _defiStaking_model_dict["Functions"].values():
        for _func in _funcs_list:
            _defiStaking_funcs_set.add(_func)

    _transfer_funcAndNode_list = contract_analyzer.get_transfer_funcsAndnodes_list(_contract)

    for _funcAndNode_dict in _transfer_funcAndNode_list:
        if isTransfer_unauthorized(_funcAndNode_dict):
            _transfer_func = _funcAndNode_dict["Function"]

            if _transfer_func.is_constructor:
                continue

            if _transfer_func in _defiStaking_funcs_set:
                continue

            if _transfer_func.visibility == "public" or _transfer_func.visibility == "external":
                _UFA_list.append(_funcAndNode_dict)

    # 输出结果
    # for _defect_dict in _UFA_list:
    #     _defect_func = _defect_dict["Function"]
    #     _defect_node = _defect_dict["Node"]
    #     print("In function " + _defect_func.name + ", token transfer in line " + str(_defect_node.source_mapping.lines) + " is not under unauthorized funds access.")
    
    # print("")

    return _UFA_list

# 判断一个交易是否未经授权
def isTransfer_unauthorized(_transfer_dict):
    _is_unauthorized = False

    _is_address_verified = False
    _is_arg_input = False

    _transfer_func = _transfer_dict["Function"]
    _transfer_node = _transfer_dict["Node"]
    
    try:
        # 验证函数输入中是否存在地址变量
        _input_address_list = []
        for _para in _transfer_func.parameters:
            if _para.type.type == "address":
                _input_address_list.append(_para)
        
        # 验证是否对输入地址进行检查
        if len(_input_address_list) > 0:
            for _node in _transfer_func.nodes:
                for _input_address_var in _input_address_list:
                    if is_addressVar_verification(_input_address_var, _node):
                        _is_address_verified = True

        # 验证transfer的对象是否是自定义且未经过检查的地址
        # 根据智能合约转账的ERC规范来寻找转账金额的参数
        _address_vars_set = set()
        _arg_num = len(_transfer_node.expression.arguments)
        # transfer(address, amount)的情况
        if _arg_num == 2:
            # 提取转账对象变量名称
            _address_Arg = _transfer_node.expression.arguments[0]
            _address_vars_set = contract_analyzer.get_vars_fromArg(_address_Arg)
        # transferFrom(from, to, amount)的情况
        elif _arg_num == 3:
            _from_Arg = _transfer_node.expression.arguments[0]
            _to_Arg = _transfer_node.expression.arguments[1]
            _from_vars_set = contract_analyzer.get_vars_fromArg(_from_Arg)
            _to_vars_set = contract_analyzer.get_vars_fromArg(_to_Arg)
            _address_vars_set = _from_vars_set.union(_to_vars_set)
        
        for _input_address_var in _input_address_list:
            if _input_address_var in _address_vars_set:
                _is_arg_input = True
                break
        
        _is_unauthorized = _is_arg_input and not _is_address_verified 
    
    except:
        pass

    return _is_unauthorized

# 判断一个地址变量是否经过msg.sender的验证
def is_addressVar_verification(_address_var: Variable, _node: Node):
    _is_verification = False

    _is_contain_msgsender = False
    _is_contain_inputAddress = False

    for _read_var in _node.variables_read:
        if _read_var is None:
            continue

        if _read_var.name == "msg.sender":
            _is_contain_msgsender = True

        if _read_var == _address_var:
            _is_contain_inputAddress = True

    _is_verification = _is_contain_msgsender and _is_contain_inputAddress

    return _is_verification

# 判断一个函数是否验证输入地址的权限
def is_func_Not_verify_inputAddress(_func: Function):
    if len(_func.parameters) == 0:
        return False

    _address_para_list = []
    for _para in _func.parameters:
        if _para.type.type == "address":
            _address_para_list.append(_para)
        
    if len(_address_para_list) == 0:
        return False
    
    for _node in _func.nodes:
        for _address_para in _address_para_list:
            if is_addressVar_verification(_address_para, _node):
                return False
    
    return True


# ******************************************************************************
# Revolving Unstaking or Claiming Rewards (RUC) [Removed]
# ******************************************************************************

def get_RUC_defects(_contract: Contract, _defiStaking_model_dict):
    _RUC_list = []

    # print("Start to detect Revolving Unstaking or Claiming Rewards (RUC) defects...")

    _reward_calModel_list = _defiStaking_model_dict["Calculations"]["getReward"]
    _unstake_calModel_list = _defiStaking_model_dict["Calculations"]["unStake"]

    # for _dict in _reward_calModel_list:
    #     _target_func = _dict["Function"]
    #     _target_node = _dict["Node"]

    #     _loop_nodesLines_set = get_loop_nodes(_target_func, _contract)
    #     if set(_target_node.source_mapping.lines).issubset(_loop_nodesLines_set):
    #         _defect_dict = {
    #             "Function": _target_func,
    #             "Node": _target_node
    #         }
    #         _RUC_list.append(_defect_dict)

    # for _dict in _unstake_calModel_list:
    #     _target_func = _dict["Function"]
    #     _target_node = _dict["Node"]

    #     _loop_nodesLines_set = get_loop_nodes(_target_func, _contract)
    #     if set(_target_node.source_mapping.lines).issubset(_loop_nodesLines_set):
    #         _defect_dict = {
    #             "Function": _target_func,
    #             "Node": _target_node
    #         }
    #         _RUC_list.append(_defect_dict)

    _reward_funcs_list = _defiStaking_model_dict["Functions"]["getReward"]
    _unstake_funcs_list = _defiStaking_model_dict["Functions"]["unStake"]
    _transfer_funcsAndnodes_list = contract_analyzer.get_transfer_funcsAndnodes_list(_contract)
    for _transfer_dict in _transfer_funcsAndnodes_list:
        _transfer_func = _transfer_dict["Function"]
        _transfer_node = _transfer_dict["Node"]

        if _transfer_func not in _reward_funcs_list and _transfer_func not in _unstake_funcs_list:
            continue

        _loop_nodesLines_set = get_loop_nodes(_transfer_func, _contract)
        if set(_transfer_node.source_mapping.lines).issubset(_loop_nodesLines_set):
            _defect_dict = {
                "Function": _transfer_func,
                "Node": _transfer_node
            }
            _RUC_list.append(_defect_dict)

    # 输出结果
    # for _defect_dict in _RUC_list:
    #     _defect_func = _defect_dict["Function"]
    #     _defect_node = _defect_dict["Node"]
    #     print("In function " + _defect_func.name + ", revolving unstaking or claiming rewards exists in lines " + str(_defect_node.source_mapping.lines))
    
    # print("")

    return _RUC_list

def get_loop_nodes(_target_func: Function, _contract: Contract):
    _loop_nodesLines_set = set()

    for _node in _target_func.nodes:
        if hasattr(_node, "type") and hasattr(_node.type, "name"):
            if _node.type.name == "STARTLOOP":
                _loop_nodesLines_list = _node.source_mapping.lines
                for _line in _loop_nodesLines_list:
                    _loop_nodesLines_set.add(_line)

    _called_funcs_set = contract_analyzer.get_calledFuncs_set_fromFunc(_target_func, _contract)
    for _called_func in _called_funcs_set:
        for _node in _called_func.nodes:
            if hasattr(_node, "type") and hasattr(_node.type, "name"):
                if _node.type.name == "STARTLOOP":
                    _loop_nodesLines_list = _node.source_mapping.lines
                    for _line in _loop_nodesLines_list:
                        _loop_nodesLines_set.add(_line)

    return _loop_nodesLines_set


# ******************************************************************************
# Defects Identifier
# ******************************************************************************

def detect_defects(contract: Contract, _defiStaking_model_dict, _contract_path):
    # print("Start to detect DeFi Stakingdefects...")
    _defects_dict = {}

    _CVM_dict = get_CVM_defects(contract, _defiStaking_model_dict, _contract_path)
    _defects_dict["Critical Variables Manipulation (CVM)"] = _CVM_dict

    _RT_list = get_RT_defects(contract, _defiStaking_model_dict)
    _defects_dict["Rewards without Timedelay (RT)"] = _RT_list

    _SLR_list = get_SLR_defects(contract, _defiStaking_model_dict, _contract_path)
    _defects_dict["Single Liquidity Pool Reliance (SLR)"] = _SLR_list

    _OSU_list = get_OSU_defects(contract, _defiStaking_model_dict, _contract_path)
    _defects_dict["Omission in Status Update (OSU)"] = _OSU_list

    _UV_list = get_UV_defects(contract, _defiStaking_model_dict, _contract_path)
    _defects_dict["Unsafe Verifications (UV)"] = _UV_list

    _UFA_list = get_UFA_defects(contract, _defiStaking_model_dict)
    _defects_dict["Unauthorized User Funds Access (UFA)"] = _UFA_list

    # _RUC_list = get_RUC_defects(contract, _defiStaking_model_dict)
    # _defects_dict["Revolving Unstaking or Claiming Rewards (RUC)"] = _RUC_list
    

    return _defects_dict

# ******************************************************************************
# Output
# ******************************************************************************

def output_defects(_defects_dict, _output_folder_path, _project_name):
    # print("Start to output defects information...")
    _defects_funcs_path = os.path.join(_output_folder_path + "/defects", _project_name + ".json")
    _detail_path = os.path.join(_output_folder_path + "/details", _project_name + ".txt")

    # 输出结果
    output_defects_funcs(_defects_dict, _defects_funcs_path)
    output_defects_details(_defects_dict, _detail_path)

    # print("Output defects information successfully!")

# 输出漏洞函数
def output_defects_funcs(_defects_dict, _defects_funcs_path):
    # 判断文件是否存在
    if os.path.exists(_defects_funcs_path):
        # 如果存在，删除文件
        os.remove(_defects_funcs_path)
    
    # 创建一个新的空白文件
    os.makedirs(os.path.dirname(_defects_funcs_path), exist_ok=True)
    with open(_defects_funcs_path, 'w') as file:
        pass

    defect_funcNames_dict = {}
    _CVM_funcNames_set = set()
    _RT_funcNames_set = set()
    _SLR_funcNames_set = set()
    _OSU_funcNames_set = set()
    _UV_funcNames_set = set()
    _UFA_funcNames_set = set()
    
    # CVM
    for _dict in _defects_dict["Critical Variables Manipulation (CVM)"]["Calculation"]:
        _defectFunc_name = _dict["Defect Function"].name
        _CVM_funcNames_set.add(_defectFunc_name)
    for _dict in _defects_dict["Critical Variables Manipulation (CVM)"]["Balance"]:
        _defectFunc_name = _dict["Defect Function"].name
        _CVM_funcNames_set.add(_defectFunc_name)
    
    # RT
    for _func in _defects_dict["Rewards without Timedelay (RT)"]:
        _RT_funcNames_set.add(_func.name)
    
    # SLR
    for _func in _defects_dict["Single Liquidity Pool Reliance (SLR)"]:
        _SLR_funcNames_set.add(_func.name)

    # OSU
    for _dict in _defects_dict["Omission in Status Update (OSU)"]:
        if _dict["Status Type"] == "stake time":
            _OSU_funcNames_set.add("All for Time")
        elif _dict["Status Type"] == "stake reward":
            _OSU_funcNames_set.add("All for Reward")
        else:
            _defectFunc_name = _dict["Function"].name
            _OSU_funcNames_set.add(_defectFunc_name)
    
    # UV
    for _dict in _defects_dict["Unsafe Verifications (UV)"]:
        _defectFunc_name = _dict["Defect Function"].name
        _UV_funcNames_set.add(_defectFunc_name)

    # UFA
    for _dict in _defects_dict["Unauthorized User Funds Access (UFA)"]:
        _defectFunc_name = _dict["Function"].name
        _UFA_funcNames_set.add(_defectFunc_name)
    
    _CVM_funcNames_list = sorted(list(_CVM_funcNames_set))
    _RT_funcNames_list = sorted(list(_RT_funcNames_set))
    _SLR_funcNames_list = sorted(list(_SLR_funcNames_set))
    _OSU_funcNames_list = sorted(list(_OSU_funcNames_set))
    _UV_funcNames_list = sorted(list(_UV_funcNames_set))
    _UFA_funcNames_list = sorted(list(_UFA_funcNames_set))

    defect_funcNames_dict["Critical Variables Manipulation (CVM)"] = _CVM_funcNames_list
    defect_funcNames_dict["Rewards without Timedelay (RT)"] = _RT_funcNames_list
    defect_funcNames_dict["Single Liquidity Pool Reliance (SLR)"] = _SLR_funcNames_list
    defect_funcNames_dict["Omission in Status Update (OSU)"] = _OSU_funcNames_list
    defect_funcNames_dict["Unsafe Verifications (UV)"] = _UV_funcNames_list
    defect_funcNames_dict["Unauthorized User Funds Access (UFA)"] = _UFA_funcNames_list

    with open(_defects_funcs_path, 'w', encoding='utf-8') as file:
        json.dump(defect_funcNames_dict, file, indent=4)


# 输出详细结果
def output_defects_details(_defects_dict, _detail_path):
    # 判断文件是否存在
    if os.path.exists(_detail_path):
        # 如果存在，删除文件
        os.remove(_detail_path)

    os.makedirs(os.path.dirname(_detail_path), exist_ok=True)
    with open(_detail_path, 'w') as file:
        pass

    # 输出CVM
    _string = "Critical Variables Manipulation (CVM):"
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write(_string + '\n')

    for _defect_dict in _defects_dict["Critical Variables Manipulation (CVM)"]["Calculation"]:
        _defectFunc_name = _defect_dict["Defect Function"].name
        _cal_ssrVar_name = _defect_dict["Calculation Variable"].expression()
        _calType = _defect_dict["Calculation Type"]
        _calFunc_name = _defect_dict["Calculation Function"].name
        _string = "Function " + _defectFunc_name + " is able to modify the value of Variable " + _cal_ssrVar_name + ", which will influence the transfer of " + _calType + " tokens in Function " + _calFunc_name
        with open(_detail_path, 'a', encoding='utf-8') as file:
            file.write(_string + '\n')

    for _defect_dict in _defects_dict["Critical Variables Manipulation (CVM)"]["Balance"]:
        _defectFunc_name = _defect_dict["Defect Function"].name
        _calType = _defect_dict["Calculation Type"]
        _calFunc_name = _defect_dict["Calculation Function"].name
        _string = "In Function " + _calFunc_name + ", the balance of this contract is used to calculate the amount of " + _calType + " tokens, which can be modified by Function " + _defectFunc_name
        with open(_detail_path, 'a', encoding='utf-8') as file:
            file.write(_string + '\n')
    
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write('\n')

    # 输出RT
    _string = "Rewards without Timedelay (RT):"
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write(_string + '\n')

    for _defect_func in _defects_dict["Rewards without Timedelay (RT)"]:
        _string = "Function " + _defect_func.name + " calculate the reward without considering the time delay of staking"
        with open(_detail_path, 'a', encoding='utf-8') as file:
            file.write(_string + '\n')

    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write('\n')
    
    # 输出SLR
    _string = "Single Liquidity Pool Reliance (SLR):"
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write(_string + '\n')

    for _defect_func in _defects_dict["Single Liquidity Pool Reliance (SLR)"]:
        _string = "The token amount in Function " + _defect_func.name + " is relying on a single liquidity pool"
        with open(_detail_path, 'a', encoding='utf-8') as file:
            file.write(_string + '\n')

    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write('\n')

    # 输出OSU
    _string = "Omission in Status Update (OSU):"
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write(_string + '\n')

    for _defect_dict in _defects_dict["Omission in Status Update (OSU)"]:
        _defect_func = _defect_dict["Function"]
        _defect_type = _defect_dict["Defect Type"]
        _status_type = _defect_dict["Status Type"]

        if _status_type == "stake time":
            _string = "No function in the contract updates the stake time status"
        elif _status_type == "stake reward":
            _string = "No function in the contract updates the stake reward status"
        else:
            if _defect_type == "omission":
                _string = "In Function " + _defect_func.name + ", the status of " + _status_type + " is not updated in the function"
            elif _defect_type == "error":
                _string = "In Function " + _defect_func.name + ", the status of " + _status_type + " is updated with an error"

        with open(_detail_path, 'a', encoding='utf-8') as file:
            file.write(_string + '\n')

    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write('\n')

    # 输出UV
    _string = "Unsafe Verifications (UV):"
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write(_string + '\n')

    for _defect_dict in _defects_dict["Unsafe Verifications (UV)"]:
        _defect_func = _defect_dict["Defect Function"]
        _defect_type = _defect_dict["Type"]
        if _defect_type == "Sensitive":
            _string = "Sensitive Function " + _defect_func.name + " is not under safe verification"
            with open(_detail_path, 'a', encoding='utf-8') as file:
                file.write(_string + '\n')
        if _defect_type == "Amount Verification":
            _string = "Function " + _defect_func.name + " does not verify the amount of staked tokens"
            with open(_detail_path, 'a', encoding='utf-8') as file:
                file.write(_string + '\n')
        if _defect_type == "Reward Verification":
            _string = "Function " + _defect_func.name + " does not verify the reward amount"
            with open(_detail_path, 'a', encoding='utf-8') as file:
                file.write(_string + '\n')
    
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write('\n')
    
    # 输出UFA
    _string = "Unauthorized User Funds Access (UFA):"
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write(_string + '\n')
    
    for _defect_dict in _defects_dict["Unauthorized User Funds Access (UFA)"]:
        _defect_func = _defect_dict["Function"]
        _defect_node = _defect_dict["Node"]
        _string = "In function " + _defect_func.name + ", token transfer in line " + str(_defect_node.source_mapping.lines) + " is not under unauthorized funds access."
        with open(_detail_path, 'a', encoding='utf-8') as file:
            file.write(_string + '\n')
    
    with open(_detail_path, 'a', encoding='utf-8') as file:
        file.write('\n')


# ******************************************************************************
# Main
# ******************************************************************************
def defects_identifier_singleProject(project_name, _contract_folder_path, _defiStaking_Infos_folder_path, _defiStaking_model_folder_path, _output_folder_path):
    # 读取DeFi Staking合约信息
    _defiStaking_Infos_path = os.path.join(_defiStaking_Infos_folder_path, project_name + ".json")
    _defiStaking_model_path = os.path.join(_defiStaking_model_folder_path, project_name + ".json")
    _contract_path = os.path.join(_contract_folder_path, project_name + ".sol")
    _output_defects_path = os.path.join(_output_folder_path + "/details", project_name + ".txt")

    _defiStaking_Infos_dict = read_defiStaking_Infos(_defiStaking_Infos_path)

    # 验证合约源码文件是否存在
    if not os.path.exists(_contract_path):
        logger.error(f"Contract file not found: {_contract_path}")
        raise FileNotFoundError(f"Contract file not found: {_contract_path}")
    
    # 验证该项目的DeFi Staking Defects是否已经检测过了，省时间
    if os.path.exists(_output_defects_path):
        logger.info(f"DeFi Staking Defects already exists: {project_name}")
        raise RuntimeError(f"DeFi Staking Defects already exists: {project_name}")
    
    setup_global_solc(_contract_path)
    # 验证合约是否可被Slither分析
    if not contract_analyzer.is_contract_analyzable(_contract_path):
        logger.info(f"Contract is not analyzable by Slither: {project_name}")
        raise RuntimeError(f"Contract is not analyzable by Slither: {project_name}")
    
    slither_obj = Slither(_contract_path)

    # 读取DeFi Staking模型
    # 如何模型信息已经存在，则直接读取，否则，构造模型
    if os.path.exists(_defiStaking_model_path):
        try:
            _defiStaking_model_dict_read = read_defiStaking_model(slither_obj, _defiStaking_model_path, _contract_path)
        except:
            logger.error(f"Failed to Read DeFi Staking Model for Project: {project_name}")
          
    else:
        try:
            _defiStaking_model_dict = construct_defiStaking_model(slither_obj, _defiStaking_Infos_dict, _contract_path)
            logger.info(f"DeFi Staking Model Constructed for Project: {project_name}")
            _defiStaking_model_dict_read = _defiStaking_model_dict
        except:
            logger.error(f"Failed to Construct DeFi Staking Model for Project: {project_name}")

        # 输出DeFi Staking模型
        try:
            # _output_model_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/2_model/model"
            _output_model_path = os.path.join(_defiStaking_model_folder_path, project_name + ".json")
            output_defiStaking_model_to_json(_defiStaking_model_dict, _output_model_path)
            logger.info(f"DeFi Staking Model Outputted for Project: {project_name}")
        except:
            logger.error(f"Failed to Output DeFi Staking Model for Project: {project_name}")

    # DeFi Staking漏洞检测
    # try:
    # 漏洞检测
    _main_contract = get_MainContract(slither_obj)
    defects_dict = detect_defects(_main_contract, _defiStaking_model_dict_read, _contract_path)
    logger.info(f"DeFi Staking Defects Identified for Project: {project_name}")
    # except:
    #     logger.error(f"Failed to Identified DeFi Staking Defects for Project: {project_name}")

    # 输出DeFi Staking漏洞检测结果
    try:
        output_defects(defects_dict, _output_folder_path, project_name)
        logger.info(f"DeFi Staking Defects Outputted for Project: {project_name}")
    except:
        logger.error(f"Failed to Output DeFi Staking Defects for Project: {project_name}")

    # 计算DeFi Staking建模及漏洞检测的准确率
    # try:
    # _groundTruth_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/1_groundTruth"
    # _metrics_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/4_metrics/groundTruth"

    # _metrics_output_path = os.path.join(_metrics_folder_path, project_name + ".json")

    # _defects_output_path = os.path.join(_output_folder_path + "/defects", project_name + ".json")
    # _groundTruth_json_path = os.path.join(_groundTruth_folder_path, project_name + ".json")

    # metrics_analysis.output_total_metrics_perProject(_groundTruth_json_path, _defiStaking_model_path, _defects_output_path, _metrics_output_path)
    # logger.info(f"DeFi Staking Defects Metrics Calculated for Project: {project_name}")
    # except:
    #     logger.error(f"Failed to Calculate DeFi Staking Defects Metrics for Project: {project_name}")




if __name__ == "__main__":
    # ******************************************************************************
    # groundTruth
    # ******************************************************************************  
    # # 检测在一个文件夹下的所有sol文件
    # target_sol_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/groundTruth"
    # project_name_list = contract_analyzer.get_projectNams_from_folder(target_sol_folder_path)

    # # LLM提取的DeFi Staking合约信息路径的json文件路径
    # defiStaking_Infos_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/2_model/infos"
    
    # # 构建的DeFi Staking模型的json文件路径
    # defiStaking_model_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/2_model/model"
    
    # # 合约路径
    # contract_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/groundTruth"

    # # 输出漏洞检测结果的路径
    # output_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/3_defects"

    # # metrics_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/4_metrics/groundTruth"
    # # groundTruth_metrics_json_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/4_metrics/groundTruth_metrics.json"

    # ***************************************************************
    # Single Project
    # ***************************************************************
    # project_name = "PopsicleFinance"

    # contract_path = "/mnt/linzw3/work/defistaking/1_Datasets/groundTruth/" + project_name + ".sol"
    # setup_global_solc(contract_path)
    # slither_obj = Slither(contract_path)
    # main_contract = get_MainContract(slither_obj)

    # defiStaking_model_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/2_model/model/" + project_name + ".json"
    # defiStaking_Infos_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/2_model/infos/" + project_name + ".json"
    # defiStaking_Infos_dict = read_defiStaking_Infos(defiStaking_Infos_path)
    # defiStaking_model_dict = construct_defiStaking_model(slither_obj, defiStaking_Infos_dict, contract_path)

    # output_model_path = "/mnt/linzw3/work/defistaking/3_Experiment/groundTruth/2_model/model/" + project_name + ".json" 
    # output_defiStaking_model_to_json(defiStaking_model_dict, output_model_path)
    # defiStaking_model_dict_read = read_defiStaking_model(slither_obj,output_model_path, contract_path)

    # defects_dict = detect_defects(main_contract, defiStaking_model_dict_read, contract_path)

    # output_defects(defects_dict, "/mnt/linzw3/work/defistaking/SSR/temp", project_name)
    
    # defects_identifier_singleProject(project_name, contract_folder_path, defiStaking_Infos_folder_path, defiStaking_model_folder_path, output_folder_path)

    # ***************************************************************
    # Multiple Projects
    # ***************************************************************

    # for project_name in tqdm(project_name_list):
    #     print("Analying project: ", project_name)
    #     try:
    #         defects_identifier_singleProject(project_name, contract_folder_path, defiStaking_Infos_folder_path, defiStaking_model_folder_path, output_folder_path)
    #     except:
    #         pass

    # print("The number of projects to be analyzed: ", contract_analyzer.count_files_in_directory(contract_folder_path))
    # print("The number of projects analyzed: ", contract_analyzer.count_files_in_directory(output_folder_path + "/defects"))


    # ***************************************************************
    # largeScale
    # ***************************************************************

    # ***************************************************************
    # Multiple Projects
    # ***************************************************************
    # 待分析的公链名称
    chain_name_list = [
        "ethereum",
        "bsc",
        "arbitrum",
        "avalanche",
        "celo",
        "fantom",
        "optimism",
        "polygon",
        "tron"
    ]

    contract_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale/final"
    defiStaking_Infos_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/infos"
    defiStaking_model_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/model"
    output_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/2_defects"

    for chain_name in chain_name_list:
        # 更新每个公链对应的路径信息
        defiStaking_Infos_folder_path_perChain = os.path.join(defiStaking_Infos_folder_path, chain_name)
        defiStaking_model_folder_path_perChain = os.path.join(defiStaking_model_folder_path, chain_name)
        contract_folder_path_perChain = os.path.join(contract_folder_path, chain_name)
        output_folder_path_perChain = os.path.join(output_folder_path, chain_name)

        # 获取该公链下所有项目名称
        files = os.listdir(defiStaking_Infos_folder_path_perChain)
        project_name_list_perChain = [os.path.splitext(file)[0] for file in files if file.endswith('.json')]

        for project_name in tqdm(project_name_list_perChain):
            print("Analying project: ", project_name)
            try:
                defects_identifier_singleProject(project_name, contract_folder_path_perChain, defiStaking_Infos_folder_path_perChain, defiStaking_model_folder_path_perChain, output_folder_path_perChain)
            except:
                pass
            

    # ***************************************************************
    # Single Project
    # ***************************************************************
    # chain_name = "ethereum"
    # contract_name = "c1fb414ef8767e1a6460bf4ec1c7e9eb46699960_HOStaking"
    

    # contract_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale/final/" + chain_name + "/" + contract_name + ".sol"
    # setup_global_solc(contract_path)
    # slither_obj = Slither(contract_path)
    # main_contract = get_MainContract(slither_obj)

    # defiStaking_model_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/model/" + chain_name + "/" + contract_name + ".json"
    # defiStaking_Infos_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/infos/" + chain_name + "/" + contract_name + ".json"
    # defiStaking_Infos_dict = read_defiStaking_Infos(defiStaking_Infos_path)
    # defiStaking_model_dict = construct_defiStaking_model(slither_obj, defiStaking_Infos_dict, contract_path)

    # output_model_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/model/" + chain_name + "/" + contract_name + ".json"  
    # output_defiStaking_model_to_json(defiStaking_model_dict, output_model_path)
    # defiStaking_model_dict_read = read_defiStaking_model(slither_obj,output_model_path, contract_path)

    # defects_dict = detect_defects(main_contract, defiStaking_model_dict_read, contract_path)

    # output_defects(defects_dict, "/mnt/linzw3/work/defistaking/SSR/temp", contract_name)


    # **************************************************************
    # Test
    # ***************************************************************
    # # files = os.listdir(defiStaking_Infos_folder_path + "/analyzable/ethereum")
    # # project_name_list_perChain = [os.path.splitext(file)[0] for file in files if file.endswith('.json')]
    # # project_name = project_name_list_perChain[7]

    # # contract_path = os.path.join(contract_folder_path + "/analyzable/ethereum", project_name + ".sol")
    # contract_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale/final/ethereum/b6dbc8dfac6ae4b7946d28c19c0dbf9e97c937d7_ShijaStake.sol"
    # setup_global_solc(contract_path)
    # slither_obj = Slither(contract_path)
    # main_contract = get_MainContract(slither_obj)

    # # defiStaking_model_path = os.path.join(defiStaking_model_folder_path, project_name + ".json")
    # defiStaking_model_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/model/ethereum/b6dbc8dfac6ae4b7946d28c19c0dbf9e97c937d7_ShijaStake.json"
    # # defiStaking_model_dict_read = read_defiStaking_model(slither_obj, defiStaking_model_path, contract_path)
    # # defiStaking_Infos_path = os.path.join(defiStaking_Infos_folder_path + "/analyzable/ethereum", project_name + ".json")
    # defiStaking_Infos_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/infos/ethereum/b6dbc8dfac6ae4b7946d28c19c0dbf9e97c937d7_ShijaStake.json"
    # defiStaking_Infos_dict = read_defiStaking_Infos(defiStaking_Infos_path)
    # defiStaking_model_dict = construct_defiStaking_model(slither_obj, defiStaking_Infos_dict, contract_path)
    # # defiStaking_model_dict_read = defiStaking_model_dict

    # # output_model_path = os.path.join(defiStaking_model_folder_path + "/analyzable/ethereum", project_name + ".json")
    # output_model_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/model/ethereum/b6dbc8dfac6ae4b7946d28c19c0dbf9e97c937d7_ShijaStake.json"
    # output_defiStaking_model_to_json(defiStaking_model_dict, output_model_path)
    # defiStaking_model_dict_read = read_defiStaking_model(slither_obj,output_model_path, contract_path)

    # defects_dict = detect_defects(main_contract, defiStaking_model_dict_read, contract_path)

    # # output_defects(defects_dict, output_folder_path + "/analyzable/ethereum", project_name)
    # output_defects(defects_dict, "/mnt/linzw3/work/defistaking/SSR/temp", "b6dbc8dfac6ae4b7946d28c19c0dbf9e97c937d7_ShijaStake")

    # print("testing...")
    # for func in main_contract.functions:
    #     if func.name == "unstakeSUF":
    #         func_unstakeSUF = func

    # modifyTime_nodeAndTime_list = get_nodes_directly_modify_time(main_contract, func_unstakeSUF, defiStaking_model_dict, contract_path)


    
    

    


    print("aha!")
