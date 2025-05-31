import os
import json
import re

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



# *************************************************************************
# Global variables
# *************************************************************************

math_funcNames_list = [
    "add",
    "sub",
    "mul",
    "div"
]

# *************************************************************************
# Basic Analysis
# *************************************************************************

# 判断给定的字符串是否为路径
def is_path(s):
    if s[0] != '/':
        return False
    if '.' in s:
        if '/' in s:
            return True
        else:
            return False
    else:
        if '/' in s:
            return True
        else:
            return False

# 从指定文件夹中获取项目名称list
def get_projectNams_from_folder(folder_path):
    # 获取文件夹中的所有文件
    files = os.listdir(folder_path)
    
    # 过滤出所有以 .sol 结尾的文件，并去掉文件后缀
    project_names = [os.path.splitext(file)[0] for file in files if file.endswith('.sol')]
    
    return project_names

# 计算指定文件夹中所有文件的数量
def count_files_in_directory(directory):
    # 获取目录中所有文件和文件夹的名称
    files = os.listdir(directory)
    # 过滤掉目录中的文件夹，只统计文件
    file_count = sum(1 for f in files if os.path.isfile(os.path.join(directory, f)))
    return file_count


# *************************************************************************
# Variables Analysis
# *************************************************************************

# 定义类型：SSR_Variable
# variable：Slither变量对象
# element：struct变量的元素（如果有）
class SSR_Variable:
    def __init__(self, variable: Variable, element: str = None):
        self.variable = variable
        self.element = element
    
    def __repr__(self):
        if self.element is None:
            return f"{self.variable.name}"
        else:
            return f"{self.variable.name}.{self.element}"

    def __eq__(self, other):
        if isinstance(other, SSR_Variable):
            return self.variable == other.variable and self.element == other.element
        else:
            return False

    def __hash__(self):
        return hash((self.variable, self.element))

    def expression(self):
        if self.element is None:
            return f"{self.variable.name}"
        else:
            return f"{self.variable.name}.{self.element}"

# 根据变量和对应节点生成对应的SSR
def get_ssrVar_from_varAndNode(_var: Variable, _source_node: Node, _contract_path):
    _ssrVar_set = set()

    if _source_node is None: 
        _ssrVar = SSR_Variable(_var)
        _ssrVar_set.add(_ssrVar)
    
    else:
        if not is_variable_struct(_var):
            _ssrVar = SSR_Variable(_var)
            _ssrVar_set.add(_ssrVar)
        else:
            _read_element = False
            _elements = get_variable_structElements(_var)
            for _elem in _elements:
                for _node in _source_node.function.nodes:
                    if check_string_in_node(_contract_path, _node, _elem):
                        _read_element = True
                        _ssrVar = SSR_Variable(_var, _elem)
                        _ssrVar_set.add(_ssrVar)
            
            # 直接读取整个struct变量的情况
            if not _read_element:
                _ssrVar = SSR_Variable(_var)
                _ssrVar_set.add(_ssrVar)

    return _ssrVar_set
        

# 判断一个变量是否是（或者包含）struct
def is_variable_struct(_var):
    """
    递归分析变量以检查是否有 StructureContract 的结构。
    
    :param _var: 要分析的变量
    :return: 如果包含Struct，返回 True，否则返回 False
    """
    # 检查变量是否有 type 属性
    if hasattr(_var, 'type'):
        type_attr = getattr(_var, 'type')
        if type(type_attr).__name__ == "StructureContract":
            return True

    # 检查变量是否有 type_to 属性
    if hasattr(_var, 'type_to'):
        type_to_attr = getattr(_var, 'type_to')
        if type(type_to_attr).__name__ == "StructureContract":
            return True

    # 如果不是 StructureContract，则递归地检查 type 和 type_to
    if hasattr(_var, 'type'):
        if is_variable_struct(_var.type):
            return True

    if hasattr(_var, 'type_to'):
        if is_variable_struct(_var.type_to):
            return True

    # 如果所有检查都未找到匹配的元素，则返回 False
    return False


