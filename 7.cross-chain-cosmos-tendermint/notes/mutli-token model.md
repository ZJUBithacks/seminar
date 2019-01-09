# multi-token model  

## overview
  　　在权益证明POS区块链中，代币主要有抵押和交易两种功能。但在单一代币模型中，代币流动性的增加会导致网络安全性降低。为了避免该情况，Cosmos团队在Cosmos Hub中采用了多代币模型multi-token model，其代币关系示意图由下图表示。由下图可知，在Cosmos的多代币模型中，代币的抵押和交易功能分离，其抵押功能由权益代币（staking token）Atom实现，而费用代币（fee tokens）则采用多种代币，其中也包括了原生费用代币Proton。  
    ![多代币模型示意图]( https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/multi_token_model.png)
## staking token: Atom  
　　在cosmos hub中，Atom作为权益代币，主要用于抵押，可通过区块增发获得。  
　　用户通过抵押自己的和被委托的Atom成为验证者，其抵押的Atom总量就是其股权。验证者参与共识过程，可轮流出块，具有投票权。验证者可通过交易费和区块奖励获得收益，其抵押的Atom占总抵押Atom的比例就是其获得的收益比例占收益的比例。其他用户（委托人）也可以通过将自己的Atom委托给其他用户，通过委托抵押的Atom来获取相应的收益。  
　　为了激励用户将手中的Atom进行抵押，Atom具有持续的通胀率。
  如何解释？
## fee token: Proton

## many fee tokens  

## examples
