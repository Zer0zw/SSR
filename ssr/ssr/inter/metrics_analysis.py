import json
import numpy as np
import os

# ************************************************************
# Normal
# ************************************************************
def read_json(file_path):
    # 打开文件并读取内容
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
    return data

def calculate_metrics_fromLists(groundTruth_list, model_list):
    # 统一转化为小写集合
    groundTruth_lower_set = set([item.lower() for item in groundTruth_list])
    model_lower_set = set([item.lower() for item in model_list])

    # 计算TP, FP, FN, TN
    # 将两个列表转换为集合进行计算
    true_positives = len(groundTruth_lower_set & model_lower_set)
    false_positives = len(model_lower_set - groundTruth_lower_set)
    false_negatives = len(groundTruth_lower_set - model_lower_set)
    true_negatives = 0  # 这个对于集合而言不适用
    
    # 计算Precision, Recall, Accuracy, F1 Score
    if true_positives + false_positives > 0:
        precision = true_positives / (true_positives + false_positives) if (true_positives + false_positives) > 0 else 0.0
    else:
        precision = 0.0
    
    if true_positives + false_negatives > 0:
        recall = true_positives / (true_positives + false_negatives) if (true_positives + false_negatives) > 0 else 0.0
    else:
        recall = 0.0
    
    accuracy = true_positives / (true_positives + false_positives + false_negatives) if (true_positives + false_positives + false_negatives) > 0 else 1.0
    
    if precision + recall > 0:
        f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0.0
    else:
        f1 = 0.0
    
    # 将每个类别的值保存到dict中
    metrics_dict = {
        "Accuracy": accuracy,
        "Precision": precision,
        "Recall": recall,
        "F1 Score": f1
    }
    
    return metrics_dict

# ************************************************************
# DeFi Staking Model metrics
# ************************************************************
def get_model_metrics(_groundTruth_json_path, _model_json_path):
    _metrics_dict = {}

    _groundTruth_dict = read_json(_groundTruth_json_path)
    _model_dict = read_json(_model_json_path)

    _model_groundTruth_dict = _groundTruth_dict["Model"]

    # Variables Model metrics
    _variables_model_groundTruth_dict = _model_groundTruth_dict["Variables"]
    _variables_model_dict = _model_dict["Variables"]

    _variables_metrics_dict = get_variables_model_metrics(_variables_model_groundTruth_dict, _variables_model_dict)
    _metrics_dict["Variables"] = _variables_metrics_dict

    # Functions Model metrics
    _functions_model_groundTruth_dict = _model_groundTruth_dict["Functions"]
    _functions_model_dict = _model_dict["Functions"]

    _functions_metrics_dict = get_functions_model_metrics(_functions_model_groundTruth_dict, _functions_model_dict)
    _metrics_dict["Functions"] = _functions_metrics_dict

    # Calculations Model metrics
    _calculations_model_groundTruth_dict = _model_groundTruth_dict["Calculations"]
    _calculations_model_dict = _model_dict["Calculations"]

    _calculations_metrics_dict = get_calculations_model_metrics(_calculations_model_groundTruth_dict, _calculations_model_dict)
    _metrics_dict["Calculations"] = _calculations_metrics_dict

    # Avg
    _avg_accuracy = np.mean([_metrics_dict["Variables"]["Mean"]["Accuracy"], _metrics_dict["Functions"]["Mean"]["Accuracy"], _metrics_dict["Calculations"]["Mean"]["Accuracy"]])
    _avg_precision = np.mean([_metrics_dict["Variables"]["Mean"]["Precision"], _metrics_dict["Functions"]["Mean"]["Precision"], _metrics_dict["Calculations"]["Mean"]["Precision"]])
    _avg_recall = np.mean([_metrics_dict["Variables"]["Mean"]["Recall"], _metrics_dict["Functions"]["Mean"]["Recall"], _metrics_dict["Calculations"]["Mean"]["Recall"]])
    _avg_f1_score = np.mean([_metrics_dict["Variables"]["Mean"]["F1 Score"], _metrics_dict["Functions"]["Mean"]["F1 Score"], _metrics_dict["Calculations"]["Mean"]["F1 Score"]])

    _metrics_dict["Mean"] = {
        "Accuracy": _avg_accuracy,
        "Precision": _avg_precision,
        "Recall": _avg_recall,
        "F1 Score": _avg_f1_score
    }

    return _metrics_dict

