import os
import json
import re
import logging
from tqdm import tqdm

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

from inter.contract_analyzer import get_MainContract, SSR_Variable

import inter.contract_analyzer as contract_analyzer

# ******************************************************
# Global setting
# ******************************************************

# 日志配置
# 创建 logger 对象
logger = logging.getLogger(__name__)  # 通常使用模块的 __name__ 作为 logger 的名字
logger.setLevel(logging.DEBUG)  # 设置最低的日志级别

# 创建文件处理器，将日志写入指定文件
log_file = '/mnt/linzw3/work/defistaking/SSR/ssr/logs/defiStaking_model.log'  # 指定日志文件的路径和名称
file_handler = logging.FileHandler(log_file)
file_handler.setLevel(logging.DEBUG)  # 设置文件处理器的日志级别

# 创建日志格式器，并将其添加到文件处理器
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

# 将文件处理器添加到 logger
logger.addHandler(file_handler)

# **********************************************************************
# DeFi Staking Informations
# **********************************************************************

# 读取利用大模型提取的DeFi Staking合约基本信息。
def read_defiStaking_Infos(_json_path):
    """
    读取利用大模型提取的DeFi Staking合约基本信息。

    参数:
        _json_path (str): 包含DeFi Staking合约基本信息的JSON文件的路径。
        
    返回:
        dict: 解析后的DeFi Staking合约基本信息的字典。
    """
    try:
        with open(_json_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
            return data
    except FileNotFoundError:
        print(f"错误: 文件 '{_json_path}' 不存在！")
    except json.JSONDecodeError as e:
        print(f"错误: 无法解析 JSON 文件。请检查文件格式是否正确。\n详细信息: {e}")
    except Exception as e:
        print(f"发生未知错误: {e}")

# **********************************************************************
# Variables
# **********************************************************************

# 根据LLM提供的信息，提取DeFi Staking相关的变量信息
def read_defiStaking_Variables(_contract: Contract, _defiStaking_Infos_dict):
    _defiStaking_variables_dict = {}

    for key in _defiStaking_Infos_dict["Variables"].keys():
        _var_list = []
        _varName_list = _defiStaking_Infos_dict["Variables"][key]

        for _varName in _varName_list:
            _var_dict = contract_analyzer.get_stateVar_from_varName_info(_contract, _varName)
            if _var_dict["Variable"] != None:
                _ssr_var = SSR_Variable(_var_dict["Variable"], _var_dict["Element"])
                _var_list.append(_ssr_var)

        _defiStaking_variables_dict[key] = _var_list
    
    return _defiStaking_variables_dict


# **********************************************************************
# Functions
# **********************************************************************

def read_defiStaking_Functions(_contract: Contract, _defiStaking_Infos_dict, _contract_path, _defiStaking_variables_dict):
    # 获取大模型提供的信息
    _stake_functions_set = set()
    _getReward_functions_set = set()
    _unstake_functions_set = set()

    for _func in _contract.functions:
        if _func.is_constructor:
            continue
        
        for _dict in _defiStaking_Infos_dict["Calculations"]["Stake"]:
            if _func.name == _dict["Function"]:
                
                # 如果函数是可被外部调用的，则添加到集合中
                if _func.visibility == "public" or _func.visibility == "external":
                    _stake_functions_set.add(_func)
                
                # 将所有调用了这个函数的外部函数也添加到集合中
                for _reachable_func in _func.all_reachable_from_functions:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        _stake_functions_set.add(_reachable_func)

        for _dict in _defiStaking_Infos_dict["Calculations"]["getReward"]:
            if _func.name == _dict["Function"]:
                if _func.visibility == "public" or _func.visibility == "external":
                    _getReward_functions_set.add(_func)
                
                for _reachable_func in _func.all_reachable_from_functions:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        _getReward_functions_set.add(_reachable_func)

        for _dict in _defiStaking_Infos_dict["Calculations"]["unStake"]:
            if _func.name == _dict["Function"]:
                if _func.visibility == "public" or _func.visibility == "external":
                    _unstake_functions_set.add(_func)
                
                for _reachable_func in _func.all_reachable_from_functions:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        _unstake_functions_set.add(_reachable_func)
    
    # 过滤重名函数
    _stake_functions_set = filter_functions_by_name_and_id(_stake_functions_set)
    _getReward_functions_set = filter_functions_by_name_and_id(_getReward_functions_set)
    _unstake_functions_set = filter_functions_by_name_and_id(_unstake_functions_set)    

    #从合约中提取敏感函数
    _stake_functions_list = sorted(list(_stake_functions_set), key = lambda x: x.name)
    _getReward_functions_list = sorted(list(_getReward_functions_set), key = lambda x: x.name)
    _unstake_functions_list = sorted(list(_unstake_functions_set), key = lambda x: x.name)
    _sensitive_functions_list = get_sensitive_functions(_contract, _defiStaking_Infos_dict, _contract_path, _defiStaking_variables_dict)

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

# 提取合约中跟DeFi Staking相关的的敏感函数。
def get_sensitive_functions(_contract: Contract, _defiStaking_Infos_dict, _contract_path, _defiStaking_variables_dict):
    _sensitive_funcs_list = []
    _sensitive_funcs_set = set()

    # 检测合约中的自毁函数
    _selfdestruct_funcs_set = get_selfdestruct_functions(_contract)
    _sensitive_funcs_set = _sensitive_funcs_set.union(_selfdestruct_funcs_set)

    # 检测合约中的初始化函数
    _init_funcs_set = get_init_functions(_contract, _contract_path, _defiStaking_variables_dict)
    _sensitive_funcs_set = _sensitive_funcs_set.union(_init_funcs_set)

    # 检测合约中的迁移函数
    _migrate_funcs_set = get_migrate_functions(_contract, _contract_path)
    _sensitive_funcs_set = _sensitive_funcs_set.union(_migrate_funcs_set)

    _sensitive_funcs_list = sorted(list(_sensitive_funcs_set), key = lambda x: x.name)

    return _sensitive_funcs_list

# 检测合约中的自毁函数
def get_selfdestruct_functions(_contract: Contract):
    _selfdestruct_func_set = set()

    for _func in _contract.functions:
        for _call in _func.solidity_calls:
            if (_call.name == 'suicide(address)') | (_call.name == 'selfdestruct(address)'):
                _selfdestruct_func_set.add(_func)

    return _selfdestruct_func_set

# 检测合约中的初始化函数
def get_init_functions(_contract: Contract, _contract_path, _defiStaking_variables_dict):
    _init_func_set = set()

    _stakeAddress_ssrVar_list = _defiStaking_variables_dict["Stake Token Address"]
    _rewardAddress_ssrVar_list = _defiStaking_variables_dict["Reward Token Address"]

    for _ssrVar in _stakeAddress_ssrVar_list:
        _modify_stakeAddress_funcs_set = contract_analyzer.get_funcs_modify_ssrVar(_contract, _ssrVar, _contract_path)
        _init_func_set = _init_func_set.union(_modify_stakeAddress_funcs_set)
    
    for _ssrVar in _rewardAddress_ssrVar_list:
        _modify_rewardAddress_funcs_set = contract_analyzer.get_funcs_modify_ssrVar(_contract, _ssrVar, _contract_path)
        _init_func_set = _init_func_set.union(_modify_rewardAddress_funcs_set)

    return _init_func_set

# 检测合约中的迁移函数
def get_migrate_functions(_contract: Contract, _contract_path):
    _migrate_funcs_set = set()

    thisBalance_statement_list = [
        "this.balance",
        "balanceOf(this)",
        "balanceOf(address(this))"
    ]

    _transfer_funcsAndnodes_list = contract_analyzer.get_transfer_funcsAndnodes_list(_contract)

    for _transfer_funcsAndnodes_dict in _transfer_funcsAndnodes_list:
        for _thisBalance_stat in thisBalance_statement_list:
            if contract_analyzer.check_string_in_node(_contract_path, _transfer_funcsAndnodes_dict["Node"], _thisBalance_stat):
                _migrate_funcs_set.add(_transfer_funcsAndnodes_dict["Function"])
                break

    return _migrate_funcs_set


# **********************************************************************
# Calculations
# **********************************************************************

# 获取DeFi Staking合约的计算信息
def read_defiStaking_Calculations(_contract: Contract, _defiStaking_Infos_dict, _contract_path):
    _stake_calculations_list = []
    _getReward_calculations_list = []
    _unStake_calculations_list = []

    # print("Getting Calculation Information of DeFi Staking...")
    # print("Stake Calculation Information: ")
    if len(_defiStaking_Infos_dict["Calculations"]["Stake"]) > 0:
        for _cal_dict in _defiStaking_Infos_dict["Calculations"]["Stake"]:
            _func_name = _cal_dict["Function"]
            _transfer_statement = _cal_dict["Node"]

            # print("getting Infomation of function: [", _func_name, "]")

            _stake_calculations_dict = get_calculation_infos(_contract, _func_name, _transfer_statement, _contract_path)

            if _stake_calculations_dict != {}:
                _stake_func = _stake_calculations_dict["Function"]
                if _stake_func.visibility == "public" or _stake_func.visibility == "external":
                    _stake_calculations_list.append(_stake_calculations_dict)
                
                for _reachable_func in _stake_func.all_reachable_from_functions:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        _reach_stake_calculations_dict = {
                            "Function": _reachable_func,
                            "Node": _stake_calculations_dict["Node"],
                            "Input": _stake_calculations_dict["Input"],
                            "Calculation Variables": _stake_calculations_dict["Calculation Variables"],
                            "Control Variables": _stake_calculations_dict["Control Variables"],
                            "Full Calculation Variables": _stake_calculations_dict["Full Calculation Variables"],
                            "Is Depend on this.balance": _stake_calculations_dict["Is Depend on this.balance"]
                        }
                        _stake_calculations_list.append(_reach_stake_calculations_dict)
                # print('\n')
    _final_stake_calculations_list = merge_calculations_infos_list(_stake_calculations_list)
    
    # print("getReward Calculation Information: ")
    if len(_defiStaking_Infos_dict["Calculations"]["getReward"]) > 0:
        for _cal_dict in _defiStaking_Infos_dict["Calculations"]["getReward"]:
            _func_name = _cal_dict["Function"]
            _transfer_statement = _cal_dict["Node"]

            # print("getting Infomation of function: [", _func_name, "]")

            _getReward_calculations_dict = get_calculation_infos(_contract, _func_name, _transfer_statement, _contract_path)

            if _getReward_calculations_dict != {}:
                _getReward_func = _getReward_calculations_dict["Function"]
                if _getReward_func.visibility == "public" or _getReward_func.visibility == "external":
                    _getReward_calculations_list.append(_getReward_calculations_dict)

                for _reachable_func in _getReward_func.all_reachable_from_functions:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        _reach_getReward_calculations_dict = {
                            "Function": _reachable_func,
                            "Node": _getReward_calculations_dict["Node"],
                            "Input": _getReward_calculations_dict["Input"],
                            "Calculation Variables": _getReward_calculations_dict["Calculation Variables"],
                            "Control Variables": _getReward_calculations_dict["Control Variables"],
                            "Full Calculation Variables": _getReward_calculations_dict["Full Calculation Variables"],
                            "Is Depend on this.balance": _getReward_calculations_dict["Is Depend on this.balance"]
                        }
                        _getReward_calculations_list.append(_reach_getReward_calculations_dict)

            # print('\n')
    _final_getReward_calculations_list = merge_calculations_infos_list(_getReward_calculations_list)

    # print("unStake Calculation Information: ")
    if len(_defiStaking_Infos_dict["Calculations"]["unStake"]) > 0:
        for _cal_dict in _defiStaking_Infos_dict["Calculations"]["unStake"]:
            _func_name = _cal_dict["Function"]
            _transfer_statement = _cal_dict["Node"]

            # print("getting Infomation of function: [", _func_name, "]")

            _unStake_calculations_dict = get_calculation_infos(_contract, _func_name, _transfer_statement, _contract_path)

            if _unStake_calculations_dict != {}:
                _unStake_func = _unStake_calculations_dict["Function"]
                if _unStake_func.visibility == "public" or _unStake_func.visibility == "external":
                    _unStake_calculations_list.append(_unStake_calculations_dict)
                
                for _reachable_func in _unStake_func.all_reachable_from_functions:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        _reach_unStake_calculations_dict = {
                            "Function": _reachable_func,
                            "Node": _unStake_calculations_dict["Node"],
                            "Input": _unStake_calculations_dict["Input"],
                            "Calculation Variables": _unStake_calculations_dict["Calculation Variables"],
                            "Control Variables": _unStake_calculations_dict["Control Variables"],
                            "Full Calculation Variables": _unStake_calculations_dict["Full Calculation Variables"],
                            "Is Depend on this.balance": _unStake_calculations_dict["Is Depend on this.balance"]
                        }
                        _unStake_calculations_list.append(_reach_unStake_calculations_dict)
                
            # print('\n')
    _final_unStake_calculations_list = merge_calculations_infos_list(_unStake_calculations_list)

    _calculations_dict = {
        "Stake": _final_stake_calculations_list,
        "getReward": _final_getReward_calculations_list,
        "unStake": _final_unStake_calculations_list
    }

    return _calculations_dict

# 获取转移token数量计算公式的相关信息
def get_calculation_infos(_contract: Contract, _func_name, _transfer_statement, _contract_path):
    """
    获取转移token数量计算公式的相关信息。
    参数:
        _contract (Contract): 待分析的主合约。
        
    """
    # 初始化变量
    _input_ssrVar_list = []
    _input_ssrVar_set = set()

    _is_dependOn_thisBalance = False

    _target_func = None

    # 获取目标函数
    for _func in _contract.functions:
        if _func.name == _func_name:
            _target_func = _func
    
    if _target_func is None:
        return {}
    
    # if _target_func.visibility != "public" and _target_func.visibility != "external":
    #     return {}

    if _target_func.is_constructor:
        return {}

    # 获取目标函数的输入变量list
    # 注意，inputs理论上不需要是SSR_Variable，因为一般都是直接把整个struct都作为输入参数，而不会只输入其中一个元素
    # 但是为了方便，还是存成了SSR_Variable的形式
    for _para in _target_func.parameters:
        _ssr_para = SSR_Variable(_para, None)
        _input_ssrVar_set.add(_ssr_para)
    
    _input_ssrVar_list = sorted(list(_input_ssrVar_set), key = lambda x: x.expression())

    # 获取转账节点的集合
    _transfer_node_set = contract_analyzer.get_node_from_statement(_target_func, _transfer_statement, _contract, _contract_path)

    # 如果找不到转账节点，则返回空字典
    if len(_transfer_node_set) == 0:
        return {}

    # 从转账语句中找到对应的转账金额
    _transfer_amount_ssrVars_set = set()
    for _transfer_node in _transfer_node_set:
        _transfer_amount_ssrVars_set = _transfer_amount_ssrVars_set.union(get_transferAmount_ssrVars(_transfer_node, _contract_path))
        # 输出转账金额变量
        # for _transfer_amount_ssrVar in _transfer_amount_ssrVars_set:
        #     print("The transfer amount is ", _transfer_amount_ssrVar)

    # 提取转账金额所依赖的变量
    _calRelated_ssrVar_set = get_related_ssrVars_fromVarSet(_transfer_amount_ssrVars_set, _transfer_node_set, _target_func, _contract, _contract_path)

    # 判断转账金额的计算是否依赖于this.balance
    if "balanceOf" in _calRelated_ssrVar_set:
        _calRelated_ssrVar_set.remove("balanceOf")
        for _ssr_var in _calRelated_ssrVar_set:
            if _ssr_var.expression() == "this":
                _is_dependOn_thisBalance = True
                break

    # 过滤掉输入变量
    for _ssr_var in list(_calRelated_ssrVar_set):
        for _input_ssrVar in _input_ssrVar_list:
            if _input_ssrVar.variable == _ssr_var.variable:
                _calRelated_ssrVar_set.remove(_ssr_var)
                continue
    
    # 过滤掉依赖的变量中，正常计算需要用的变量。
    _calRelated_ssrVar_set = filter_calRelated_ssrVars(_calRelated_ssrVar_set)

    # 提取转账语句所依赖的变量
    _control_ssrVar_set = get_control_ssrVars_set(_transfer_node_set, _target_func, _contract_path)
    _controlRelated_ssrVar_set = get_related_ssrVars_fromVarSet(_control_ssrVar_set, _transfer_node_set, _target_func, _contract, _contract_path)

    # 判断控制变量是否依赖于this.balance
    if "balanceOf" in _controlRelated_ssrVar_set:
        _controlRelated_ssrVar_set.remove("balanceOf")
        for _ssr_var in _controlRelated_ssrVar_set:
            if _ssr_var.expression() == "this":
                _is_dependOn_thisBalance = True
                break
    
    for _ssr_var in list(_controlRelated_ssrVar_set):
        for _input_ssrVar in _input_ssrVar_list:
            if _input_ssrVar.variable == _ssr_var.variable:
                _controlRelated_ssrVar_set.remove(_ssr_var)
                continue
    
    # 过滤掉控制变量中，正常计算需要用的变量。
    _controlRelated_ssrVar_set = filter_calRelated_ssrVars(_controlRelated_ssrVar_set)

    _full_calRelated_ssrVar_set = _calRelated_ssrVar_set.union(_controlRelated_ssrVar_set)

    # 输出结果
    _calRelated_ssrVar_list = sorted(list(_calRelated_ssrVar_set), key = lambda x: x.expression())
    _controlRelated_ssrVar_list = sorted(list(_controlRelated_ssrVar_set), key = lambda x: x.expression())
    _full_calRelated_ssrVar_list = sorted(list(_full_calRelated_ssrVar_set), key = lambda x: x.expression())
    _transfer_node_list = sorted(list(_transfer_node_set), key = lambda x: x.node_id)

    _calculations_dict = {}
    _calculations_dict["Function"] = _target_func
    _calculations_dict["Node"] = _transfer_node_list
    _calculations_dict["Input"] = _input_ssrVar_list
    _calculations_dict["Calculation Variables"] = _calRelated_ssrVar_list
    _calculations_dict["Control Variables"] = _controlRelated_ssrVar_list
    _calculations_dict["Full Calculation Variables"] = _full_calRelated_ssrVar_list
    _calculations_dict["Is Depend on this.balance"] = _is_dependOn_thisBalance

    return _calculations_dict

# 合并得到的Calculations模型中可能出现的重复的函数及节点
def merge_calculations_infos_list(_calculations_dict_list):
    merged_calculations_list = []

    _exist_functions_list = []

    for _calculations_dict in _calculations_dict_list:
        _target_func = _calculations_dict["Function"]
        if _target_func not in _exist_functions_list:
            merged_calculations_list.append(_calculations_dict)
            _exist_functions_list.append(_target_func)
        else:
            for _dict in merged_calculations_list:
                if _dict["Function"] == _target_func:
                    _exist_calculations_dict = _dict
                    break
            
            _merged_nodes_list = list(set(_calculations_dict["Node"]) | set(_exist_calculations_dict["Node"]))
            _merged_inputs_list = list(set(_calculations_dict["Input"]) | set(_exist_calculations_dict["Input"]))
            _merged_calculations_variables_list = list(set(_calculations_dict["Calculation Variables"]) | set(_exist_calculations_dict["Calculation Variables"]))
            _merged_control_variables_list = list(set(_calculations_dict["Control Variables"]) | set(_exist_calculations_dict["Control Variables"]))
            _merged_full_cal_variables_list = list(set(_calculations_dict["Full Calculation Variables"]) | set(_exist_calculations_dict["Full Calculation Variables"]))
            _merged_dependBalances_list = _calculations_dict["Is Depend on this.balance"] or _exist_calculations_dict["Is Depend on this.balance"]

            _merged_calculations_dict = {
                "Function": _target_func,
                "Node": _merged_nodes_list,
                "Input": _merged_inputs_list,
                "Calculation Variables": _merged_calculations_variables_list,
                "Control Variables": _merged_control_variables_list,
                "Full Calculation Variables": _merged_full_cal_variables_list,
                "Is Depend on this.balance": _merged_dependBalances_list
            }

            merged_calculations_list.remove(_exist_calculations_dict)
            merged_calculations_list.append(_merged_calculations_dict)

    return merged_calculations_list


# 从转账语句中找到对应的转账金额
def get_transferAmount_ssrVars(_node: Node, _contract_path):
    _amount_vars_set = set()
    _amount_ssrVars_set = set()

    try:
        if contract_analyzer.check_string_in_node(_contract_path, _node, "require("):
            _transfer_argments = _node.expression.arguments[0].arguments
            _arg_num = len(_transfer_argments)

            # transfer(address, amount)的情况
            if _arg_num == 2:
                # 提取转账金额变量名称
                _amount_vars_set = contract_analyzer.get_vars_fromArg(_transfer_argments[1])
            # transferFrom(from, to, amount)的情况
            elif _arg_num == 3:
                _amount_vars_set = contract_analyzer.get_vars_fromArg(_transfer_argments[2])

        else:
            # 根据智能合约转账的ERC规范来寻找转账金额的参数
            _arg_num = len(_node.expression.arguments)
            # transfer(address, amount)的情况
            if _arg_num == 2:
                # 提取转账金额变量名称
                # 这里还有个问题是如果没有预定义的local变量，而是直接使用函数应该怎么办？
                _amount_Arg = _node.expression.arguments[1]
                _amount_vars_set = contract_analyzer.get_vars_fromArg(_amount_Arg)
            # transferFrom(from, to, amount)的情况
            elif _arg_num == 3:
                _amount_Arg = _node.expression.arguments[2]
                _amount_vars_set = contract_analyzer.get_vars_fromArg(_amount_Arg)
            # # 其他情况
            # else:
            #     raise ValueError('Error: 转账函数的参数不符合要求，参数数量为：', _arg_num)
    except:
        pass

    for _var in _amount_vars_set:
        _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_var, _node, _contract_path)
        _amount_ssrVars_set = _amount_ssrVars_set.union(_ssr_var_set)

    _amount_ssrVars_set.discard(None)
    
    return _amount_ssrVars_set