# 判断一个变量是否是（或者包含）struct
def get_variable_structElements(_var):
    """
    递归分析变量以检查是否有 StructureContract 的结构。
    
    :param _var: 要分析的变量
    :return: 如果包含Struct，返回 struct的元素列表，否则返回 None
    """
    # 检查变量是否有 type 属性
    if hasattr(_var, 'type'):
        type_attr = getattr(_var, 'type')
        if type(type_attr).__name__ == "StructureContract":
            return type_attr.elems

    # 检查变量是否有 type_to 属性
    if hasattr(_var, 'type_to'):
        type_to_attr = getattr(_var, 'type_to')
        if type(type_to_attr).__name__ == "StructureContract":
            return type_to_attr.elems

    # 如果不是 StructureContract，则递归地检查 type 和 type_to
    if hasattr(_var, 'type'):
        if is_variable_struct(_var.type):
            return get_variable_structElements(_var.type)

    if hasattr(_var, 'type_to'):
        if is_variable_struct(_var.type_to):
            return get_variable_structElements(_var.type_to)

    # 如果所有检查都未找到匹配的元素，则返回 None
    return None

# 根据LLM给定的变量名称获取对应的状态变量
def get_stateVar_from_varName_info(_contract: Contract, _read_varName):
    # 初始化变量
    _var_dict = {}

    # 判断变量类型
    _var_name, _element = parse_variable_name(_read_varName)
    _var_dict["Variable"] = None
    _var_dict["Element"] = _element

    # 获取合约中所有的状态变量
    _state_vars_set = get_all_stateVariables_set(_contract)

    # 遍历状态变量，找到与给定变量名匹配的变量
    if _element is None:
        # 对于普通变量，直接匹配变量名称
        for _var in _state_vars_set:
            if _var.name == _var_name:
                _var_dict["Variable"] = _var
    else:
        # 对于struct变量，需要匹配变量名称和元素名称
        for _var in _state_vars_set:
            if is_variable_struct(_var):
                # LLM输出的直接是struct变量的名称的情况
                if _var.name == _var_name:
                    if _element in get_variable_structElements(_var):
                        _var_dict["Variable"] = _var

                # LLM输出的是struct类型的名称的情况
                if is_var_match_structElems(_var, _var_name, _element):
                    _var_dict["Variable"] = _var

    return _var_dict


# 识别变量类型（普通变量或struct变量）
def parse_variable_name(variable_name):
    # 匹配结构体元素的模式，例如 struct.element
    struct_pattern = r"([a-zA-Z_][a-zA-Z0-9_]*)\.([a-zA-Z_][a-zA-Z0-9_]*)"
    
    # 如果匹配结构体模式
    match = re.match(struct_pattern, variable_name)
    if match:
        var_name = match.group(1)  # 结构体的名称
        element = match.group(2)   # 元素的名称
        return var_name, element
    
    # 如果没有匹配到结构体模式，则认为它是一个普通变量
    return variable_name, None

# 判断给定变量名是否是某个自定义的struct的成员变量
def is_var_match_structElems(_var, _varName, _element):
    """
    递归分析变量以检查是否有与给定变量名称相匹配的 StructureContract 的元素。
    
    :param variable: 要分析的变量
    :param variable_name: 要搜索的变量名称（或struct类型的名称）
    :return: 如果找到匹配的元素，返回 True，否则返回 False
    """
    # 检查变量是否有 type 属性
    if hasattr(_var, 'type'):
        type_attr = getattr(_var, 'type')
        if type(type_attr).__name__ == "StructureContract":
            # 如果是 StructureContract，检查 elements 是否与 variable_name 匹配
            if hasattr(type_attr, 'name') and _varName == type_attr.name:
                if hasattr(type_attr, 'elems') and _element in type_attr.elems:
                    return True

    # 检查变量是否有 type_to 属性
    if hasattr(_var, 'type_to'):
        type_to_attr = getattr(_var, 'type_to')
        if type(type_to_attr).__name__ == "StructureContract":
            # 如果是 StructureContract，检查 elements 是否与 variable_name 匹配
            if hasattr(type_to_attr, 'name') and _varName == type_to_attr.name:
                if hasattr(type_to_attr, 'elems') and _element in type_to_attr.elems:
                    return True

    # 如果不是 StructureContract，则递归地检查 type 和 type_to
    if hasattr(_var, 'type'):
        if is_var_match_structElems(_var.type, _varName, _element):
            return True

    if hasattr(_var, 'type_to'):
        if is_var_match_structElems(_var.type_to, _varName, _element):
            return True

    # 如果所有检查都未找到匹配的元素，则返回 False
    return False