# Variables
def get_variables_model_metrics(_variables_model_groundTruth_dict, variables_model_dict):
    _variables_metrics_dict = {}

    _accuracies_list = []
    _precisions_list = []
    _recalls_list = []
    _f1_scores_list = []

    for key in _variables_model_groundTruth_dict.keys():
        _groundTruth_list = _variables_model_groundTruth_dict[key]
        _model_list = variables_model_dict[key]

        _metrics_dict_perKey = calculate_metrics_fromLists(_groundTruth_list, _model_list)

        _accuracies_list.append(_metrics_dict_perKey["Accuracy"])
        _precisions_list.append(_metrics_dict_perKey["Precision"])
        _recalls_list.append(_metrics_dict_perKey["Recall"])
        _f1_scores_list.append(_metrics_dict_perKey["F1 Score"])

        _variables_metrics_dict[key] = _metrics_dict_perKey
    
    _avg_accuracy = np.mean(_accuracies_list)
    _avg_precision = np.mean(_precisions_list)
    _avg_recall = np.mean(_recalls_list)
    _avg_f1_score = np.mean(_f1_scores_list)

    _variables_metrics_dict["Mean"] = {
        "Accuracy": _avg_accuracy,
        "Precision": _avg_precision,
        "Recall": _avg_recall,
        "F1 Score": _avg_f1_score
    }

    return _variables_metrics_dict

# Functions
def get_functions_model_metrics(_functions_model_groundTruth_dict, functions_model_dict):
    _functions_metrics_dict = {}

    _accuracies_list = []
    _precisions_list = []
    _recalls_list = []
    _f1_scores_list = []

    for key in _functions_model_groundTruth_dict.keys():
        _groundTruth_list = _functions_model_groundTruth_dict[key]
        _model_list = functions_model_dict[key]

        _metrics_dict_perKey = calculate_metrics_fromLists(_groundTruth_list, _model_list)

        _accuracies_list.append(_metrics_dict_perKey["Accuracy"])
        _precisions_list.append(_metrics_dict_perKey["Precision"])
        _recalls_list.append(_metrics_dict_perKey["Recall"])
        _f1_scores_list.append(_metrics_dict_perKey["F1 Score"])

        _functions_metrics_dict[key] = _metrics_dict_perKey
    
    _avg_accuracy = np.mean(_accuracies_list)
    _avg_precision = np.mean(_precisions_list)
    _avg_recall = np.mean(_recalls_list)
    _avg_f1_score = np.mean(_f1_scores_list)

    _functions_metrics_dict["Mean"] = {
        "Accuracy": _avg_accuracy,
        "Precision": _avg_precision,
        "Recall": _avg_recall,
        "F1 Score": _avg_f1_score
    }

    return _functions_metrics_dict

# Calculations
def get_calculations_model_metrics(_calculations_model_groundTruth_dict, calculations_model_dict):
    _calculations_metrics_dict = {}

    _accuracies_list = []
    _precisions_list = []
    _recalls_list = []
    _f1_scores_list = []

    for key in _calculations_model_groundTruth_dict.keys():
        _groundTruth_list = _calculations_model_groundTruth_dict[key]
        _model_list = calculations_model_dict[key]

        _calculations_metrics_dict[key] = []

        for _groundTruth_dict in _groundTruth_list:
            # 根据函数名称找到对应的模型输出
            _func_name = _groundTruth_dict["Function"]
            for _model_dict in _model_list:
                if _model_dict["Function"] == _func_name:
                    _metrics_dict_perFunc = calculate_metrics_fromLists(_groundTruth_dict["Calculation Variables"], _model_dict["Full Calculation Variables"])

                    _accuracies_list.append(_metrics_dict_perFunc["Accuracy"])
                    _precisions_list.append(_metrics_dict_perFunc["Precision"])
                    _recalls_list.append(_metrics_dict_perFunc["Recall"])
                    _f1_scores_list.append(_metrics_dict_perFunc["F1 Score"])

                    _calculations_metrics_dict[key].append({
                        "Function": _func_name,
                        "Metrics": _metrics_dict_perFunc
                    })

                    break
    
    _avg_accuracy = np.mean(_accuracies_list)
    _avg_precision = np.mean(_precisions_list)
    _avg_recall = np.mean(_recalls_list)
    _avg_f1_score = np.mean(_f1_scores_list)

    _calculations_metrics_dict["Mean"] = {
        "Accuracy": _avg_accuracy,
        "Precision": _avg_precision,
        "Recall": _avg_recall,
        "F1 Score": _avg_f1_score
    }
    
    return _calculations_metrics_dict