# 获取转账金额变量的取值所依赖的变量
def get_related_ssrVars_fromVarSet(_target_ssrVars_set, _transfer_node_set, _target_func, _contract: Contract, _contract_path):
    # 使用一个堆栈来跟踪需要处理的变量
    _stack = list(_target_ssrVars_set)
    # 用一个集合记录已经访问过的变量，避免重复处理
    _visited_ssrVar_set = set()
    # 用一个集合保存所有依赖的变量，包括自身
    _calRelated_ssrVar_set = set()

    # 当堆栈非空时，继续处理
    while _stack:
        _current_ssrVar = _stack.pop()  # 从堆栈取出当前变量

        # 如果当前变量已经访问过，跳过
        if _current_ssrVar in _visited_ssrVar_set:
            continue

        # 标记当前变量为已访问
        _visited_ssrVar_set.add(_current_ssrVar)
        _calRelated_ssrVar_set.add(_current_ssrVar)

        # 提取某个单一变量所依赖的其他变量
        for _transfer_node in _transfer_node_set:
            _dependent_ssrVar_set = get_dependent_ssrVars_set_fromSingleVar(_current_ssrVar, _transfer_node, _target_func, _contract, _contract_path)

            for _dependent_ssrVar in _dependent_ssrVar_set:
                if _dependent_ssrVar not in _visited_ssrVar_set:
                    _stack.append(_dependent_ssrVar)
    
    _calRelated_ssrVar_set.discard(None)

    return _calRelated_ssrVar_set