# 获取所有合约的状态变量集合
def get_all_stateVariables_set(_contract: Contract):
    _state_var_set = set()
    # 获取主合约的状态变量
    for _var in _contract.state_variables:
        _state_var_set.add(_var)

    # 获取父合约的状态变量
    for _father_contract in _contract.inheritance:
        for _var in _father_contract.state_variables:
            _state_var_set.add(_var)

    return _state_var_set

# 从函数参数对象arg中获取对应的变量
def get_vars_fromArg(_arg):
    _vars_set = set()  # 用于收集所有找到的 content

    # 如果变量包含 expressions 属性，则进行递归检查
    if hasattr(_arg, 'expressions'):
        # 获取 expression 的值，如果它是一个列表，递归检查每个元素
        expressions_value = getattr(_arg, 'expressions')
        # 对列表中的每个元素执行操作
        for item in expressions_value:
            _vars_set.update(get_vars_fromArg(item))
    else:
        # 如果没有 expressions 属性，检查是否包含 source_mapping.content 属性
        if hasattr(_arg, 'expression'):
            expression = getattr(_arg, 'expression')
            if hasattr(expression, 'value'):
                if (type(expression.value).__name__ == 'StateVariable') or (type(expression.value).__name__ == 'LocalVariable'):
                    _vars_set.add(expression.value)
        else:
            if hasattr(_arg, 'value'):
                if (type(_arg.value).__name__ == 'StateVariable') or (type(_arg.value).__name__ == 'LocalVariable'):
                    _vars_set.add(_arg.value)
    
    return _vars_set


# *************************************************************************
# Nodes Analysis
# *************************************************************************

# 根据代码行数寻找相应的节点
def get_node_from_lineNums(_contract: Contract, _lineNums_list):
    _target_node = None

    # print(_lineNums_list)
    for _func in _contract.functions:
        _func_lines = _func.source_mapping.lines
        if set(_lineNums_list).issubset(set(_func_lines)):
            # 找到定义_target_var的语句所在的节点
            for _node in _func.nodes[1:]:
                _node_lines = _node.source_mapping.lines
                if set(_lineNums_list).issubset(set(_node_lines)):
                    _target_node = _node
                    break

    return _target_node


def extract_lines(file_path, line_numbers):
    """
    从智能合约文件中提取指定行，并按顺序组合成一个字符串。

    :param file_path: 智能合约文件路径（sol文件）
    :param line_numbers: 包含代码行数的列表，按顺序提取
    :return: 一个字符串，包含指定行的内容
    """
    try:
        # 打开智能合约文件
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()

        # 提取指定行，并组合成字符串
        extracted_lines = []
        for line_number in line_numbers:
            # 检查行号是否有效
            if 1 <= line_number <= len(lines):
                extracted_lines.append(lines[line_number - 1].strip())
            else:
                print(f"警告：行号 {line_number} 超出了文件的范围，已跳过。")

        # 将提取的行组合成一个字符串
        result = ' '.join(extracted_lines)
        return result

    except FileNotFoundError:
        print(f"错误：找不到文件 {file_path}")
        return ""
    except Exception as e:
        print(f"发生错误：{e}")
        return ""