# ************************************************************
# DeFi Staking Defects Detection metrics
# ************************************************************
def get_defects_detection_metrics(_groundTruth_json_path, _defects_json_path):
    _metrics_dict = {}

    _groundTruth_dict = read_json(_groundTruth_json_path)
    _defects_dict = read_json(_defects_json_path)
    _defects_groundTruth_dict = _groundTruth_dict["Defects"]

    for key in _defects_groundTruth_dict.keys():
        _num_defects_groundTruth = len(_defects_groundTruth_dict[key])
        _num_defects_detected = len(_defects_dict[key])

        if _num_defects_detected == 0 and _num_defects_groundTruth == 0:
            _metrics_dict[key] = "TN"

        if _num_defects_detected == 0 and _num_defects_groundTruth > 0:
            _metrics_dict[key] = "FN"

        if _num_defects_detected > 0 and _num_defects_groundTruth == 0:
            _metrics_dict[key] = "FP"

        if _num_defects_detected > 0 and _num_defects_groundTruth > 0:
            _metrics_dict[key] = "TP"
    
    return _metrics_dict

# ************************************************************
# Total metrics
# ************************************************************
def output_total_metrics_perProject(_groundTruth_json_path, _model_json_path, _defects_json_path, output_json_path):
    _metrics_dict = {}

    _model_metrics_dict = get_model_metrics(_groundTruth_json_path, _model_json_path)
    _defects_detection_metrics_dict = get_defects_detection_metrics(_groundTruth_json_path, _defects_json_path)

    _metrics_dict["Model"] = _model_metrics_dict
    _metrics_dict["Defects"] = _defects_detection_metrics_dict

    # Output
    with open(output_json_path, 'w', encoding='utf-8') as file:
        json.dump(_metrics_dict, file, indent=4)
    
    return _metrics_dict

# ************************************************************
# GroundTruth Dataset metrics
# ************************************************************

# 输出groundTruth数据集中DeFi Staking建模以及漏洞检测的效果
def output_groundTruth_metrics(_groundTruth_folder_path, _output_json_path):
    _metrics_dict = get_groundTruth_metrics_dict(_groundTruth_folder_path)

    # Output
    with open(_output_json_path, 'w', encoding='utf-8') as file:
        json.dump(_metrics_dict, file, indent=4)


# 计算groundTruth数据集中DeFi Staking建模以及漏洞检测的效果
def get_groundTruth_metrics_dict(_groundTruth_folder_path):
    _metrics_dict_list = read_json_files_from_folder(_groundTruth_folder_path)

    _metrics_model_dict = get_total_metrics_model(_metrics_dict_list)
    _metrics_defects_dict = get_total_metrics_defects(_metrics_dict_list)

    _metrics_dict = {
        "Model": _metrics_model_dict,
        "Defects": _metrics_defects_dict
    }

    return _metrics_dict

# 从指定文件夹中读取所有的json文件，并生成list
def read_json_files_from_folder(folder_path):
    json_data_list = []
    
    # 遍历文件夹中的所有文件
    for filename in os.listdir(folder_path):
        # 检查文件扩展名是否为.json
        if filename.endswith('.json'):
            file_path = os.path.join(folder_path, filename)
            
            # 打开并读取JSON文件
            with open(file_path, 'r', encoding='utf-8') as f:
                try:
                    data = json.load(f)
                    json_data_list.append(data)
                except json.JSONDecodeError:
                    print(f"文件 {filename} 不是有效的JSON文件，跳过该文件。")
    
    return json_data_list