# 提取某个单一变量所依赖的变量
# 不要直接调用，这个函数是搭配get_related_ssrVars_fromVarSet使用的
def get_dependent_ssrVars_set_fromSingleVar(_target_ssrVar: SSR_Variable, _transfer_node: Node, _target_func: Function, _contract: Contract, _contract_path):
    # print("Getting Dependent Variables of ", _target_var.name)
    _dependent_ssrVar_set = set()
    _dependent_ssrVar_set.add(_target_ssrVar)

    if _target_ssrVar == "balanceOf":
        return set()

    # 前向寻找依赖变量：寻找定义该变量的节点，然后找到该节点所依赖的变量
    if hasattr(_target_ssrVar.variable, 'expression'):
        if _target_ssrVar.variable.expression is not None:
            # 找到定义_target_var的节点source_node
            _source_lines = _target_ssrVar.variable.expression.source_mapping.lines
            _source_node = contract_analyzer.get_node_from_lineNums(_contract, _source_lines)

            if _source_node is not None:
                # print("Variable [", _target_ssrVar, "] Source Node: ", _source_node.expression.source_mapping.content)
                
                # 提取source_node所依赖的变量
                # source_node直接依赖的变量
                for _var in _source_node.variables_read:
                    _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_var, _source_node, _contract_path)
                    _dependent_ssrVar_set = _dependent_ssrVar_set.union(_ssr_var_set)

                # source_node调用的函数所依赖的变量
                _dependent_func_set = contract_analyzer.get_calledFuncs_set_fromNode(_source_node, _contract)
                # print("Variable [", _target_ssrVar, "] Dependent Functions: ", [_func.name for _func in _dependent_func_set])

                for _func in _dependent_func_set:
                    for _node in _func.nodes[1:]:
                        for _var in _node.variables_read:
                            if _var not in _func.parameters:
                                _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_var, _node, _contract_path)
                                _dependent_ssrVar_set = _dependent_ssrVar_set.union(_ssr_var_set)

                    # 将特殊变量this.balance加入到依赖列表中
                    if _func.name == "balanceOf":
                        _dependent_ssrVar_set.add("balanceOf")

    # 后向寻找依赖变量：检测从定义该变量的节点到转账节点之间变量被修改的情况
    # 找到执行转账操作的节点
    _transfer_node_inFunc = contract_analyzer.get_nodeLocation_inFunc(_transfer_node, _target_func)
    _transfer_node_index = _transfer_node_inFunc.node_id

    for _node in _target_func.nodes[1:_transfer_node_index]:
        # 判断一个节点是否直接修改了_target_var
        _written_var_list = _node.variables_written
        # 如果修改了_target_var，则将该节点所读取的变量加入到依赖列表
        if _target_ssrVar.variable in _written_var_list:
            for _var in _node.variables_read:
                if _var not in _target_func.parameters:
                    _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_var, _node, _contract_path)
                    _dependent_ssrVar_set = _dependent_ssrVar_set.union(_ssr_var_set)

        # 判断一个节点所调用的函数是否修改了_target_var
        _dependent_func_set = contract_analyzer.get_calledFuncs_set_fromNode(_node, _contract)
        for _func in _dependent_func_set:
            for _node in _func.nodes[1:]:
                if _target_ssrVar.variable in _node.variables_written:
                    for _var in _node.variables_read:
                        if _var not in _func.parameters:
                            _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_var, _node, _contract_path)
                            _dependent_ssrVar_set = _dependent_ssrVar_set.union(_ssr_var_set)
            
            if _func.name == "balanceOf":
                _dependent_ssrVar_set.add("balanceOf")

    for _ssr_var in list(_dependent_ssrVar_set):
        if _ssr_var != "balanceOf":
            if _ssr_var.variable is None:
                _dependent_ssrVar_set.remove(_ssr_var)

    # 输出变量依赖信息
    # for _ssr_var in _dependent_ssrVar_set:
    #     if _ssr_var == "balanceOf":
    #         print("Variable [", _target_ssrVar, "] Dependent Variables: balanceOf")
    #     else:
    #         print("Variable [", _target_ssrVar, "] Dependent Variables: ", _ssr_var)

    return _dependent_ssrVar_set