# 根据语句寻找对应的节点
def get_node_from_statement(_target_func: Function, _target_statement, _contract: Contract, _contract_file_path):
    """
    根据Statement对象寻找对应的节点。

    :param _target_func: 目标函数
    :param _target_statement: 目标语句
    :param _contract: 目标函数所在的合约
    :param _contract_file_path: 目标合约文件路径
    :return _target_node_set: 目标函数中包含目标语句的节点集合。
    返回值是集合的原因是：当该节点中存在IF-ELSE语句时，可能存在多个分支，因此返回多个节点。
    """
    _clean_target_statement = clean_string(_target_statement)
    _target_node_set = set()

    # 从目标函数本身识别转账语句（不考虑调用其他函数的情况）
    for _node in _target_func.nodes:
        try:
            # Slither能够正确输出content的情况
            _statement = _node.expression.source_mapping.content
            _clean_statement = clean_string(_statement)
            if _clean_target_statement in _clean_statement:
                _target_node_set.add(_node)
            
            # 如果Slither无法正确输出content，则尝试从源码文件中提取语句
            _lines_nums = _node.expression.source_mapping.lines
            _statement = extract_lines(_contract_file_path, _lines_nums)
            _clean_statement = clean_string(_statement)
            if _clean_target_statement in _clean_statement:
                _target_node_set.add(_node)
        except:
            pass
    
    # 从目标函数调用的函数中寻找目标语句
    if len(_target_node_set) == 0:
        _called_funcs_set = get_calledFuncs_set_fromFunc(_target_func, _contract)
        for _called_func in _called_funcs_set:
            for _called_node in _called_func.nodes:
                try:
                    _statement = _called_node.expression.source_mapping.content
                    _clean_statement = clean_string(_statement)
                    if _clean_target_statement in _clean_statement:
                        _target_node_set.add(_called_node)
                    
                    # 如果Slither无法正确输出content，则尝试从源码文件中提取语句
                    _lines_nums = _called_node.expression.source_mapping.lines
                    _statement = extract_lines(_contract_file_path, _lines_nums)
                    _clean_statement = clean_string(_statement)
                    if _clean_target_statement in _clean_statement:
                        _target_node_set.add(_called_node)
                        # return _target_node
                except:
                    pass

    # 如果从Slither中找不到，则结合源码sol文件进行寻找目标语句

    return _target_node_set

# 使用正则表达式删除无意义的字符：\n、\r、\、空格
def clean_string(input_string):
    cleaned_string = re.sub(r'[\n\r\\\s]', '', input_string)
    return cleaned_string

# 判断一个节点是否直接修改了指定的变量的取值（不考虑调用的内部函数的情况）
def isNode_directly_modify_ssrVar(_node: Node, _modified_ssr_var: SSR_Variable, _contract_path):
    for _var in _node.variables_written:
        if _var.name == _modified_ssr_var.variable.name:
            if _modified_ssr_var.element == None:
                return True
            else:
                if check_string_in_node(_contract_path, _node, _modified_ssr_var.element):
                    return True

    return False

# 判断一个节点是否直接修改了指定的变量的取值（范围比较大的情况，修改variable或者element就行）
def isNode_directly_modify_varOrElem(_node: Node, _modified_ssr_var: SSR_Variable, _contract_path):
    for _var in _node.variables_written:
        if _var.name == _modified_ssr_var.variable.name:
            if _modified_ssr_var.element == None:
                return True
            else:
                if check_string_in_node(_contract_path, _node, _modified_ssr_var.element):
                    return True
    
    return False


# 判断一个节点是否直接修改了指定的变量的取值（考虑调用的内部函数的情况）
def isNode_modify_ssrVar(_node: Node, _modified_ssr_var: SSR_Variable, _contract_path):
    for _var in _node.variables_written:
        if _var == _modified_ssr_var.variable:
            if _modified_ssr_var.element == None:
                return True
            else:
                if check_string_in_node(_contract_path, _node, _modified_ssr_var.element):
                    return True
    
    _called_funcs_set = get_calledFuncs_set_fromNode(_node, _node.function.contract)
    for _called_func in _called_funcs_set:
        for _called_node in _called_func.nodes:
            if isNode_modify_ssrVar(_called_node, _modified_ssr_var, _contract_path):
                return True

    return False



# 检查给定合约源码文件的指定节点中，是否包含指定的字符串。
def check_string_in_node(_contract_path, _target_node: Node, _target_string):
    """
    检查给定合约源码文件的指定行中，是否包含指定的字符串。

    :param _contract_path: 合约源码文件路径
    :param _tarfet_node: 需要查找的节点
    :param _target_string: 需要查找的字符串
    :return: 如果目标字符串出现在指定的行中，返回 True；否则返回 False
    """

    try:
        _line_numbers = _target_node.expression.source_mapping.lines
        # 打开文件并读取所有行
        with open(_contract_path, 'r', encoding='utf-8') as file:
            contract_lines = file.readlines()

        # 校验行号是否在有效范围内
        for line_num in _line_numbers:
            if line_num < 1 or line_num > len(contract_lines):
                # print(f"行号 {line_num} 不在合约代码的有效行范围内！")
                return False

        # 检查指定行数是否包含目标字符串
        for line_num in _line_numbers:
            line_content = contract_lines[line_num - 1]  # 行号是从1开始的，所以要减去1
            if _target_string in line_content:
                return True
        return False

    except:
        return False