# 计算DeFi Staking模型的总体指标
def get_total_metrics_model(_metrics_dict_list):
    _variables_accuracies_list = []
    _variables_precisions_list = []
    _variables_recalls_list = []
    _variables_f1_scores_list = []

    _functions_accuracies_list = []
    _functions_precisions_list = []
    _functions_recalls_list = []
    _functions_f1_scores_list = []

    _calculations_accuracies_list = []
    _calculations_precisions_list = []
    _calculations_recalls_list = []
    _calculations_f1_scores_list = []

    _mean_accuracies_list = []
    _mean_precisions_list = []
    _mean_recalls_list = []
    _mean_f1_scores_list = []

    for _metrics_dict_perProject in _metrics_dict_list:
        _metrics_model_dict_perProject = _metrics_dict_perProject["Model"]

        _variables_accuracies_list.append(_metrics_model_dict_perProject["Variables"]["Mean"]["Accuracy"])
        _variables_precisions_list.append(_metrics_model_dict_perProject["Variables"]["Mean"]["Precision"])
        _variables_recalls_list.append(_metrics_model_dict_perProject["Variables"]["Mean"]["Recall"])
        _variables_f1_scores_list.append(_metrics_model_dict_perProject["Variables"]["Mean"]["F1 Score"])

        _functions_accuracies_list.append(_metrics_model_dict_perProject["Functions"]["Mean"]["Accuracy"])
        _functions_precisions_list.append(_metrics_model_dict_perProject["Functions"]["Mean"]["Precision"])
        _functions_recalls_list.append(_metrics_model_dict_perProject["Functions"]["Mean"]["Recall"])
        _functions_f1_scores_list.append(_metrics_model_dict_perProject["Functions"]["Mean"]["F1 Score"])

        _calculations_accuracies_list.append(_metrics_model_dict_perProject["Calculations"]["Mean"]["Accuracy"])
        _calculations_precisions_list.append(_metrics_model_dict_perProject["Calculations"]["Mean"]["Precision"])
        _calculations_recalls_list.append(_metrics_model_dict_perProject["Calculations"]["Mean"]["Recall"])
        _calculations_f1_scores_list.append(_metrics_model_dict_perProject["Calculations"]["Mean"]["F1 Score"])

        _mean_accuracies_list.append(_metrics_model_dict_perProject["Mean"]["Accuracy"])
        _mean_precisions_list.append(_metrics_model_dict_perProject["Mean"]["Precision"])
        _mean_recalls_list.append(_metrics_model_dict_perProject["Mean"]["Recall"])
        _mean_f1_scores_list.append(_metrics_model_dict_perProject["Mean"]["F1 Score"])

    _total_metrics_model_dict_variables = {
        "Accuracy": np.mean(_variables_accuracies_list),
        "Precision": np.mean(_variables_precisions_list),
        "Recall": np.mean(_variables_recalls_list), 
        "F1 Score": np.mean(_variables_f1_scores_list)
    }

    _total_metrics_model_dict_functions = {
        "Accuracy": np.mean(_functions_accuracies_list),
        "Precision": np.mean(_functions_precisions_list),
        "Recall": np.mean(_functions_recalls_list), 
        "F1 Score": np.mean(_functions_f1_scores_list)
    }

    _total_metrics_model_dict_calculations = {
        "Accuracy": np.mean(_calculations_accuracies_list),
        "Precision": np.mean(_calculations_precisions_list),
        "Recall": np.mean(_calculations_recalls_list), 
        "F1 Score": np.mean(_calculations_f1_scores_list)
    }

    _total_metrics_model_dict_total = {
        "Accuracy": np.mean(_mean_accuracies_list),
        "Precision": np.mean(_mean_precisions_list),
        "Recall": np.mean(_mean_recalls_list), 
        "F1 Score": np.mean(_mean_f1_scores_list)
    }

    _total_metrics_model_dict = {
        "Variables": _total_metrics_model_dict_variables,
        "Functions": _total_metrics_model_dict_functions,
        "Calculations": _total_metrics_model_dict_calculations,
        "Total": _total_metrics_model_dict_total
    }

    return _total_metrics_model_dict