# 过滤Calculation-related Variables中不必要的变量
def filter_calRelated_ssrVars(_calRelated_ssrVar_set):
    _filtered_calRelated_ssrVar_set = set()

    list_special_varNames = [
        "this",
        "msg.sender",
        "_balances",
        "_totalSupply"
    ]

    for _ssrVar in _calRelated_ssrVar_set:
        if _ssrVar is None:
            continue

        # 过滤掉一些特殊变量
        if _ssrVar.expression() in list_special_varNames:
            continue

        # 过滤掉local variables
        if type(_ssrVar.variable).__name__ == 'StateVariable':
            _filtered_calRelated_ssrVar_set.add(_ssrVar)

    return _filtered_calRelated_ssrVar_set

# 获取控制token transfer的变量集合
def get_control_ssrVars_set(_transfer_node_set, _target_func, _contract_path):
    _control_ssrVar_set = set()

    _transfer_node_local_set = set()
    for _transfer_node in _transfer_node_set:
        _transfer_node_local = contract_analyzer.get_nodeLocation_inFunc(_transfer_node, _target_func)
        _transfer_node_local_set.add(_transfer_node_local)

    # 分析转账节点所在函数的控制变量
    for _transfer_node in _transfer_node_set:
        _node_dominators_list = _transfer_node.dominators
        for _dominator_node in _node_dominators_list:
            for _read_var in _dominator_node.variables_read:
                _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_read_var, _dominator_node, _contract_path)
                _control_ssrVar_set = _control_ssrVar_set.union(_ssr_var_set)
    
    # 分析转账函数中调用转账节点所在函数的控制变量
    for _transfer_node_local in _transfer_node_local_set:
        _node_dominators_list = _transfer_node_local.dominators
        for _dominator_node in _node_dominators_list:
            for _read_var in _dominator_node.variables_read:
                _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_read_var, _dominator_node, _contract_path)
                _control_ssrVar_set = _control_ssrVar_set.union(_ssr_var_set)

    # 分析目标函数所调用的modifiers调用的变量集合
    for _modifier in _target_func.modifiers:
        for _read_var in _modifier.state_variables_read:
            _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_read_var, _read_var.node_initialization, _contract_path)
            _control_ssrVar_set = _control_ssrVar_set.union(_ssr_var_set)
        
        # 分析modifier所调用的函数所依赖的变量集合
        _called_funcs_set = contract_analyzer.get_calledFuncs_set_fromFunc(_modifier, _modifier.contract)
        for _called_func in _called_funcs_set:
            for _read_var in _called_func.state_variables_read:
                _ssr_var_set = contract_analyzer.get_ssrVar_from_varAndNode(_read_var, _read_var.node_initialization, _contract_path)
                _control_ssrVar_set = _control_ssrVar_set.union(_ssr_var_set)

    return _control_ssrVar_set

