# SSR (Safegurading Staking Rewards)

**SSR** is a detection tool for logical defects in DeFi Staking Contract written in Python.


## Install

### Install Slither
```
python3 setup.py install
```

### Install Libraries
```
pip install -r ./requirements.txt
```

## Usage
```console
python ./ssr/defects_identifier.py $your_folder_path$/examples/sportsDAO.sol
```
Note: 
The input should be the absolute path of the contract to be analyzed.
And the analysis results will be outputted to the same folder of the contract.