# 计算DeFi Staking Defects Detection的总体指标
def get_total_metrics_defects(_metrics_dict_list):
    # 初始化变量
    _num_cvm_tp = 0
    _num_cvm_fp = 0
    _num_cvm_tn = 0
    _num_cvm_fn = 0

    _num_rt_tp = 0
    _num_rt_fp = 0
    _num_rt_tn = 0
    _num_rt_fn = 0

    _num_slr_tp = 0
    _num_slr_fp = 0
    _num_slr_tn = 0
    _num_slr_fn = 0

    _num_esu_tp = 0
    _num_esu_fp = 0
    _num_esu_tn = 0
    _num_esu_fn = 0

    _num_uv_tp = 0
    _num_uv_fp = 0
    _num_uv_tn = 0
    _num_uv_fn = 0

    _num_ufa_tp = 0
    _num_ufa_fp = 0
    _num_ufa_tn = 0
    _num_ufa_fn = 0

    for _metrics_dict_perProject in _metrics_dict_list:
        _metrics_defects_dict_perProject = _metrics_dict_perProject["Defects"]

        _cvm_result_perProject = _metrics_defects_dict_perProject["Critical Variables Manipulation (CVM)"]
        _rt_result_perProject = _metrics_defects_dict_perProject["Rewards without Timedelay (RT)"]
        _slr_result_perProject = _metrics_defects_dict_perProject["Single Liquidity Pool Reliance (SLR)"]
        _esu_result_perProject = _metrics_defects_dict_perProject["Error or Omission in Status Update (ESU)"]
        _uv_result_perProject = _metrics_defects_dict_perProject["Unsafe Verifications (UV)"]
        _ufa_result_perProject = _metrics_defects_dict_perProject["Unauthorized User Funds Access (UFA)"]

        # CVM
        if _cvm_result_perProject == "TP":
            _num_cvm_tp += 1
        elif _cvm_result_perProject == "FP":
            _num_cvm_fp += 1
        elif _cvm_result_perProject == "TN":
            _num_cvm_tn += 1
        elif _cvm_result_perProject == "FN":
            _num_cvm_fn += 1
        
        # RT
        if _rt_result_perProject == "TP":
            _num_rt_tp += 1
        elif _rt_result_perProject == "FP":
            _num_rt_fp += 1
        elif _rt_result_perProject == "TN":
            _num_rt_tn += 1
        elif _rt_result_perProject == "FN":
            _num_rt_fn += 1
        
        # SLR
        if _slr_result_perProject == "TP":
            _num_slr_tp += 1
        elif _slr_result_perProject == "FP":
            _num_slr_fp += 1
        elif _slr_result_perProject == "TN":
            _num_slr_tn += 1
        elif _slr_result_perProject == "FN":
            _num_slr_fn += 1
        
        # ESU
        if _esu_result_perProject == "TP":
            _num_esu_tp += 1
        elif _esu_result_perProject == "FP":
            _num_esu_fp += 1
        elif _esu_result_perProject == "TN":
            _num_esu_tn += 1
        elif _esu_result_perProject == "FN":
            _num_esu_fn += 1
        
        # UV
        if _uv_result_perProject == "TP":
            _num_uv_tp += 1
        elif _uv_result_perProject == "FP":
            _num_uv_fp += 1
        elif _uv_result_perProject == "TN":
            _num_uv_tn += 1
        elif _uv_result_perProject == "FN":
            _num_uv_fn += 1
        
        # UFA
        if _ufa_result_perProject == "TP":
            _num_ufa_tp += 1
        elif _ufa_result_perProject == "FP":
            _num_ufa_fp += 1
        elif _ufa_result_perProject == "TN":
            _num_ufa_tn += 1
        elif _ufa_result_perProject == "FN":
            _num_ufa_fn += 1

    _cvm_accuracy = (_num_cvm_tp + _num_cvm_tn) / (_num_cvm_tp + _num_cvm_tn + _num_cvm_fp + _num_cvm_fn) if _num_cvm_tp + _num_cvm_tn + _num_cvm_fp + _num_cvm_fn > 0 else 0
    _cvm_precision = _num_cvm_tp / (_num_cvm_tp + _num_cvm_fp) if _num_cvm_tp + _num_cvm_fp > 0 else 0
    _cvm_recall = _num_cvm_tp / (_num_cvm_tp + _num_cvm_fn) if _num_cvm_tp + _num_cvm_fn > 0 else 0
    _cvm_f1_score = 2 * _cvm_precision * _cvm_recall / (_cvm_precision + _cvm_recall) if _cvm_precision + _cvm_recall > 0 else 0

    _rt_accuracy = (_num_rt_tp + _num_rt_tn) / (_num_rt_tp + _num_rt_tn + _num_rt_fp + _num_rt_fn) if _num_rt_tp + _num_rt_tn + _num_rt_fp + _num_rt_fn > 0 else 0
    _rt_precision = _num_rt_tp / (_num_rt_tp + _num_rt_fp) if _num_rt_tp + _num_rt_fp > 0 else 0
    _rt_recall = _num_rt_tp / (_num_rt_tp + _num_rt_fn) if _num_rt_tp + _num_rt_fn > 0 else 0
    _rt_f1_score = 2 * _rt_precision * _rt_recall / (_rt_precision + _rt_recall) if _rt_precision + _rt_recall > 0 else 0

    _slr_accuracy = (_num_slr_tp + _num_slr_tn) / (_num_slr_tp + _num_slr_tn + _num_slr_fp + _num_slr_fn) if _num_slr_tp + _num_slr_tn + _num_slr_fp + _num_slr_fn > 0 else 0
    _slr_precision = _num_slr_tp / (_num_slr_tp + _num_slr_fp) if _num_slr_tp + _num_slr_fp > 0 else 0
    _slr_recall = _num_slr_tp / (_num_slr_tp + _num_slr_fn) if _num_slr_tp + _num_slr_fn > 0 else 0
    _slr_f1_score = 2 * _slr_precision * _slr_recall / (_slr_precision + _slr_recall) if _slr_precision + _slr_recall > 0 else 0

    _esu_accuracy = (_num_esu_tp + _num_esu_tn) / (_num_esu_tp + _num_esu_tn + _num_esu_fp + _num_esu_fn) if _num_esu_tp + _num_esu_tn + _num_esu_fp + _num_esu_fn > 0 else 0
    _esu_precision = _num_esu_tp / (_num_esu_tp + _num_esu_fp) if _num_esu_tp + _num_esu_fp > 0 else 0
    _esu_recall = _num_esu_tp / (_num_esu_tp + _num_esu_fn) if _num_esu_tp + _num_esu_fn > 0 else 0
    _esu_f1_score = 2 * _esu_precision * _esu_recall / (_esu_precision + _esu_recall) if _esu_precision + _esu_recall > 0 else 0

    _uv_accuracy = (_num_uv_tp + _num_uv_tn) / (_num_uv_tp + _num_uv_tn + _num_uv_fp + _num_uv_fn) if _num_uv_tp + _num_uv_tn + _num_uv_fp + _num_uv_fn > 0 else 0
    _uv_precision = _num_uv_tp / (_num_uv_tp + _num_uv_fp) if _num_uv_tp + _num_uv_fp > 0 else 0
    _uv_recall = _num_uv_tp / (_num_uv_tp + _num_uv_fn) if _num_uv_tp + _num_uv_fn > 0 else 0
    _uv_f1_score = 2 * _uv_precision * _uv_recall / (_uv_precision + _uv_recall) if _uv_precision + _uv_recall > 0 else 0

    _ufa_accuracy = (_num_ufa_tp + _num_ufa_tn) / (_num_ufa_tp + _num_ufa_tn + _num_ufa_fp + _num_ufa_fn) if _num_ufa_tp + _num_ufa_tn + _num_ufa_fp + _num_ufa_fn > 0 else 0
    _ufa_precision = _num_ufa_tp / (_num_ufa_tp + _num_ufa_fp) if _num_ufa_tp + _num_ufa_fp > 0 else 0
    _ufa_recall = _num_ufa_tp / (_num_ufa_tp + _num_ufa_fn) if _num_ufa_tp + _num_ufa_fn > 0 else 0
    _ufa_f1_score = 2 * _ufa_precision * _ufa_recall / (_ufa_precision + _ufa_recall) if _ufa_precision + _ufa_recall > 0 else 0
        
    _CVM_metrics_dict = {
        "Accuracy": _cvm_accuracy,
        "Precision": _cvm_precision,
        "Recall": _cvm_recall,
        "F1 Score": _cvm_f1_score
    }

    _RT_metrics_dict = {
        "Accuracy": _rt_accuracy,
        "Precision": _rt_precision,
        "Recall": _rt_recall,
        "F1 Score": _rt_f1_score
    }

    _SLR_metrics_dict = {
        "Accuracy": _slr_accuracy,
        "Precision": _slr_precision,
        "Recall": _slr_recall,
        "F1 Score": _slr_f1_score
    }

    _ESU_metrics_dict = {
        "Accuracy": _esu_accuracy,
        "Precision": _esu_precision,
        "Recall": _esu_recall,
        "F1 Score": _esu_f1_score
    }

    _UV_metrics_dict = {
        "Accuracy": _uv_accuracy,
        "Precision": _uv_precision,
        "Recall": _uv_recall,
        "F1 Score": _uv_f1_score}

    _UFA_metrics_dict = {
        "Accuracy": _ufa_accuracy,
        "Precision": _ufa_precision,
        "Recall": _ufa_recall,
        "F1 Score": _ufa_f1_score
    }

    _num_positive_cvm = _num_cvm_tp + _num_cvm_fp
    _num_positive_rt = _num_rt_tp + _num_rt_fp
    _num_positive_slr = _num_slr_tp + _num_slr_fp
    _num_positive_esu = _num_esu_tp + _num_esu_fp
    _num_positive_uv = _num_uv_tp + _num_uv_fp
    _num_positive_ufa = _num_ufa_tp + _num_ufa_fp
    _num_positive_total = _num_positive_cvm + _num_positive_rt + _num_positive_slr + _num_positive_esu + _num_positive_uv + _num_positive_ufa

    _total_accuracy = (
        (_CVM_metrics_dict["Accuracy"] * _num_positive_cvm) + 
        (_RT_metrics_dict["Accuracy"] * _num_positive_rt) + 
        (_SLR_metrics_dict["Accuracy"] * _num_positive_slr) + 
        (_ESU_metrics_dict["Accuracy"] * _num_positive_esu) + 
        (_UV_metrics_dict["Accuracy"] * _num_positive_uv) + 
        (_UFA_metrics_dict["Accuracy"] * _num_positive_ufa)
    ) / _num_positive_total if _num_positive_total > 0 else 0

    _total_precision = (
        (_CVM_metrics_dict["Precision"] * _num_positive_cvm) + 
        (_RT_metrics_dict["Precision"] * _num_positive_rt) +    
        (_SLR_metrics_dict["Precision"] * _num_positive_slr) + 
        (_ESU_metrics_dict["Precision"] * _num_positive_esu) + 
        (_UV_metrics_dict["Precision"] * _num_positive_uv) + 
        (_UFA_metrics_dict["Precision"] * _num_positive_ufa)
    ) / _num_positive_total if _num_positive_total > 0 else 0

    _total_recall = (
        (_CVM_metrics_dict["Recall"] * _num_positive_cvm) + 
        (_RT_metrics_dict["Recall"] * _num_positive_rt) + 
        (_SLR_metrics_dict["Recall"] * _num_positive_slr) + 
        (_ESU_metrics_dict["Recall"] * _num_positive_esu) + 
        (_UV_metrics_dict["Recall"] * _num_positive_uv) + 
        (_UFA_metrics_dict["Recall"] * _num_positive_ufa)
    ) / _num_positive_total if _num_positive_total > 0 else 0

    _total_f1_score = (
        (_CVM_metrics_dict["F1 Score"] * _num_positive_cvm) + 
        (_RT_metrics_dict["F1 Score"] * _num_positive_rt) + 
        (_SLR_metrics_dict["F1 Score"] * _num_positive_slr) + 
        (_ESU_metrics_dict["F1 Score"] * _num_positive_esu) + 
        (_UV_metrics_dict["F1 Score"] * _num_positive_uv) + 
        (_UFA_metrics_dict["F1 Score"] * _num_positive_ufa)
    ) / _num_positive_total if _num_positive_total > 0 else 0

    _total_metrics_dict = {
        "Accuracy": _total_accuracy,
        "Precision": _total_precision,
        "Recall": _total_recall,
        "F1 Score": _total_f1_score
    }

    _total_metrics_defects_dict = {
        "Critical Variables Manipulation (CVM)": _CVM_metrics_dict,
        "Rewards without Timedelay (RT)": _RT_metrics_dict,
        "Single Liquidity Pool Reliance (SLR)": _SLR_metrics_dict,
        "Error or Omission in Status Update (ESU)": _ESU_metrics_dict,
        "Unsafe Verifications (UV)": _UV_metrics_dict,
        "Unauthorized User Funds Access (UFA)": _UFA_metrics_dict,
        "Total": _total_metrics_dict
    }

    return _total_metrics_defects_dict

    