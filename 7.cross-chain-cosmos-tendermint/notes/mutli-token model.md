# multi-token model  

## overview
  　　在权益证明POS区块链中，代币主要有抵押和交易两种功能。但在单一代币模型中，代币流动性的增加会导致网络安全性降低。为了避免该情况，Cosmos团队在Cosmos Hub中采用了多代币模型multi-token model，其代币关系示意图由下图表示。由下图可知，在Cosmos的多代币模型中，代币的抵押和交易功能分离，其抵押功能由权益代币（staking token）Atom实现，而费用代币（fee tokens）则采用多种代币，其中也包括了原生费用代币Proton。  
    ![多代币模型示意图]( https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/multi_token_model.png)
## staking token: Atom  
　　在cosmos hub中，Atom作为权益代币，主要用于抵押，可通过区块增发获得。  
　　用户通过抵押自己的和被委托的Atom成为验证者，其抵押的Atom总量就是其股权。验证者参与共识过程，可轮流出块，具有投票权。验证者可通过交易费和区块奖励获得收益，其抵押的Atom占总抵押Atom的比例就是其获得的收益比例占收益的比例。其他用户（委托人）也可以通过将自己的Atom委托给其他用户，通过委托抵押的Atom来获取相应的收益，同时支付给委托用户一定比例的佣金。  
　　为了激励用户将手中的Atom进行抵押，Atom具有持续的通胀率。Atom的总量会随着时间进行增长，其通胀率是基于Atom的供应总量。Atom的持有者只有通过抵押才能获得新分发的Atom，而未抵押的Atom会由于通货膨胀而相应地“贬值”了。由此激励用户将Atom进行抵押。在cosmos-sdk中，模块Inflation负责通胀率的计算，其通胀率按小时变化，目标是使抵押代币与未抵押代币的比率保持在67%左右，同时也限制了其通胀率变化范围，具体可参见![inflation in cosmos-sdk:end_block.md](https://github.com/cosmos/cosmos-sdk/blob/develop/docs/spec/inflation/end_block.md)。   
　　对抵押Atom进行激励，使得Atom的流通性降低，也是用户获得大份额股权（stake）代价增加，进一步增强了网络的安全性。
## fee token: Proton
　　Proton是cosmos提出的原生费用货币，相比Atom有着更好的流动性和交易速度，可在Cosmos Hub连接的所有分区之间任意转移。Proton可通过区块奖励获得，每个小时Proton的区块奖励为500 Protons，其通胀率近乎0。同时Proton也可以一次以太坊账户状态的硬舀取（Hard Spoon）来分发，数量与 Ether 的数量相等。具体可参见![cosmos fee token: Proton](https://medium.com/tendermint/proposed-cosmos-fee-token-codename-photon-e0927daf5c4c)
## many fee tokens  
　　在Cosmos Hub中，交易费并不强制使用某一单一代币，允许使用多种类型代币。用户可以使用自己所拥有的代币支付交易费，而不用转换成规定的代币，这就降低了跨区交易的门槛。在Cosmos Hub创建之初，其费用代币白名单只有Atom和Proton，随着各个分区Zone介入Hub，其费用代币白名单成员也会相应增加。  
　　由于使用多种交易代币，在区块打包时，交易的排序并不是根据具体交易费大小，而是根据transaction fee per resources进行排序，如BTC每字节、“gas price”（单个gas的ETH）。但在cosmos Hub中，采用的是根据计算量和存储花费预估各自交易类型/代币的权重，再进行相应的计算排序。为了保证Hub的去中心化，每个验证者对于各个类型的代币权重并不进行统一。验证者在打包区块时可根据自己的权重设定，对交易进行排序打包。  
  　　交易费分配：当区块确认后，一定比例的交易费分发给出块者，然后一部分上交community fund，剩下的部分由验证者按投票权/权益进行分配。出块者获取的比例可由以下公式进行计算：  
     ```  
     出块者比例=0.01+0.04*(投precommit验证者中的权益/抵押总权益)  
     ```  
　　委托者在获得收益的同时要支付一定的佣金给被委托人。在这一部分由cosmos-sdk的distribution模块处理，具体详见![distribution in cosmos-sdk](https://github.com/cosmos/cosmos-sdk/blob/develop/docs/spec/distribution/end_block.md)。
  
## examples  
1. **交易排序**  
有以下三条交易以及其各自的交易费:  
  ```
  　　tx1：ETH 5  
  　　tx2：BTC 0.01  
  　　tx3：Proton 100  
  ```  
  有两个验证者A和B，其各自的代币权重如下：    
  ```
　　validator A：ETH 1, BTC 100, Proton 0.1  　　
 　　validator B：ETH 5，BTC 200，Proton 0.01  
  ```
  验证者A和B分别作为打包者时，计算三条交易的交易费如下：  
  ```
  　　validator A:tx1 5, tx2 1, tx3 10 
  　　validator B:tx1 25, tx2 2, tx3 1  
  ```
  由此可知，验证者A对三条交易的排序分别为：tx3,tx1,tx2。而验证者B的排序则为：tx1,tx2,tx3。  
    
    
  2. **交易奖励分配**  
  
　　区块确认后，有奖励：ETH 1000，Proton 300。参与precommit验证者权益占总权益的80%，有出块者A，其权益占总权益的10%，而这其中只有20%是自己抵押的Atom，剩下的是其他用户委托的Atom，佣金为20%。有用户B将Atom委托给出块者A，委托的Atoms占A委托Atom的40%。奖励主要分配为出块奖励（交给出块者分配）、税（上交community fund）和所有validator共享的奖励。 在所以用户A获得的奖励有：  
```  
　　出块奖励比例=0.01+0.04*80%=0.042  
    出块奖励：ETH 1000*0.042=42；Proton 300*0.042=12.6   
```    
假设税为2%其分配示意图为：   
  ![](https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/%E4%BA%A4%E6%98%93%E5%A5%96%E5%8A%B1%E5%88%86%E9%85%8D%E7%A4%BA%E6%84%8F%E5%9B%BE.png)  
  
 在所以用户A获得的奖励有：  
```  
　　出块奖励比例=0.01+0.04*80%=0.042  
    出块奖励：ETH 1000*0.042=42；Proton 300*0.042=12.6  
    用户A的出块奖励佣金：ETH 42*70%*20%=5.88；Proton 12.6*70%*20%=1.764  
    用户A获得的奖励：ETH 42*30%+5.88=18.48；Proton 12.6*30%+1.764=5.544  
```  
而用户B通过委托获得的奖励有：  
```  
　　出块奖励比例=0.01+0.04*80%=0.042  
    出块奖励：ETH 1000*0.042=42；Proton 300*0.042=12.6  
    用户A委托用户的出块奖励：ETH 42*70%*(100-20)%=23.52；Proton 12.6*70%*(100-20)%=7.056  
    用户B获得的奖励：ETH 23.52*40%=9.048；Proton 7.056*40%=2.8224  
``` 
其出块奖励分配比例示意图如下图所示：  
![](https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/%E5%87%BA%E5%9D%97%E5%A5%96%E5%8A%B1%E5%88%86%E9%85%8D%E7%A4%BA%E6%84%8F%E5%9B%BE.png)