# **********************************************************************
# DeFi Staking Model
# **********************************************************************

# 构建DeFi Staking合约模型。
def construct_defiStaking_model(_slither_obj, _defiStaking_Infos_dict, _contract_path):
    """
    构建DeFi Staking合约模型。

    参数:
        _defiStaking_Infos_dict: 包含DeFi Staking合约基本信息的dict。
        _slither_obj: 利用Slither工具分析合约得到的Slither对象。
        
    返回:
        defiStaking_model_dict: 构建得到的DeFi Staking合约模型。
    """
    defiStaking_model_dict = {}

    # 获取主合约
    _main_contract = get_MainContract(_slither_obj)

    # print("Starting to Construct DeFi Staking Model...")

    # *****************************************
    # 获取deFi Staking相关变量信息
    # *****************************************

    # print("Getting DeFi Staking Variables...")

    variables_dict = read_defiStaking_Variables(_main_contract, _defiStaking_Infos_dict)

    # *****************************************
    # 获取deFi Staking相关函数信息
    # *****************************************

    # print("Getting DeFi Staking Functions...")

    functions_dict = read_defiStaking_Functions(_main_contract, _defiStaking_Infos_dict, _contract_path, variables_dict)

    # *****************************************
    # 获取DeFi Staking相关计算信息
    # *****************************************

    # print("Getting DeFi Staking Calculations...")

    calculations_dict = read_defiStaking_Calculations(_main_contract, _defiStaking_Infos_dict, _contract_path)

    # 整合输出模型
    defiStaking_model_dict["Variables"] = variables_dict
    defiStaking_model_dict["Functions"] = functions_dict
    defiStaking_model_dict["Calculations"] = calculations_dict

    # print("DeFi Staking Model Constructed!")
    
    return defiStaking_model_dict