# 比较两个节点的先后顺序，并输出较早的节点（如果不可比，则返回None）
def get_deyond_node(_node1: Node, _node2: Node):
    if _node1.function == _node2.function:
        if _node1.node_id < _node2.node_id:
            return _node1
        elif _node1.node_id > _node2.node_id:
            return _node2
        else:
            return None
    else:
        _node1_called_funcs_set = get_calledFuncs_set_fromNode(_node1, _node1.function.contract)
        if _node2.function in _node1_called_funcs_set:
            return _node2

        _node2_called_funcs_set = get_calledFuncs_set_fromNode(_node2, _node2.function.contract)
        if _node1.function in _node2_called_funcs_set:
            return _node1
    
    return None

# 获取指定节点在指定函数中的位置
def get_nodeLocation_inFunc(_target_node: Node, _target_func: Function):
    _target_node_lines = _target_node.source_mapping.lines
    _target_func_lines = _target_func.source_mapping.lines

    # 如果指定节点本身就在指定函数中
    if set(_target_node_lines).issubset(set(_target_func_lines)):
        return _target_node

    # 如果指定节点在指定函数所调用的其他函数中
    else:
        for _node in _target_func.nodes[1:]:
            _called_funcs_set = get_calledFuncs_set_fromNode(_node, _target_func.contract)
            for _called_func in _called_funcs_set:
                _called_func_lines = _called_func.source_mapping.lines
                if set(_target_node_lines).issubset(set(_called_func_lines)):
                    return _node

    return None
        

# *************************************************************************
# Functions Analysis
# *************************************************************************

# 获取某个Function调用的所有函数（包括调用的函数调用的其他函数）
def get_calledFuncs_set_fromFunc(_target_func: Function, _contract: Contract):
    _called_func_set = set()

    # 基于堆栈来检测所有调用的函数
    _stack = [_target_func]
    _visited_func_set = set()
    while _stack:
        _current_func = _stack.pop()

        if _current_func in _visited_func_set:
            continue
    
        if (type(_current_func).__name__ == 'FunctionContract') or (type(_current_func).__name__ == 'Modifier'):  
            # print("Getting called Functions of ", _current_func.name)
            if _current_func.name not in math_funcNames_list:
                _visited_func_set.add(_current_func)
                _called_func_set.add(_current_func)

                if hasattr(_current_func, 'high_level_calls'):
                    for _func in _current_func.high_level_calls:
                        if _func not in _visited_func_set:
                            _stack.append(_func)
                        
                if hasattr(_current_func, 'internal_calls'):
                    for _func in _current_func.internal_calls:
                        if _func not in _visited_func_set:
                            _stack.append(_func)
                
                if hasattr(_current_func, 'low_level_calls'):
                    for _func in _current_func.low_level_calls:
                        if _func not in _visited_func_set:
                            _stack.append(_func)

        elif type(_current_func).__name__ == 'tuple':
            for _func in _current_func:
                _set = get_calledFuncs_set_fromFunc(_func, _contract)
                for _func in _set:
                    if _func not in _visited_func_set:
                        _stack.append(_func)

    # print("called Functions of ", _target_func.name, ": ", [_func.name for _func in _called_func_set])

    return _called_func_set


# 获取某个Node所调用的函数
def get_calledFuncs_set_fromNode(_target_node: Node, _contract: Contract):
    # 获取所有调用的函数
    _called_func_set = set()
    for _func in _target_node.high_level_calls:
        if type(_func).__name__ == 'FunctionContract':
            if _func.name not in math_funcNames_list:
                _called_func_set.add(_func)
        elif type(_func).__name__ == 'tuple':
            for _invoked_func in _func:
                _set = get_calledFuncs_set_fromFunc(_invoked_func, _contract)
                for _func in _set:
                    _called_func_set.add(_func)

    for _func in _target_node.internal_calls:
        if type(_func).__name__ == 'FunctionContract':
            if _func.name not in math_funcNames_list:
                _called_func_set.add(_func)
        elif type(_func).__name__ == 'tuple':
            for _invoked_func in _func:
                _set = get_calledFuncs_set_fromFunc(_invoked_func, _contract)
                for _func in _set:
                    _called_func_set.add(_func)
    
    for _cur_func in _called_func_set:
        _cur_called_func_set = get_calledFuncs_set_fromFunc(_cur_func, _contract)
        _called_func_set = _called_func_set.union(_cur_called_func_set)
        
    return _called_func_set


