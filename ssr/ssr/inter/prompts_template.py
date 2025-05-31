# ************************************************************
# Prompt Templates
# ************************************************************

system_template = """You are a smart contract auditor. You will be asked questions related to code semantic. You can mimic answering them in the background five times and provide me with the most frequently appearing answer. Furthermore, please strictly adhere to the output format specified in the question, there is no need to explain your answer."""

contract_template = """The DeFi staking contract allows users to stake tokens on the platform, thereby increasing the total value locked (TVL) and rewarding them with additional tokens as incentives. Does the above smart contract code is a DeFi Staking contract? Answer only "Yes" or "No"."""

variable_template = """In this DeFi staking contract, which variable is used to record the number of tokens staked by the user? Please answer in a section starts with "User Stake Amount:".
In this DeFi staking contract, which variable is used to record the rewards of the user? Please answer in a section starts with "User Stake Reward:".
In this DeFi staking contract, which variable is used to record the user's staking duration? Please answer in a section starts with "User Stake Time:".
In this DeFi staking contract, which variable is used to record the contract address of the tokens staked by the user? Please answer in a section starts with "Stake Token Address:".
In this DeFi staking contract, which variable is used to record the contract address of the tokens received as rewards by the user? Please answer in a section starts with "Reward Token Address:".
Please answer in the following json format:        
"User Stake Amount": ["Variable Name 1", "Variable Name 2"],
"User Stake Reward": ["Variable Name 1", "Variable Name 2"],
"User Stake Time": ["Variable Name 1", "Variable Name 2"],
"Stake Token Address": ["Variable Name 1", "Variable Name 2"],
"Reward Token Address": ["Variable Name 1", "Variable Name 2"]
Note: 
1. When outputting the variable name, there is no need to include the contract name. If the obtained variable is a regular variable, please output the variable name as "Variable Name". If the obtained variable is an element of a struct in a contract, please output the variable name as "Struct Name"."Element Name", without including the index.
2. If the contract does not include the corresponding function, leave the "Variable name" and "Description" fields empty in the response. For instance, if the contract does not have a variable for recording the number of tokens staked by the user, the response should be formatted in JSON as follows: "User Stake Amount": []."""

calculation_template = """In this DeFi Staking Contract, for each function employed to allow users to stake tokens, which statement is used to transfer equity tokens to users who have staked their tokens? Please answer in a section starts with “Stake Calculation:”.
In this DeFi Staking Contract, for each function employed to allow users to claim rewards, which statement is used to transfer the staking rewards to the user? Please answer in a section starts with “Reward Calculation:”.
In this DeFi Staking Contract, for each function employed to allow users to unstake tokens, which statement is used to transfer the tokens from unstaking to the user? Please answer in a section starts with “unStake Calculation:”.
Please answer in the following json format:   
"Stake": [{"Function": "Stake Function Name 1", "Node": "Transfer Statement"}, {"Function": "Stake Function Name 2", "Node": "Transfer Statement"}],
"getReward": [{"Function": "getReward Function Name 1", "Node": "Transfer Statement"}, {"Function": "getReward Function Name 2", "Node": "Transfer Statement"}],
"unStake": [{"Function": "unStake Function Name 1", "Node": "Transfer Statement"}, {"Function": "unStake Function Name 2", "Node": "Transfer Statement"}]
Please ensure that the obtained statement is complete, but do not include the semicolon at the end of the sentence."""

# ************************************************************
# Functions to generate prompts and messages
# ************************************************************

def get_contract_message(_contract_code_str):
    question_contract = f'{_contract_code_str} \n \n Please analyze the above code, and answer the questions: "{contract_template}"'

    _messages = [
        {"role": "system", "content": system_template},
        {"role": "user", "content": question_contract}
    ]

    return _messages

def get_variables_message(_contract_code_str):
    question_variable = f'{_contract_code_str} \n \n Please analyze the above code, and answer the questions: "{variable_template}"'

    _messages = [
        {"role": "system", "content": system_template},
        {"role": "user", "content": question_variable}
    ]

    return _messages

def get_calculations_message(_contract_code_str):
    question_calculation = f'{_contract_code_str} \n \n Please analyze the above code, and answer the questions: "{calculation_template}"'

    _messages = [
        {"role": "system", "content": system_template},
        {"role": "user", "content": question_calculation}
    ]

    return _messages