# 输出DeFi Staking模型到指定json文件路径
# （只输出变量和函数名到json文件，不输出具体的变量和函数信息）
def output_defiStaking_model_to_json(_defiStaking_model_dict, _output_file_path):
    _simplified_model_dict = {}

    # 处理DeFi Staking模型中的变量信息
    _variables_dict = _defiStaking_model_dict["Variables"]
    _simplified_variables_dict = {}
    _simplified_variables_dict["User Stake Amount"] = [_ssr_var.expression() for _ssr_var in _variables_dict["User Stake Amount"]]
    _simplified_variables_dict["User Stake Reward"] = [_ssr_var.expression() for _ssr_var in _variables_dict["User Stake Reward"]]
    _simplified_variables_dict["User Stake Time"] = [_ssr_var.expression() for _ssr_var in _variables_dict["User Stake Time"]]
    _simplified_variables_dict["Stake Token Address"] = [_ssr_var.expression() for _ssr_var in _variables_dict["Stake Token Address"]]
    _simplified_variables_dict["Reward Token Address"] = [_ssr_var.expression() for _ssr_var in _variables_dict["Reward Token Address"]]

    # 处理DeFi Staking模型中的函数信息
    _functions_dict = _defiStaking_model_dict["Functions"]
    _simplified_functions_dict = {}
    _simplified_functions_dict["Stake"] = [_func.name for _func in _functions_dict["Stake"]]
    _simplified_functions_dict["getReward"] = [_func.name for _func in _functions_dict["getReward"]]    
    _simplified_functions_dict["unStake"] = [_func.name for _func in _functions_dict["unStake"]]
    _simplified_functions_dict["Sensitive Functions"] = [_func.name for _func in _functions_dict["Sensitive Functions"]]

    # 处理DeFi Staking模型中的计算信息
    _calculations_dict = _defiStaking_model_dict["Calculations"]
    _simplified_calculations_dict = {}

    _simplified_stake_calculations_list = []
    for _dict in _calculations_dict["Stake"]:
        _simplified_stake_calculations_dict = {}
        _simplified_stake_calculations_dict["Function"] = _dict["Function"].name
        _simplified_stake_calculations_dict["Node"] = _dict["Node"][0].expression.source_mapping.lines
        _simplified_stake_calculations_dict["Input"] = [_ssr_var.expression() for _ssr_var in _dict["Input"]]
        _simplified_stake_calculations_dict["Calculation Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Calculation Variables"]]
        _simplified_stake_calculations_dict["Control Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Control Variables"]]
        _simplified_stake_calculations_dict["Full Calculation Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Full Calculation Variables"]]
        _simplified_stake_calculations_dict["Is Depend on this.balance"] = _dict["Is Depend on this.balance"]

        _simplified_stake_calculations_list.append(_simplified_stake_calculations_dict)
    
    _simplified_getReward_calculations_list = []
    for _dict in _calculations_dict["getReward"]:
        _simplified_getReward_calculations_dict = {}
        _simplified_getReward_calculations_dict["Function"] = _dict["Function"].name
        _simplified_getReward_calculations_dict["Node"] = _dict["Node"][0].expression.source_mapping.lines
        _simplified_getReward_calculations_dict["Input"] = [_ssr_var.expression() for _ssr_var in _dict["Input"]]
        _simplified_getReward_calculations_dict["Calculation Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Calculation Variables"]]
        _simplified_getReward_calculations_dict["Control Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Control Variables"]]
        _simplified_getReward_calculations_dict["Full Calculation Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Full Calculation Variables"]]
        _simplified_getReward_calculations_dict["Is Depend on this.balance"] = _dict["Is Depend on this.balance"]

        _simplified_getReward_calculations_list.append(_simplified_getReward_calculations_dict)
    
    _simplified_unStake_calculations_list = []
    for _dict in _calculations_dict["unStake"]:
        _simplified_unStake_calculations_dict = {}
        _simplified_unStake_calculations_dict["Function"] = _dict["Function"].name
        _simplified_unStake_calculations_dict["Node"] = _dict["Node"][0].expression.source_mapping.lines
        _simplified_unStake_calculations_dict["Input"] = [_ssr_var.expression() for _ssr_var in _dict["Input"]]
        _simplified_unStake_calculations_dict["Calculation Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Calculation Variables"]]
        _simplified_unStake_calculations_dict["Control Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Control Variables"]]
        _simplified_unStake_calculations_dict["Full Calculation Variables"] = [_ssr_var.expression() for _ssr_var in _dict["Full Calculation Variables"]]
        _simplified_unStake_calculations_dict["Is Depend on this.balance"] = _dict["Is Depend on this.balance"]

        _simplified_unStake_calculations_list.append(_simplified_unStake_calculations_dict)

    _simplified_calculations_dict["Stake"] = _simplified_stake_calculations_list
    _simplified_calculations_dict["getReward"] = _simplified_getReward_calculations_list
    _simplified_calculations_dict["unStake"] = _simplified_unStake_calculations_list

    _simplified_model_dict["Variables"] = _simplified_variables_dict
    _simplified_model_dict["Functions"] = _simplified_functions_dict
    _simplified_model_dict["Calculations"] = _simplified_calculations_dict

    os.makedirs(os.path.dirname(_output_file_path), exist_ok=True)
    with open(_output_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(_simplified_model_dict, json_file, ensure_ascii=False, indent=4)

# **********************************************************************
# Main
# **********************************************************************

def get_defiStaking_model_singleProject(project_name, _contract_folder_path, _defiStaking_Infos_folder_path, _output_folder_path):
    # 读取DeFi Staking合约信息
    _defiStaking_Infos_path = os.path.join(_defiStaking_Infos_folder_path, project_name + ".json")
    _contract_path = os.path.join(_contract_folder_path, project_name + ".sol")
    _output_path = os.path.join(_output_folder_path, project_name + ".json")

    _defiStaking_Infos_dict = read_defiStaking_Infos(_defiStaking_Infos_path)

    # 验证合约源码文件是否存在
    if not os.path.exists(_contract_path):
        logger.error(f"Contract file not found: {_contract_path}")
        raise FileNotFoundError(f"Contract file not found: {_contract_path}")
    
    # 验证该项目的DeFi Staking Model是否已经构造过了，省时间
    if os.path.exists(_output_path):
        logger.info(f"DeFi Staking Model already exists: {project_name}")
        raise RuntimeError(f"DeFi Staking Model already exists: {project_name}")
    
    setup_global_solc(_contract_path)
    # 验证合约是否可被Slither分析
    if not contract_analyzer.is_contract_analyzable(_contract_path):
        logger.info(f"Contract is not analyzable by Slither: {project_name}")
        raise RuntimeError(f"Contract is not analyzable by Slither: {project_name}")

    # 构建DeFi Staking模型
    try:
        slither_obj = Slither(_contract_path)
        _defiStaking_model_dict = construct_defiStaking_model(slither_obj, _defiStaking_Infos_dict, _contract_path)
        logger.info(f"DeFi Staking Model Constructed for Project: {project_name}")
    except:
        logger.error(f"Failed to Construct DeFi Staking Model for Project: {project_name}")

    # 输出DeFi Staking模型
    try:
        output_defiStaking_model_to_json(_defiStaking_model_dict, _output_path)
        logger.info(f"DeFi Staking Model Outputted for Project: {project_name}")
    except:
        logger.error(f"Failed to Output DeFi Staking Model for Project: {project_name}")



# **********************************************************************
# Test
# **********************************************************************


    

# 示例用法
if __name__ == "__main__":
    # ***************************************************************
    # 输入
    # ***************************************************************

    # 项目名称

    # # 单个项目
    # # project_name = "KaspaNexus"

    # # 检测在一个文件夹下的所有sol文件
    # target_sol_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/groundTruth"
    # project_name_list = contract_analyzer.get_projectNams_from_folder(target_sol_folder_path)

    # # LLM提取的DeFi Staking合约信息路径的json文件路径
    # defiStaking_Infos_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/2_model/infos"

    # # 合约路径
    # contract_folder_path = "/mnt/linzw3/work/defistaking/1_Datasets/groundTruth"

    # # 输出DeFi Staking模型的路径
    # output_folder_path = "/mnt/linzw3/work/defistaking/3_Experiment/2_model/model"

    # # ***************************************************************
    # # Single Project
    # # ***************************************************************
    # # get_defiStaking_model_singleProject(project_name, contract_folder_path, defiStaking_Infos_folder_path, output_folder_path)

    # # ***************************************************************
    # # Multiple Projects
    # # ***************************************************************

    # for project_name in tqdm(project_name_list):
    #     print("Analying project: ", project_name)
    #     try:
    #         get_defiStaking_model_singleProject(project_name, contract_folder_path, defiStaking_Infos_folder_path, output_folder_path)
    #     except:
    #         pass

    # print("The number of projects to be analyzed: ", contract_analyzer.count_files_in_directory(contract_folder_path))
    # print("The number of projects analyzed: ", contract_analyzer.count_files_in_directory(output_folder_path))
    
    # ***************************************************************
    # Test
    # ***************************************************************
    contract_path = "/mnt/linzw3/work/defistaking/1_Datasets/largeScale/final/analyzable/ethereum/b667b1870afca69058c1728d6b33b32cbf4e7edf_MetaObjectsStakingPool.sol"
    setup_global_solc(contract_path)
    slither_obj = Slither(contract_path)
    main_contract = get_MainContract(slither_obj)

    # defiStaking_Infos_path = os.path.join(defiStaking_Infos_folder_path, project_name + ".json")
    defiStaking_Infos_path = "/mnt/linzw3/work/defistaking/3_Experiment/largeScale/1_model/infos/analyzable/ethereum/b667b1870afca69058c1728d6b33b32cbf4e7edf_MetaObjectsStakingPool.json"
    defiStaking_Infos_dict = read_defiStaking_Infos(defiStaking_Infos_path)

    defiStaking_model_dict = construct_defiStaking_model(slither_obj, defiStaking_Infos_dict, contract_path)


    print('aha!') 