# 获取修改了指定变量的取值的函数
def get_funcs_modify_ssrVar(_contract: Contract, _modified_ssr_var: SSR_Variable, _contract_path):
    _modify_func_set = set()

    for _func in _contract.functions:
        if _func.is_constructor:
            continue

        if isFunc_modify_ssrVar(_func, _modified_ssr_var, _contract_path):
            if _func.visibility == "public" or _func.visibility == "external":
                _modify_func_set.add(_func)

            for _reachable_func in _func.all_reachable_from_functions:
                if not _reachable_func.is_constructor:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        _modify_func_set.add(_reachable_func)

    return _modify_func_set

# 判断一个函数是否可以修改了指定的变量的取值（不考虑调用的内部函数的情况）
# 只要修改了目标变量取值就算
def isFunc_modify_ssrVar(_func: Function, _modified_ssr_var: SSR_Variable, _contract_path):
    for _node in _func.nodes:
        # 判断节点是否修改了目标SSR Variable的取值
        if isNode_modify_ssrVar(_node, _modified_ssr_var, _contract_path):
            return True
    
    return False

# 获取任意修改了指定变量的取值的函数
def get_funcs_modify_ssrVar_freely(_contract: Contract, _modified_ssr_var: SSR_Variable, _contract_path):
    _modify_func_set = set()

    for _func in _contract.functions:
        if _func.is_constructor:
            continue

        if isFunc_modify_ssrVar_freely(_func, _modified_ssr_var, _contract_path):
            if _func.visibility == "public" or _func.visibility == "external":
                _modify_func_set.add(_func)

            for _reachable_func in _func.all_reachable_from_functions:
                if not _reachable_func.is_constructor:
                    if _reachable_func.visibility == "public" or _reachable_func.visibility == "external":
                        if len(_reachable_func.parameters) > 0:
                            _modify_func_set.add(_reachable_func)

    return _modify_func_set

# 判断一个函数是否可以任意（由函数输入任意设定）修改了指定的变量的取值（不考虑调用的内部函数的情况）
def isFunc_modify_ssrVar_freely(_func: Function, _modified_ssr_var: SSR_Variable, _contract_path):
    for _node in _func.nodes:
        # 判断节点是否读取了函数的输出参数
        _is_read_para = False
        for _read_var in _node.variables_read:
            if _read_var in _func.parameters:
                _is_read_para = True
                break
        
        # 如果没有读取函数的输出参数，则跳过该节点
        if not _is_read_para:
            continue

        # 判断节点是否修改了目标SSR Variable的取值
        if isNode_modify_ssrVar(_node, _modified_ssr_var, _contract_path):
            return True
    
    return False


# 从合约中获取执行了transfer或者transferFrom操作的函数和节点
def get_transfer_funcsAndnodes_list(_contract: Contract):
    _transfer_funcsAndnodes_list = []

    for _func in _contract.functions:
        # if _func.visibility != "public" and _func.visibility != "external":
        #     continue

        if _func.is_constructor:
            continue

        for _node in _func.nodes:
            # 判断_node是否执行了transfer或者transferFrom操作
            _called_funcs_set = get_calledFuncs_set_fromNode(_node, _contract)
            for _called_func in _called_funcs_set:
                if _called_func.name in ["transfer", "transferFrom"]:
                    _transfer_funcsAndnodes_list.append({"Function": _func, "Node": _node})
                    continue

    return _transfer_funcsAndnodes_list





# *************************************************************************
# Contracts Analysis
# *************************************************************************

# 从一个Slither文件中获取主合约
def get_MainContract(slither_obj):
    _keys = list(slither_obj.crytic_compile.compilation_units.keys())
    _target_contract_name = _keys[0] if len(_keys) == 1 else slither_obj.contracts[-1].name

    if is_path(_target_contract_name):
        for _contract in reversed(slither_obj.contracts):
            if _contract.contract_kind == "contract":
                _target_contract_name = _contract.name
                break

    for contract in slither_obj.contracts:
        if contract.name == _target_contract_name:
            return contract

# 判断Slither能否分析指定合约
def is_contract_analyzable(_contract_path):
    try:
        slither_obj = Slither(_contract_path)
        return True
    except:
        return False



# *************************************************************************
# Ungrouped
# *************************************************************************

























